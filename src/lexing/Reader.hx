package lexing;

@:publicFields
@:build(util.Overload.build())
class Reader {
	private final input: String;
	private final length: Int;
	var offset: Int;

	function new(input: String) {
		this.input = input;
		length = input.length;
		offset = 0;
	}

	inline function hasNext() {
		return offset < length;
	}

	inline function hasNextAt(index: Int) {
		return offset + index < length;
	}

	inline overload function unsafePeek() {
		return @:privateAccess input._charCodeAt8Unsafe(offset);
	}

	inline overload function unsafePeek(char: Char) {
		return @:privateAccess input._charCodeAt8Unsafe(offset) == char;
	}

	inline function unsafePeekAt(index: Int) {
		return @:privateAccess input._charCodeAt8Unsafe(offset + index);
	}

	inline overload function peek() {
		return if(hasNext()) {
			unsafePeek();
		} else {
			null;
		}
	}

	inline overload function peek(char: Char) {
		return hasNext() && char == unsafePeek();
	}

	inline overload function eat() {
		final char = unsafePeek();

		offset++;

		return char;
	}
	
	inline overload function eat(char: Char) {
		return if(peek(char)) {
			offset++;
			true;
		} else {
			false;
		}
	}

	inline function next() {
		offset++;
	}
	
	inline overload function substring(startIndex) {
		return input.substring(startIndex, offset);
	}
	inline overload function substring(startIndex, endIndex) {
		return input.substring(startIndex, endIndex);
	}


	inline function peekDigit() return hasNext() && unsafePeek()._match(
		at('0'.code ... '9'.code) => true,
		_ => false
	);

	inline function peekLowerU() return hasNext() && unsafePeek()._match(
		at(('a'.code ... 'z'.code)
		 | '_'.code
		) => true,
		_ => false
	);

	inline function peekAlphaU() return hasNext() && unsafePeek()._match(
		at(('a'.code ... 'z'.code)
		 | ('A'.code ... 'Z'.code)
		 | '_'.code
		) => true,
		_ => false
	);

	inline function peekAlnum() return hasNext() && unsafePeek()._match(
		at(('a'.code ... 'z'.code)
		 | ('A'.code ... 'Z'.code)
		 | ('0'.code ... '9'.code)
		 | '_'.code
		) => true,
		_ => false
	);
}