package runtime;

import parsing.Expr;

@:structInit
@:publicFields
class Object {
	final slots: Array<Slot>;
	final exprs: Array<Expr> = [];

	static inline function make(slots: Array<Slot>, ?exprs: Array<Expr>): Object {
		return {
			slots: slots,
			exprs: exprs._or([])
		};
	}

	function clone() {
		return Object.make(slots.map(s -> s.clone()), exprs);
	}

	function addSlot(slot: Slot) {
		slots.push(slot);
	}

	function addOrReplaceSlot(slot: Slot) {
		slots.findIndex(s -> s.name == slot.name)._match(
			at(-1) => {
				slots.push(slot);
			},
			at(i) => {
				slots[i] = slot;
			}
		);
	}

	function prependSlot(slot: Slot) {
		slots.unshift(slot);
	}

	function prependOrReplaceSlot(slot: Slot) {
		slots.findIndex(s -> s.name == slot.name)._match(
			at(-1) => {
				slots.unshift(slot);
			},
			at(i) => {
				slots[i] = slot;
			}
		);
	}

	function getSlot(name: String) {
		return slots.find(s -> s.name == name);
	}

	function hasSlot(name: String) {
		return slots.some(s -> s.name == name);
	}

	inline function numArgSlots() {
		return Slot.numArgSlots(slots);
	}

	function print(prefix: String) {
		prefix += "  ";
		return "( "
				+ Slot.printSlots(slots, prefix)
				+ (slots.length != 0 && exprs.length != 0 ? '\n$prefix' : "")
				+ printCode(exprs, prefix)
				+ ")";
	}

	function printShort() {
		return "(...)";
	}
}

function printCode(exprs: Array<Expr>, prefix: String) {
	if(exprs.length == 0) return "";

	return exprs.joinMap('.\n', e -> prefix + e.print(prefix));
}