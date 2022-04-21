package runtime;

@:structInit
@:publicFields
class ArgSlot extends Slot {
	var contents: Null<Object> = null;

	override function new(name: String, isParent: Bool = false, contents: Null<Object> = null) {
		inline super(name, isParent);
		this.contents = contents;
	}

	function clone(): ArgSlot {
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
		return contents._andOr(
			c => ':$name = ' + c.printShort(),
			':$name'
		);
	}
}