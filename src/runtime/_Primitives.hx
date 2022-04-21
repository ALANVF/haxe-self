package runtime;

// This is in a separate file due to weird macro bugs

macro function addPrim(name: String, args, body) {
	return macro
		PRIMS[$v{name}] = function(args: Array<Object>, env: Object): Object {
			Util._match(args,
				at($args) => $body,
				_ => return cast untyped invalidArgs($v{name}, args) // Haxe doesn't have a "Never" type, so this is the best alternative
			);
		};
}