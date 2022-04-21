package runtime;

import lexing.Lexer;
import parsing.Parser;
import parsing.Expr;
import parsing.Slot as SlotExpr;

@:publicFields
class Eval {
	static function eval(expr: Expr, env: Object): Object return expr._match(
		at(EInt(int)) => IntObject.make(int),
		at(EFloat(float)) => FloatObject.make(float),
		at(EString(string)) => StringObject.make(string),
		at(EObject(false, slots, exprs)) => {
			final slots2 = evalSlots(slots, env);

			if(Slot.numArgSlots(slots2) > 0) {
				throw "Unexpected argument slots";
			}

			if(exprs.length > 0) {
				slots2.unshift(({
					name: "_lexicalParent",
					isParent: true,
					contents: env
				} : ObjectSlot));

				final nestedEnv = Object.make(slots2);

				evalExprs(exprs, nestedEnv);
			} else {
				Object.make(slots2);
			}
		},
		at(EObject(true, slots, exprs)) => {
			final slots2 = evalSlots(slots, env);

			BlockObject.make(slots2, exprs, env);
		},
		at(EImplicitSelf) => {
			try {
				Dispatch.sendMessage(env, "self", [], env);
			} catch(_: String) {
				Globals.globalEnv;
			}
		},
		at(EUnaryMsg(receiver, name)) => evalMsg(receiver, name, [], env),
		at(EBinaryMsg(receiver, name, arg)) => evalMsg(receiver, name, [arg], env),
		at(EKeywordMsg(receiver, name, _, args)) => evalMsg(receiver, name, args, env),
		at(ENonLocalReturn(expr)) => {
			final result = expr._andOr(
				expr => eval(expr, env),
				Globals.nilObject
			);

			final nlrObj = Dispatch.sendMessage(env, "_nlr", [], env)._or(
				throw "Cannot invoke a non-local return outside a method"
			);
			
			final nlr = nlrObj._match(
				at(obj is NLRClosureObject) => obj,
				_ => throw "Expecting _nlr to hold an NLRClosureObject"
			);

			return nlr.closure(result);
		}
	);


	static function evalMsg(receiver: Expr, name: String, args: Array<Expr>, env: Object) {
		final receiver2 = eval(receiver, env);
		final args2 = args.map(a -> eval(a, env));

		if(name.startsWith("_")) {
			args2.unshift(receiver2);
			Primitives.PRIMS[name]._andOr(prim => {
				return prim(args2, env);
			}, {
				throw 'Undefined primitive $name(${args2.joinMap(", ", a -> a.print(""))})';
			});
		} else {
			final lookupStart = if(receiver.match(EImplicitSelf)) env else receiver2;

			return Dispatch.sendMessage(lookupStart, receiver2, name, args2, env);
		}
	}


	static function evalSlot(slot: SlotExpr, slots: Array<Slot>, env: Object) slot._match(
		at(SUninitialized(name, isParent)) => {
			slots.push(({
				name: name,
				isParent: isParent,
				contents: Globals.nilObject
			} : ObjectSlot));
			slots.push(({
				name: '$name:'
			} : AssignmentPrimitiveSlot));
		},
		at(SInitialized(name, isParent, contents, isMutable)) => {
			final rhs = evalSlotContents(contents, env);
			final numArgs = name.charCodeAt(0)._match(
				at(('a'.code ... 'z'.code) | '_'.code) => name.countMatches(":"),
				_ => 1
			);
			if(numArgs != rhs.numArgSlots()) {
				throw 'Unexpected number of argument slots $name $numArgs ${rhs.numArgSlots()}';
			}

			slots.push(({
				name: name,
				isParent: isParent,
				contents: rhs
			} : ObjectSlot));
			
			if(isMutable) {
				slots.push(({
					name: '$name:'
				} : AssignmentPrimitiveSlot));
			}
		},
		at(SMethod(name, labels, names, contents)) => {
			final method = evalSlotContents(contents, env);
			if(method.numArgSlots() > 0) {
				throw "Unexpected argument slots in method rhs";
			}

			var i = names.length - 1;
			while(i >= 0) { final name = names[i];
				method.prependSlot(({
					name: name
				} : ArgSlot));
			i--; }

			slots.push(({
				name: name,
				contents: method
			} : ObjectSlot));
		},
		at(SArgument(name)) => {
			slots.push(({
				name: name
			} : ArgSlot));
		}
	);


	static function evalSlotContents(expr: Expr, env: Object) return expr._match(
		at(EObject(false, slots, exprs)) => {
			final slots2 = evalSlots(slots, env);

			Object.make(slots2, exprs);
		},
		_ => eval(expr, env)
	);


	static function evalSlots(slotExprs: Array<SlotExpr>, env: Object) {
		final slots: Array<Slot> = [];

		for(slotExpr in slotExprs) {
			evalSlot(slotExpr, slots, env);
		}

		return slots;
	}


	static function evalExprs(exprs: Array<Expr>, env: Object) {
		var result = Globals.nilObject;

		for(expr in exprs) {
			result = eval(expr, env);
		}

		return result;
	}


	static inline function evalFile(filename: String) {
		return evalCode(sys.io.File.getContent(filename));
	}

	static function evalCode(code: String) {
		final lexer = new Lexer(code);
		final tokens = lexer.tokenize();
		final exprs = Parser.parse(tokens);

		return evalExprs(exprs, Globals.globalEnv);
	}
}