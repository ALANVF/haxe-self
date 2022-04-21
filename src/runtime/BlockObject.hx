package runtime;

import parsing.Expr;

@:structInit
class BlockObject extends Object {
	final blockMethod: Object;

	static function make(slots: Array<Slot>, exprs: Array<Expr>, lexicalParent: Object): BlockObject {
		final numArgs = Slot.numArgSlots(slots);
		final valueSlotName = numArgs._match(
			at(0) => "value",
			at(1) => "value:",
			_ => "value:" + "With:".repeat(numArgs - 1)
		);

		slots.unshift(new ObjectSlot("_lexicalParent", true, lexicalParent));

		final blockMethod = Object.make(slots, exprs);

		return {
			slots: [
				new ObjectSlot(valueSlotName, blockMethod),
				new ObjectSlot("parent", true, Globals.blockParent)
			],
			blockMethod: blockMethod
		};
	}

	override function clone() {
		return BlockObject.make(
			slots.map(s -> s.clone()),
			exprs,
			blockMethod
		);
	}

	override function print(prefix: String) {
		prefix += "  ";
		return "[ "
				+ Slot.printSlots(slots, prefix)
				+ (slots.length != 0 && exprs.length != 0 ? '\n$prefix' : "")
				+ Object.printCode(exprs, prefix)
				+ "]";
	}

	override function printShort() {
		return "[...]";
	}
}