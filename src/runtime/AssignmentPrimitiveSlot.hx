package runtime;

@:structInit
@:publicFields
class AssignmentPrimitiveSlot extends Slot {
	override function new(name: String, isParent: Bool = false) {
		inline super(name, isParent);
	}

	function clone(): AssignmentPrimitiveSlot {
		return {
			name: name,
			isParent: isParent
		};
	}

	function print(prefix: String) {
		return '$name = <-';
	}
}