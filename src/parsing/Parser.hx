package parsing;

import lexing.*;
import parsing.Expr;
import parsing.Slot;

@:publicFields
class Parser {
	static function parse(tokens: Tokens) {
		final exprs: Array<Expr> = [];
		var rest = tokens;

		while(true) rest._match(
			at([]) => break,
			_ => {
				detuple(@final [expr, rest2] = parseKeywordExpr(rest));
				exprs.push(expr);
				rest2._match(
					at([TDot] | []) => break,
					at([TDot, ...rest3]) => {
						rest = rest3;
					},
					_ => throw "Syntax error: " + rest2.head()
				);
			}
		);

		return exprs;
	}
	

	static function parseBaseExpr(tokens: Tokens) return tokens._match(
		at([TInt(int), ...rest]) => tuple(EInt(int), rest),
		at([TFloat(float), ...rest]) => tuple(EFloat(float), rest),
		at([TString(string), ...rest]) => tuple(EString(string), rest),
		at([TLParen, ...rest]) => {
			final slots = rest._match(
				at([TBar, ...rest2]) => {
					detuple([@final slotExprs, rest] = parseSlotExprs(rest2));
					slotExprs;
				},
				_ => []
			);
			final exprs: Array<Expr> = [];

			while(true) rest._match(
				at([TRParen, ...rest2]) => {
					rest = rest2;
					break;
				},
				_ => {
					detuple(@final [expr, rest2] = parseKeywordExpr(rest));
					exprs.push(expr);
					rest2._match(
						at([TDot, TRParen, ...rest3] | [TRParen, ...rest3]) => {
							rest = rest3;
							break;
						},
						at([TDot, ...rest3]) => {
							rest = rest3;
						},
						_ => throw "Syntax error"
					);
				}
			);

			tuple(EObject(false, slots, exprs), rest);
		},
		at([TLBracket, ...rest]) => {
			final slots = rest._match(
				at([TBar, ...rest2]) => {
					detuple([@final slotExprs, rest] = parseSlotExprs(rest2));
					slotExprs;
				},
				_ => []
			);
			final exprs: Array<Expr> = [];

			while(true) rest._match(
				at([TRBracket, ...rest2]) => {
					rest = rest2;
					break;
				},
				at([TReturn, TRBracket, ...rest2]) => {
					exprs.push(ENonLocalReturn(null));
					rest = rest2;
					break;
				},
				at([TReturn, ...rest2]) => {
					detuple(@final [expr, rest3] = parseKeywordExpr(rest2));
					exprs.push(ENonLocalReturn(expr));
					rest3._match(
						at([TDot, TRBracket, ...rest4] | [TRBracket, ...rest4]) => {
							rest = rest4;
							break;
						},
						_ => throw "Syntax error"
					);
				},
				_ => {
					detuple(@final [expr, rest2] = parseKeywordExpr(rest));
					exprs.push(expr);
					rest2._match(
						at([TDot, TRBracket, ...rest3] | [TRBracket, ...rest3]) => {
							rest = rest3;
							break;
						},
						at([TDot, ...rest3]) => {
							rest = rest3;
						},
						_ => throw "Syntax error"
					);
				}
			);

			tuple(EObject(true, slots, exprs), rest);
		},

		at([]) => throw "EOF",
		_ => throw "Syntax error: " + tokens.head()
	);

	static function parseUnaryExpr(tokens: Tokens) return tokens._match(
		at([TName(name), ...rest]) => {
			var expr = EUnaryMsg(EImplicitSelf, name);

			while(true) rest._match(
				at([TName(name2), ...rest2]) => {
					expr = EUnaryMsg(expr, name2);
					rest = rest2;
				},
				_ => break
			);

			tuple(expr, rest);
		},
		_ => {
			detuple(@var [expr, rest] = parseBaseExpr(tokens));
			if(!rest.match(Cons(TName(_), _))) return __anon__Tuple2;

			while(true) rest._match(
				at([TName(name), ...rest2]) => {
					expr = EUnaryMsg(expr, name);
					rest = rest2;
				},
				_ => break
			);

			tuple(expr, rest);
		}
	);

	static function parseBinaryExpr(tokens: Tokens) return tokens._match(
		at([TOp(op), ...rest]) => {
			detuple([@final arg, rest] = parseUnaryExpr(rest));
			var expr = EBinaryMsg(EImplicitSelf, op, arg);

			while(true) rest._match(
				at([TOp(op2), ...rest2]) => {
					detuple([@final arg2, rest] = parseUnaryExpr(rest2));
					expr = EBinaryMsg(expr, op2, arg2);
				},
				_ => break
			);

			tuple(expr, rest);
		},
		_ => {
			detuple(@var [expr, rest] = parseUnaryExpr(tokens));
			if(!rest.match(Cons(TOp(_), _))) return __anon__Tuple2;
			
			while(true) rest._match(
				at([TOp(op), ...rest2]) => {
					detuple([@final arg, rest] = parseUnaryExpr(rest2));
					expr = EBinaryMsg(expr, op, arg);
				},
				_ => break
			);

			tuple(expr, rest);
		}
	);

