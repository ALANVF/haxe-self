package runtime;

import runtime._Primitives.addPrim;
import runtime.Dispatch.sendMessage;

function invalidArgs(name: String, args: Array<Object>) {
	throw 'Invalid arguments for primitive $name(${args.joinMap(", ", a -> a.print(""))})';
}

final PRIMS: Map<String, Closure> = [];

function build() {
	addPrim("_ObjEQ:True:False:", [arg1, arg2, trueObj, falseObj], {
		if(arg1 == arg2) return trueObj
		else return falseObj;
	});
	addPrim("_ObjNE:True:False:", [arg1, arg2, trueObj, falseObj], {
		if(arg1 != arg2) return trueObj
		else return falseObj;
	});

	addPrim("_ObjPrint", [obj], {
		Sys.println(obj.print(""));
		return obj;
	});

	addPrim("_ObjPrintString", [obj], {
		return StringObject.make(obj.print("").toBytes());
	});

	addPrim("_Clone", [obj], {
		return obj.clone();
	});

	addPrim("_Loop", [obj], {
		while(true) {
			sendMessage(obj, "value", [], env);
		}
		return untyped null;
	});

	addPrim("_DefineSlots:", [obj, slotsObj], {
		obj.slots.splice(0, obj.slots.length); // clear slots
		for(slot in slotsObj.slots) {
			obj.addSlot(slot.clone());
		}
		return obj;
	});

	addPrim("_AddSlots:", [obj, slotsObj], {
		for(slot in slotsObj.slots) {
			obj.addOrReplaceSlot(slot.clone());
		}
		return obj;
	});

	addPrim("_AddSlotsIfAbsent:", [obj, slotsObj], {
		for(slot in slotsObj.slots) {
			if(!obj.hasSlot(slot.name)) {
				obj.addSlot(slot.clone());
			}
		}
		return obj;
	});

	addPrim("_TraceOn", [obj], {
		Globals.msgTrace = true;
		return obj;
	});
	addPrim("_TraceOff", [obj], {
		Globals.msgTrace = false;
		return obj;
	});

	addPrim("_InputTraceOn", [obj], {
		Globals.inputTrace = true;
		return obj;
	});
	addPrim("_InputTraceOff", [obj], {
		Globals.inputTrace = false;
		return obj;
	});


	// Int prims

	addPrim("_IntNeg", [int is IntObject], {
		return IntObject.make(-int.value);
	});
	addPrim("_IntAdd:", [int1 is IntObject, int2 is IntObject], {
		return IntObject.make(int1.value + int2.value);
	});
	addPrim("_IntSub:", [int1 is IntObject, int2 is IntObject], {
		return IntObject.make(int1.value - int2.value);
	});
	addPrim("_IntMul:", [int1 is IntObject, int2 is IntObject], {
		return IntObject.make(int1.value * int2.value);
	});
	addPrim("_IntDiv:", [int1 is IntObject, int2 is IntObject], {
		if(int2.value == 0) throw "Divide by zero";
		return IntObject.make(Std.int(int1.value / int2.value));
	});
	addPrim("_IntMod:", [int1 is IntObject, int2 is IntObject], {
		if(int2.value == 0) throw "Modulo by zero";
		return IntObject.make(int1.value % int2.value);
	});

	addPrim("_IntAsFloat", [int is IntObject], {
		return FloatObject.make(cast int.value);
	});

	addPrim("_IntEQ:True:False:", [int1 is IntObject, int2 is IntObject, trueObj, falseObj], {
		return if(int1.value == int2.value) trueObj else falseObj;
	});
	addPrim("_IntNE:True:False:", [int1 is IntObject, int2 is IntObject, trueObj, falseObj], {
		return if(int1.value != int2.value) trueObj else falseObj;
	});
	addPrim("_IntLT:True:False:", [int1 is IntObject, int2 is IntObject, trueObj, falseObj], {
		return if(int1.value < int2.value) trueObj else falseObj;
	});
	addPrim("_IntLE:True:False:", [int1 is IntObject, int2 is IntObject, trueObj, falseObj], {
		return if(int1.value <= int2.value) trueObj else falseObj;
	});
	addPrim("_IntGT:True:False:", [int1 is IntObject, int2 is IntObject, trueObj, falseObj], {
		return if(int1.value > int2.value) trueObj else falseObj;
	});
	addPrim("_IntGE:True:False:", [int1 is IntObject, int2 is IntObject, trueObj, falseObj], {
		return if(int1.value >= int2.value) trueObj else falseObj;
	});

	addPrim("_IntPrint", [int is IntObject], {
		Sys.print(int.value);
		return int;
	});


	// Float prims
	
	addPrim("_FloatNeg", [float is FloatObject], {
		return FloatObject.make(-float.value);
	});
	addPrim("_FloatAdd:", [float1 is FloatObject, float2 is FloatObject], {
		return FloatObject.make(float1.value + float2.value);
	});
	addPrim("_FloatSub:", [float1 is FloatObject, float2 is FloatObject], {
		return FloatObject.make(float1.value - float2.value);
	});
	addPrim("_FloatMul:", [float1 is FloatObject, float2 is FloatObject], {
		return FloatObject.make(float1.value * float2.value);
	});
	addPrim("_FloatDiv:", [float1 is FloatObject, float2 is FloatObject], {
		if(float2.value == 0) throw "Divide by zero";
		return FloatObject.make(float1.value / float2.value);
	});
	addPrim("_FloatMod:", [float1 is FloatObject, float2 is FloatObject], {
		if(float2.value == 0) throw "Modulo by zero";
		return FloatObject.make(float1.value % float2.value);
	});

	addPrim("_FloatAsInt", [float is FloatObject], {
		return IntObject.make(Std.int(float.value));
	});

	addPrim("_FloatFloor", [float is FloatObject], {
		return FloatObject.make(Math.ffloor(float.value));
	});
	addPrim("_FloatCeil", [float is FloatObject], {
		return FloatObject.make(Math.fceil(float.value));
	});
	addPrim("_FloatRound", [float is FloatObject], {
		return FloatObject.make(Math.fround(float.value));
	});
	addPrim("_FloatTruncate", [float is FloatObject], {
		return FloatObject.make(cast Std.int(float.value));
	});

	addPrim("_FloatEQ:True:False:", [float1 is FloatObject, float2 is FloatObject, trueObj, falseObj], {
		return if(float1.value == float2.value) trueObj else falseObj;
	});
	addPrim("_FloatNE:True:False:", [float1 is FloatObject, float2 is FloatObject, trueObj, falseObj], {
		return if(float1.value != float2.value) trueObj else falseObj;
	});
	addPrim("_FloatLT:True:False:", [float1 is FloatObject, float2 is FloatObject, trueObj, falseObj], {
		return if(float1.value < float2.value) trueObj else falseObj;
	});
	addPrim("_FloatLE:True:False:", [float1 is FloatObject, float2 is FloatObject, trueObj, falseObj], {
		return if(float1.value <= float2.value) trueObj else falseObj;
	});
	addPrim("_FloatGT:True:False:", [float1 is FloatObject, float2 is FloatObject, trueObj, falseObj], {
		return if(float1.value > float2.value) trueObj else falseObj;
	});
	addPrim("_FloatGE:True:False:", [float1 is FloatObject, float2 is FloatObject, trueObj, falseObj], {
		return if(float1.value >= float2.value) trueObj else falseObj;
	});

	addPrim("_FloatPrint", [float is FloatObject], {
		Sys.print(float.value);
		return float;
	});


	// String prims

	addPrim("_StringConcat:", [str1 is StringObject, str2 is StringObject], {
		final val1 = str1.value;
		final val2 = str2.value;
		final res = haxe.io.Bytes.alloc(val1.length + val2.length);

		res.blit(0, val1, 0, val1.length);
		res.blit(val1.length, val2, 0, val2.length);

		return StringObject.make(res);
	});

	addPrim("_StringEQ:True:False:", [str1 is StringObject, str2 is StringObject, trueObj, falseObj], {
		return if(str1.value.compare(str2.value) == 0) trueObj else falseObj;
	});
	addPrim("_StringNE:True:False:", [str1 is StringObject, str2 is StringObject, trueObj, falseObj], {
		return if(str1.value.compare(str2.value) != 0) trueObj else falseObj;
	});
	addPrim("_StringLT:True:False:", [str1 is StringObject, str2 is StringObject, trueObj, falseObj], {
		return if(str1.value.compare(str2.value) < 0 ) trueObj else falseObj;
	});
	addPrim("_StringLE:True:False:", [str1 is StringObject, str2 is StringObject, trueObj, falseObj], {
		return if(str1.value.compare(str2.value) <= 0) trueObj else falseObj;
	});
	addPrim("_StringGT:True:False:", [str1 is StringObject, str2 is StringObject, trueObj, falseObj], {
		return if(str1.value.compare(str2.value) > 0) trueObj else falseObj;
	});
	addPrim("_StringGE:True:False:", [str1 is StringObject, str2 is StringObject, trueObj, falseObj], {
		return if(str1.value.compare(str2.value) >= 0) trueObj else falseObj;
	});

	addPrim("_StringPrint", [str is StringObject], {
		Sys.print(str.value.toString());
		return str;
	});

	addPrim("_StringLength", [str is StringObject], {
		return IntObject.make(str.value.length);
	});
	addPrim("_StringAt:IfOutOfBounds:", [str is StringObject, index is IntObject, outOfBounds], {
		if(0 <= index.value && index.value < str.value.length) {
			return StringObject.make(str.value.sub(index.value, 1));
		} else {
			return sendMessage(outOfBounds, "value", [], env);
		}
	});
	addPrim("_StringAt:Put:IfOutOfBounds:", [str is StringObject, index is IntObject, char is StringObject, outOfBounds], {
		if(0 <= index.value && index.value < str.value.length) {
			if(char.value.length == 1) {
				str.value.set(index.value, char.value.get(0));
				return str;
			} else {
				throw "Storing a string that isn't one character long";
			}
		} else {
			return sendMessage(outOfBounds, "value", [], env);
		}
	});

	addPrim("_StringIncludeFile", [filename is StringObject], {
		return Eval.evalFile(filename.value.toString());
	});

	addPrim("_StringError", [str is StringObject], {
		throw str.value.toString();
	});
}