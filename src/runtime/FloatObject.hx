package runtime;

@:structInit
class FloatObject extends Object {
	final value: Float;

	static function make(value: Float): FloatObject {
		return {
			slots: [
				new ObjectSlot("parent", true, Globals.floatParent)
			],
			value: value
		};
	}

	override function clone(): FloatObject {
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