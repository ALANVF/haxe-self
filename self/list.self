"This file defines a linked-list ADT.  See the end of the file for
examples of use."

"the ancestor of all lists"
globals _AddSlotsIfAbsent: ( |
  listTraits = ( ).
| ).
listTraits _DefineSlots: ( |
  parent* = collectionTraits.

  "create and return a new list whose first element is the argument
   and whose tail list is the receiver"
  addToFront: newFirst = (
    (consProto clone first: newFirst) rest: self ).

  "evaluate aBlock on each element in the list"
  do: aBlock = (
    | link |
    link: self.
    [link isEmpty] whileFalse: [ 
      aBlock value: link first. 
      link: link rest. ].
    self ).

  "update the element that's at position index (base 0) in the
   receiver list to be newValue, or invoke outOfBoundsBlock and return
   its result if the index is out of bounds"
  at: index Put: newValue IfOutOfBounds: outOfBoundsBlock = (
    | link. pos <- 0. |
    index >= 0 ifTrue: [
      link: self.
      [link isEmpty] whileFalse: [ 
        pos = index ifTrue: [
          "we found the right link to update"
          link first: newValue.
          ^ self
        ].
        "keep scanning"
        link: link rest.
        pos: pos + 1.
      ].
    ].
    "the index was out of bounds"
    outOfBoundsBlock value ).

  "remove the given element from the list (if it exists), using = to
   compare elements; return the possibly updated new head of the list"
  remove: elem = (
    remove: elem IfAbsent: [self] ).

  "remove the given element from the list (if it exists), using = to
   compare elements; return the possibly updated new head of the list.
   if the element does not exist in the list, then invoke absentBlock
   and return its result"
  remove: elem IfAbsent: absentBlock = (
    | prev. link. |
    link: self.
    [link isEmpty] whileFalse: [
      elem = link first ifTrue: [
        "we found the element to remove"
        prev isEmpty ifTrue: [
          "we're removing the first link; just return the rest of the list"
          ^ link rest
        ] False: [
          "we're removing an interior list element.  splice it out,
           then return the original receiver"
          prev rest: link rest.
          ^ self
        ].
      ].
      "keep looking"
      prev: link.
      link: link rest.
    ].
    "didn't find the elememt to remove"
    absentBlock value ).

  "printing behavior for lists"
  printString = (
    | str <- 'list{'. first <- true. |
    do: [|:elem| 
      first ifTrue: [ first: false ] False: [ str: str + ', '. ].
      str: str + elem printString. ].
    str + '}' ).

  "catch a potential infinite recursion, if the child doesn't implement 
   this method"
  isEmpty = ( 'child should implement isEmpty' error ).
| ).

"the parent of cons cells"
globals _AddSlotsIfAbsent: ( |
  consTraits = ( ).
| ).
consTraits _DefineSlots: ( |
  parent* = listTraits.

  isEmpty = false.
| ).

"the prototypical cons cell, 'hidden' inside the listTraits object so
 that it's less visible to the rest of the world"
listTraits _AddSlots: ( |
  consProto = ( |
    parent* = consTraits.
    first.
    rest.
  | ).
| ).

"update nil with behavior to act like the empty list"
nil _AddSlots: ( |
  parent* = listTraits.

  "put empty-list operations here"

  isEmpty = true.
| ).

"add public operations to all objects"
objectTraits _AddSlots: ( |
  "create a new list which is the receiver element followed by the
   argument list"
  cons: rest = ( rest addToFront: self ).
| ).


"singly linked lists are bad at adding to the end.  so to construct a
list in left-to-right order, define this helper object that allows
constant-time adding to the end of the list.  see map: in
collection.self for a simple use"

globals _AddSlotsIfAbsent: ( |
  listBuilderTraits = ( ).
| ).
listBuilderTraits _DefineSlots: ( |
  parent* = objectTraits.

  "allow adding to the front and back of the list being built"
  addToFront: elem = ( 
    list: list addToFront: elem.
    last isEmpty ifTrue: [ last: list. ]. ).

  addToBack: elem = (
    last isEmpty 
      ifTrue: [ addToFront: elem ]
       False: [ | newLast |
         newLast: elem cons: nil.
         last rest: newLast.
         last: newLast. ] ).
| ).

