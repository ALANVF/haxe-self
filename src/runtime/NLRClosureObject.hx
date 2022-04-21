package runtime;

@:structInit
class NLRClosureObject extends Object {
	final closure: (obj: Object) -> Object;

	static inline function make(slots: Array<Slot>, closure: (obj: Object) -> Object): NLRClosureObject {
		return {
			slots: slots,
			closure: closure
		};
	}

	override function clone(): NLRClosureObject {
		return {
			slots: slots.map(s -> s.clone()),
			closure: closure
		};
	}

	override function print(prefix: String) {
		return "<nlr closure>";
	}
}