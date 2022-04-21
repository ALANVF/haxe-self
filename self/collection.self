"This file defines shared operations for all collection-like data structures"

globals _AddSlotsIfAbsent: ( |
  collectionTraits = ( ).
| ).
collectionTraits _DefineSlots: ( |
  parent* = objectTraits.

"iteration operations"

  "the following operations should be defined for all concrete children"
    "do: aBlock"

  "iterate through all the indexes and elements of the collection"
  doWithIndexes: aBlock = (
    | index <- 0. |
    do: [ |:elem| aBlock value: index With: elem. index: index + 1. ] ).

"length testing operations"

  "return the number of elements in the collection"
  "(a default implementation in terms of do:"
  length = ( | count <- 0 | do: [ |:elem| count: count + 1. ]. count ).

  "a default implementation of isEmpty in terms of length"
  isEmpty = ( length = 0 ).

"indexing operations"

  "return the element that's at position index (base 0) in the
   receiver collection"
  at: index = ( 
    at: index IfOutOfBounds: [ outOfBoundsError: index ] ).

  "a default implementation in terms of do:"
  at: index IfOutOfBounds: outOfBoundsBlock = (
    index >= 0 ifTrue: [
      doWithIndexes: [ |:pos. :elem.|
        pos = index ifTrue: [^ elem].
      ].
    ].
    outOfBoundsBlock value ).

  "update the element that's at position index (base 0) in the
   receiver collection to be newValue"
  at: index Put: newValue = ( 
    at: index Put: newValue IfOutOfBounds: [
      outOfBoundsError: index ] ).

  "all concrete children should implement at:Put:IfOutOfBounds: (if
   they wish to support at:Put:)"

"functionals"

  "map"
  mapBy: aBlock = (
    | builder |
    builder: listBuilder clone.
    do: [|:elem| builder addToBack: aBlock value: elem.].
    builder list ).

"misc operations"

  "error messages"
  outOfBoundsError: index = (
    ('index ' + index printString + ' out of bounds in ' + printString) 
       error ).
| ).


"extend strings to work as a kind of collection"
stringTraits _AddSlots: ( |
  "change the parent to the collection traits object"
  parent* = collectionTraits.

  do: aBlock = (
    doWithIndexes: [|:index. :elem| aBlock value: elem. ]. ).

  doWithIndexes: aBlock = (
    length do: [|:index| aBlock value: index With: at: index ]. ).
| ).