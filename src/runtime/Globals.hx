package runtime;

final globalEnv: Object = {slots: []};
final intParent: Object = {slots: []};
final floatParent: Object = {slots: []};
final stringParent: Object = {slots: []};
final blockParent: Object = {slots: []};
final nilObject: Object = {slots: []};

var msgTrace: Bool = false;
var inputTrace: Bool = false;

function build() {
	final globals: Object = {slots: []};

	globalEnv.addSlot(({name: "globals", isParent: true, contents: globals} : ObjectSlot));

	globals.addSlot(({name: "intTraits", contents: intParent} : ObjectSlot));
	globals.addSlot(({name: "floatTraits", contents: floatParent} : ObjectSlot));
	globals.addSlot(({name: "stringTraits", contents: stringParent} : ObjectSlot));
	globals.addSlot(({name: "blockTraits", contents: blockParent} : ObjectSlot));
	globals.addSlot(({name: "nil", contents: nilObject} : ObjectSlot));
}