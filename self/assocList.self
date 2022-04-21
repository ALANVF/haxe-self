"This file defines a keyed table data structure"

globals _AddSlotsIfAbsent: (|
    assocListTraits = ( ).
|).
assocListTraits _DefineSlots: (|
    parent* = objectTraits.

    "define this internal 'struct'"
    assoc = (| parent* = objectTraits. key. value. next. |).

    "invoke aBlock on each assoc in the list"
    assocsDo: aBlock = (
        |assoc|
        assoc: head.
        [assoc !== nil] whileTrue: [
            aBlock value: assoc. assoc: assoc next. ]).

    "invoke aBlock on each key and value in the list"
    keysAndValuesDo: aBlock = (
        assocsDo: [|:assoc|
            aBlock value: assoc key With: assoc value] ).

    "return the number of elements in the assoc list"
    length = ( | count <- 0 | assocsDo: [ |:elem| count: count + 1. ]. count ).

    "return whether the association list is empty"
    isEmpty = ( head == nil ).

    "return the value associated with key k, or if none, 
     invoke absentBlock and return the result"
    at: k IfAbsent: absentBlock = (
        keysAndValuesDo: [|:key. :value.|
            key = k ifTrue: [^ value].
        ].
        absentBlock value ).

    "return the value associated with key k"
    at: k = ( at: k IfAbsent: [ absentError: k ] ).

    "change key k to map to value v, or add a k->v association
     if k not already in the list.  return the assoc list."
    at: k Put: v = (
        assocsDo: [|:assoc|
            assoc key = k ifTrue: [
                assoc value: v. 
                ^self
            ].
        ].
        head: ((assoc clone key: k) value: v) next: head. ).

    "printing behavior for assoc lists"
    printString = (
        | str <- 'assocList{'. first <- true. |
        keysAndValuesDo: [|:key. :value.| 
            first ifTrue: [ first: false ] False: [ str: str + ', '. ].
            str: str + key printString + '->' + value printString. ].
        str + '}' ).

    "error messages"
    absentError: k = (
        ('key ' + k printString + ' not found in ' + printString) error ).
|).

globals _AddSlotsIfAbsent: (|
    assocListProto = ( ).
|).
assocListProto _DefineSlots: (|
    parent* = assocListTraits.
    head.
|).