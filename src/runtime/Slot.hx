package runtime;

@:publicFields
abstract class Slot {
	var name: String;
	var isParent: Bool = false;

	function new(name: String, isParent: Bool = false) {
		this.name = name;
		this.isParent = isParent;
	}

	abstract function clone(): Slot;

	function getContents(): Null<Object> {
		return null;
	}

	function setContents(value: Object) {
		throw "No contents to set";
	}

	abstract function print(prefix: String): String;
}

function printSlots(slots: Array<Slot>, prefix: String) {
	if(slots.length == 0) return "";

	prefix += "  ";

	return "| " + slots.joinMap('.\n$prefix', s -> s.print(prefix)) + " | ";
}

function numArgSlots(slots: Array<Slot>) {
	return slots.count(s -> s is ArgSlot);
}