globals _AddSlotsIfAbsent: ( |
  listBuilder = ( ).
| ).
listBuilder _DefineSlots: ( |
  parent* = listBuilderTraits.

  "send 'list' to get the list object that's been built"
  list.

  "key idea: builder keeps track of the last cons cell in the list"
  last.
| ).


"Here are some examples of how to use lists:

nil is the empty list.

To add to the front of a list, send cons: to the element with the rest
of the list as an argument (assuming the element object inherits from
objectTraits).  Alternatively, you can send addToFront: to the rest of
the list with the new element as the argument.  E.g.:

_AddSlots: (| lst1. lst2. |)

lst1: 3 cons: (4 cons: (5 cons: nil))

lst1
  -> list{3, 4, 5}


lst2: ((nil addToFront: 5) addToFront: 4) addToFront: 3.

lst2
  -> list{3, 4, 5}


Given a list, you can iterate through its elements using do:

lst1 do: [|:elem| elem print. ' ' print. ]. '' printLine.
  -> 3 4 5

nil do: [|:elem| elem print. ' ' print. ]. '' printLine.
  ->


You also can iterate through the pairs of its indexes and elements
using doWithIndexes: (the first element is at index 0):

lst1 doWithIndexes: [|:index. :elem.| 
         index print. ':' print. elem print. ' ' print. ]. '' printLine.
  -> 0:3 1:4 2:5


You can query the length of a list using length, and test whether a
list is empty using isEmpty:

lst1 length
  -> 3
lst1 isEmpty
  -> false

nil length
  -> 0
nil isEmpty
  -> true


You can also look up an element at a given index in the list using
at:

lst1 at: 0
  -> 3

lst1 at: 2
  -> 5

lst1 at: 5
  -> Eval error: index 5 out of bounds in list{3, 4, 5}

lst1 at: -1
  -> Eval error: index -1 out of bounds in list{3, 4, 5}


You can alternatively use at:IfOutOfBounds: to pass a block argument
which will be invoked and its result returned if the index is out of
bounds:

lst1 at: 1 IfOutOfBounds: ['out of bounds']
  -> 4

lst1 at: 5 IfOutOfBounds: ['out of bounds']
  -> 'out of bounds'


You can change the element at a given index in the list using at:Put:
(this changes the receiver list in place):

lst1 at: 1 Put: 14
  -> list{3, 14, 5}

lst1 at: 5 Put: 100
  -> Eval error: index 5 out of bounds in list{3, 14, 5}

You can alternatively use at:Put:IfOutOfBounds: to pass a block
argument which will be invoked and its result returned if the index is
out of bounds:

lst1 at: 2 Put: 15 IfOutOfBounds: ['out of bounds']
  -> list{3, 14, 15}

lst1 at: 5 Put: 100 IfOutOfBounds: ['out of bounds']
  -> 'out of bounds'


You can invoke mapBy: to build a new list which is the result of
invoking its argument block on each element of its receiver list (the
original list is unchanged):

lst1 mapBy: [|:elem| elem+1]
  -> list{4, 15, 16}


Lists are easy to build right-to-left (using cons: or addToFront:),
but not the other way.  As a helper when building lists left-to-right,
the listBuilder object can help.  'listBuilder clone' constructs a new
list builder, initially holding an empty list.  Then addToFront: and
addToBack: can be sent to the list builder to add elements to the
front or back of the list being build.  Finally, list can be sent to
the list builder to get the list that was built.  For example:

_AddSlots: (| builder |).

builder: listBuilder clone.

builder addToFront: 3.
builder addToBack: 4.
builder addToFront: 2.
builder addToBack: 5.
builder addToBack: 6.

builder list
  -> list{2, 3, 4, 5, 6}

"