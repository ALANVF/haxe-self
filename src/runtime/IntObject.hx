package runtime;

@:structInit
class IntObject extends Object {
	final value: Int;

	static function make(value: Int): IntObject {
		return {
			slots: [
				new ObjectSlot("parent", true, Globals.intParent)
			],
			value: value
		};
	}

	override function clone(): IntObject {
		return {
			slots: slots.map(s -> s.clone()),
			value: value
		};
	}

	override function print(prefix: String) {
		return printShort();
	}

	override function printShort() {
		return Std.string(value);
	}
}