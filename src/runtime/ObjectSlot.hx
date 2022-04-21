package runtime;

@:structInit
@:publicFields
class ObjectSlot extends Slot {
	var contents: Object;

	override function new(name: String, isParent: Bool = false, contents: Object) {
		inline super(name, isParent);
		this.contents = contents;
	}

	function clone(): ObjectSlot {
		return {
			name: name,
			isParent: isParent,
			contents: contents
		};
	}

	override function getContents() {
		return contents;
	}

	override function setContents(value: Object) {
		contents = value;
	}

	function print(prefix: String) {
		return (isParent ? '$name* = ' : '$name = ') + contents.printShort();
	}
}