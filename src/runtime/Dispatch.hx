package runtime;

@:publicFields
class NLR {
	final value: Object;
	final receiver: Object;

	function new(value: Object, receiver: Object) {
		this.value = value;
		this.receiver = receiver;
	}
}

@:build(util.Overload.build())
@:publicFields
class Dispatch {
	static overload inline function sendMessage(receiver: Object, message: String, args: Array<Object>, env: Object, indent: Int = 0) {
		return sendMessage(receiver, receiver, message, args, env, indent);
	}

	static overload function sendMessage(lookupStart: Object, receiver: Object, message: String, args: Array<Object>, env: Object, indent: Int = 0) {
		if(Globals.msgTrace) {
			final str = " ".repeat(indent);
			final subStr = '$str    ';

			Sys.println('${str}sending $message');
			Sys.println('${subStr}rcvr: ${receiver.print('$subStr      ')}');
			for(arg in args) Sys.println('${subStr}arg: ${arg.print('$subStr      ')}');
		}

		detuple(@final [foundIn, slot] = try {
			lookupSlot(lookupStart, message);
		} catch(err: String) {
			throw '$err; receiver: ${receiver.print("")}';
		});

		final result = applyToArgs(slot, receiver, args, foundIn, env);

		if(Globals.msgTrace) {
			final str = " ".repeat(indent + 2);
			
			Sys.println('${str}returning ${result.print('$str      ')}');
		}

		return result;
	}


	static overload function lookupSlot(obj: Object, name: String) {
		return lookupSlot(obj, name, []);
	}

	static overload function lookupSlot(obj: Object, name: String, cache: Array<Object>): Tuple2<Object, Slot> {
		if(cache.contains(obj)) throw 'message "$name" not found';

		cache.push(obj);

		obj.getSlot(name)._andOr(slot => {
			return tuple(obj, slot);
		}, {
			final lookups = [];

			for(slot in obj.slots) {
				if(slot.isParent) {
					lookupSlot(slot.getContents().nonNull(), name, cache)._and(found => {
						lookups.push(found);
					});
				}
			}

			lookups._match(
				at([]) => throw 'message "$name" not found',
				at([found]) => return found,
				_ => throw 'message "$name" ambiguous'
			);
		});
	}


	static overload function applyToArgs(slot: Slot, receiver: Object, args: Array<Object>, foundIn: Object, env: Object) {
		return slot._match(
			at(s is ObjectSlot) => applyToArgs(s, receiver, args, foundIn, env),
			at(s is ArgSlot) => applyToArgs(s, receiver, args, foundIn, env),
			at(s is AssignmentPrimitiveSlot) => applyToArgs(s, receiver, args, foundIn, env),
			_ => throw "bad"
		);
	}

	static overload function applyToArgs(slot: ObjectSlot, receiver: Object, args: Array<Object>, foundIn: Object, env: Object) {
		final contents = slot.contents;
		if(contents.exprs.length == 0) {
			return contents;
		} else {
			final activationRecord = contents.clone();

			final argSlots = activationRecord.slots.filterMap(slot -> slot._match(
				at(s is ArgSlot) => s,
				_ => null
			));
			argSlots._for(i => slot, {
				slot.contents = args[i];
			});

			// Check if this is a method
			if(!activationRecord.hasSlot("_lexicalParent")) {
				activationRecord.prependSlot(({
					name: "self",
					isParent: true,
					contents: receiver
				} : ArgSlot));

				final nlr: NLRClosureObject = {
					slots: [],
					closure: (obj) -> throw new NLR(obj, receiver)
				};

				activationRecord.prependSlot(({
					name: "_nlr",
					contents: nlr
				} : ArgSlot));
			}
			
			try {
				return Eval.evalExprs(activationRecord.exprs, activationRecord);
			} catch(nlr: NLR) {
				// Make sure we are returning to the current method
				if(nlr.receiver == receiver) {
					return nlr.value;
				} else {
					throw nlr;
				}
			} catch(e: haxe.ValueException) {
				activationRecord.prependOrReplaceSlot(({
					name: "_nlr",
					contents: ({
						slots: [],
						closure: (obj) -> {
							throw "Cannot do a non-local return after the enclosing method has returned";
						}
					} : NLRClosureObject)
				} : ArgSlot));

				throw e;
			}
		}
	}

	static overload function applyToArgs(slot: ArgSlot, receiver: Object, args: Array<Object>, foundIn: Object, env: Object) {
		slot.contents._andOr(contents => {
			return contents;
		}, {
			trace(slot.print(""));
			throw "Expecting argument slot to be filled in by now";
		});
	}

	static overload function applyToArgs(slot: AssignmentPrimitiveSlot, receiver: Object, args: Array<Object>, foundIn: Object, env: Object) {
		final dataSlotName = slot.name.removeTrailing(":");

		foundIn.getSlot(dataSlotName)._andOr(dataSlot => {
			dataSlot.setContents(args[0]);
			return receiver;
		}, {
			throw "didn't find the corresponding data slot!";
		});
	}
}