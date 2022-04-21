package runtime;

import haxe.io.Bytes;

@:structInit
class StringObject extends Object {
	final value: Bytes;

	static function make(value: Bytes): StringObject {
		return {
			slots: [
				new ObjectSlot("parent", true, Globals.stringParent)
			],
			value: value
		};
	}

	override function clone(): StringObject {
		return {
			slots: slots.map(s -> s.clone()),
			value: value.copy()
		};
	}

	override function print(prefix: String) {
		return printShort();
	}

	override function printShort() {
		return value.toString().escape(false, true).quoteSingle();
	}
}