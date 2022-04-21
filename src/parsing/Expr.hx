package parsing;

import haxe.io.Bytes;

@:using(parsing.Expr)
enum Expr {
	EInt(int: Int);
	EFloat(float: Float);
	EString(string: Bytes);
	EObject(isBlock: Bool, slots: Array<Slot>, exprs: Array<Expr>);
	
	EImplicitSelf;

	EUnaryMsg(receiver: Expr, name: String);
	EBinaryMsg(receiver: Expr, name: String, arg: Expr);
	EKeywordMsg(receiver: Expr, name: String, keywords: Array<String>, args: Array<Expr>);

	ENonLocalReturn(expr: Null<Expr>);
}

function print(self: Expr, prefix: String) return self._match(
	at(EInt(int)) => '$int',
	at(EFloat(float)) => '$float',
	at(EString(string)) => string.toString().escape(false, true).quoteSingle(),
	
	at(EObject(false, [], [])) => "( )",
	at(EObject(false, slots, exprs)) => "( " + Slot.printSlots(slots, prefix)
										+ (slots.length != 0 && exprs.length != 0 ? '\n$prefix  ' : "")
										+ printExprs(exprs, prefix) + ")",
	
	at(EObject(true, [], [])) => "[ ]",
	at(EObject(true, slots, exprs)) => "[ " + Slot.printSlots(slots, prefix)
										+ (slots.length != 0 && exprs.length != 0 ? '\n$prefix  ' : "")
										+ printExprs(exprs, prefix) + "]",

	at(EImplicitSelf) => "self",
	
	at(EUnaryMsg(receiver, name)) => receiver.print(prefix) + ' $name',
	at(EBinaryMsg(receiver, name, arg)) => receiver.print(prefix) + ' $name ' + arg.print(prefix),
	at(EKeywordMsg(receiver, _, keywords, args)) => (
		receiver.print(prefix) + keywords.zip(args, (k, a) -> ' $k ' + a.print(prefix)).join("")
	),

	at(ENonLocalReturn(null)) => "^",
	at(ENonLocalReturn(expr!!)) => "^ " + expr.print(prefix)
);

function printExprs(exprs: Array<Expr>, prefix: String) {
	if(exprs.length == 0) return "";

	return exprs.joinMap('.\n$prefix', e -> e.print(prefix)) + " ";
}