package lexing;

import lexing.Token;

class Lexer {
	final reader: Reader;

	public function new(input: String) {
		reader = new Reader(input);
	}

	public function tokenize() {
		var res: Tokens = Nil;

		trim();

		while(reader.hasNext()) {
			res = res.prepend(readToken());
			trim();
		}

		return res.rev();
	}


	function trim() {
		while(reader.hasNext()) reader.unsafePeek()._match(
			at('\n'.code | '\r'.code | ' '.code | '\t'.code) => reader.next(),
			at('"'.code) => {
				reader.next();
				while(reader.hasNext() || throw new Eof()) {
					if(reader.eat() == '"'.code) {
						if(!reader.eat('"'.code)) break;
					}
				}
			},
			_ => break
		);
	}


	function readToken(): Token {
		if(!reader.hasNext()) throw new Eof();

		return reader.unsafePeek()._match(
			at('.'.code) => { reader.next(); TDot; },
			at(':'.code) => { reader.next(); TColon; },
			at('|'.code) => { reader.next(); TBar; },
			at('^'.code) => { reader.next(); TReturn; },

			at('('.code) => { reader.next(); TLParen; },
			at('['.code) => { reader.next(); TLBracket; },
			at('{'.code) => { reader.next(); TLBrace; },
			at(')'.code) => { reader.next(); TRParen; },
			at(']'.code) => { reader.next(); TRBracket; },
			at('}'.code) => { reader.next(); TRBrace; },

			at(('a'.code ... 'z'.code) | '_'.code) => {
				final start = reader.offset;

				do {
					reader.next();
				} while(reader.hasNext() && reader.peekAlnum());

				if(reader.eat(':'.code)) {
					TLabel(reader.substring(start));
				} else {
					TName(reader.substring(start));
				}
			},
			at('A'.code ... 'Z'.code) => {
				final start = reader.offset;

				do {
					reader.next();
				} while(reader.hasNext() && reader.peekAlnum());

				if(reader.eat(':'.code)) {
					TULabel(reader.substring(start));
				} else {
					throw 'Syntax error: ${reader.substring(start)}';
				}
			},

			at('-'.code) => if(reader.unsafePeekAt(1).isDigit()) readNumber() else readOp(),
			at('!'.code | '@'.code | '#'.code | '$'.code | '%'.code
			 | '&'.code | '*'.code | '+'.code | '='.code | '\\'.code
			 | '~'.code | '<'.code | '>'.code | '/'.code | '?'.code) => readOp(),
			
			at('0'.code ... '9'.code) => readNumber(),
			at("'".code) => {
				reader.next();
				var buf = new haxe.io.BytesBuffer();

				while(reader.hasNext() || throw new Eof()) reader.unsafePeek()._match(
					at('\\'.code) => {
						reader.next();
						if(!reader.hasNext()) throw new Eof();
						reader.eat()._match(
							at("'".code) => buf.addByte("'".code),
							at('\\'.code) => buf.addByte('\\'.code),
							at('n'.code) => buf.addByte('\n'.code),
							at('r'.code) => buf.addByte('\r'.code),
							at('t'.code) => buf.addByte('\t'.code),
							at('a'.code) => buf.addByte(7),
							at('b'.code) => buf.addByte(8),
							at('v'.code) => buf.addByte(11),
							at('f'.code) => buf.addByte(12),
							at('x'.code) => {
								final start = reader.offset;
								for(_ in 0...2) reader.eat()._match(
									at(c = ('0'.code ... '9'.code)
										 | ('A'.code ... 'F'.code)
										 | ('a'.code ... 'f'.code)
									) => {},
									at(c) => throw 'Syntax error: ${c.escape()}'
								);
								buf.addByte(Util.parseHex(reader.substring(start)));
							},
							at(esc) => throw 'Syntax error: Unknown escape code \\${esc.escape()}'
						);
					},
					at("'".code) => {
						reader.next();
						break;
					},
					at(char) => {
						buf.addByte(char);
						reader.next();
					}
				);

				TString(buf.getBytes());
			},

			at(char) => throw 'Syntax error: ${char.escape()}'
		);
	}

	function readOp() {
		final start = reader.offset;

		while(reader.hasNext()) reader.unsafePeek()._match(
			at('!'.code | '@'.code | '#'.code | '$'.code | '%'.code
			 | '&'.code | '*'.code | '-'.code | '+'.code | '='.code
			 | '\\'.code | '~'.code | '<'.code | '>'.code | '/'.code
			 | '?'.code) => reader.next(),
			_ => break
		);

		return TOp(reader.substring(start));
	}

	function readNumber() {
		final start = reader.offset;

		do {
			reader.next();
		} while(reader.peekDigit());

		if(reader.peek('.') && reader.hasNextAt(1) && reader.unsafePeekAt(1).isDigit()) {
			reader.next();
			
			do {
				reader.next();
			} while(reader.peekDigit());

			return TFloat(Std.parseFloat(reader.substring(start)));
		} else {
			return TInt(Util.parseInt(reader.substring(start)));
		}
	}
}