	static function parseKeywordExpr(tokens: Tokens): Tuple2<Expr, List<Token>> return tokens._match(
		at([TLabel(label), ...rest]) => {
			detuple([@final arg, rest] = parseKeywordExpr(rest));
			
			final labels = [label];
			final args = [arg];
			var name = label;

			while(true) rest._match(
				at([TULabel(label2), ...rest2]) => {
					detuple([@final arg2, rest] = parseKeywordExpr(rest2));
					labels.push(label2);
					args.push(arg2);
					name += label2;
				},
				_ => break
			);

			tuple(EKeywordMsg(EImplicitSelf, name, labels, args), rest);
		},
		_ => {
			detuple(@var [expr, rest] = parseBinaryExpr(tokens));
			rest._match(
				at([TLabel(label), ...rest]) => {
					detuple([@final arg, rest] = parseKeywordExpr(rest));

					final labels = [label];
					final args = [arg];
					var name = label;

					while(true) rest._match(
						at([TULabel(label2), ...rest2]) => {
							detuple([@final arg2, rest] = parseKeywordExpr(rest2));
							labels.push(label2);
							args.push(arg2);
							name += label2;
						},
						_ => break
					);

					tuple(EKeywordMsg(expr, name, labels, args), rest);
				},
				_ => __anon__Tuple2
			);
		}
	);


	static function parseSlotExpr(tokens: Tokens) return tokens._match(
		at([TColon, TName(name), ...rest]) => tuple(SArgument(name), rest),

		at([TName(name), ...rest]) => {
			final isParent = rest._match(
				at([TOp("*"), ...rest2]) => { rest = rest2; true; },
				_ => false
			);

			rest._match(
				at([TOp("="), ...rest2]) => {
					detuple(@final [expr, rest3] = parseKeywordExpr(rest2));
					tuple(SInitialized(name, isParent, expr, false), rest3);
				},
				at([TOp("<-"), ...rest2]) => {
					detuple(@final [expr, rest3] = parseKeywordExpr(rest2));
					tuple(SInitialized(name, isParent, expr, true), rest3);
				},
				_ => tuple(SUninitialized(name, isParent), rest)
			);
		},
		
		at([TOp(op), TName(arg), TOp("="), ...rest]) => {
			detuple(@final [expr, rest2] = parseKeywordExpr(rest));
			tuple(SMethod(op, [op], [arg], expr), rest2);
		},
		at([TOp(op), TOp("="), ...rest]) => {
			detuple(@final [expr, rest2] = parseKeywordExpr(rest));
			tuple(SInitialized(op, false, expr, false), rest2);
		},

		at([TLabel(label), TName(arg), ...rest]) => {
			final labels = [label];
			final args = [arg];
			var name = label;

			while(true) rest._match(
				at([TULabel(label2), TName(arg2), ...rest2]) => {
					labels.push(label2);
					args.push(arg2);
					name += label2;
					rest = rest2;
				},
				at([TOp("="), ...rest2]) => {
					rest = rest2;
					break;
				},
				_ => throw "Syntax error: " + rest.head()
			);
			
			detuple(@final [expr, rest2] = parseKeywordExpr(rest));
			tuple(SMethod(name, labels, args, expr), rest2);
		},
		at([TLabel(label), ...rest]) => {
			var name = label;

			while(true) rest._match(
				at([TLabel(label2), ...rest2]) => {
					name += label2;
					rest = rest2;
				},
				at([TOp("="), ...rest2]) => {
					rest = rest2;
					break;
				},
				_ => throw "Syntax error"
			);
			
			detuple(@final [expr, rest2] = parseKeywordExpr(rest));
			tuple(SInitialized(name, false, expr, false), rest2);
		},

		_ => throw "Syntax error"
	);

	static function parseSlotExprs(tokens: Tokens) {
		final slots: Array<Slot> = [];
		var rest = tokens;
		
		while(true) rest._match(
			at([TBar, ...rest2]) => {
				rest = rest2;
				break;
			},
			_ => {
				detuple(@final [slot, rest2] = parseSlotExpr(rest));
				slots.push(slot);
				rest2._match(
					at([TDot, TBar, ...rest3] | [TBar, ...rest3]) => {
						rest = rest3;
						break;
					},
					at([TDot, ...rest3]) => {
						rest = rest3;
					},
					_ => throw "Syntax error"
				);
			}
		);

		return tuple(slots, rest);
	}
}