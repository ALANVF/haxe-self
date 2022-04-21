package parsing;

@:using(parsing.Slot)
enum Slot {
	SUninitialized(name: String, isParent: Bool);
	SInitialized(name: String, isParent: Bool, contents: Expr, isMutable: Bool);
	SMethod(name: String, labels: Array<String>, names: Array<String>, contents: Expr);
	SArgument(name: String);
}

function print(self: Slot, prefix: String) return self._match(
	at(SUninitialized(name, false)) => name,
	at(SUninitialized(name, true)) => '$name*',
	
	at(SInitialized(name, false, contents, false)) => '$name = ' + contents.print(prefix),
	at(SInitialized(name, false, contents, true)) => '$name <- ' + contents.print(prefix),
	at(SInitialized(name, true, contents, false)) => '$name* = ' + contents.print(prefix),
	at(SInitialized(name, true, contents, true)) => '$name* <- ' + contents.print(prefix),

	at(SMethod(_, labels, names, contents)) => labels.zip(names, (l, n) -> '$l $n ').join("") + "= " + contents.print(prefix),

	at(SArgument(name)) => ':$name'
);

function printSlots(slots: Array<Slot>, prefix: String) {
	if(slots.length == 0) return "";

	prefix += "  ";

	return "| " + slots.joinMap('.\n$prefix', s -> s.print(prefix)) + " | ";
}