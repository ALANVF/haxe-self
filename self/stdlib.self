"this is a file of standard library definitions for Self programs to use"

"add the name 'globals' to the globals object"
globals _AddSlots: ( |
  globals = globals.
| ).

"the root object, from which all others (should) descend"
globals _AddSlotsIfAbsent: ( |
  objectTraits* = ( ).
| ).
objectTraits _DefineSlots: ( |
  "all objects can access globals, e.g. via implicit self"
  parent* = globals.

  "we can print any object"
  printString = ( _ObjPrintString ).  "default print string"
  print = ( printString print ).  "no newline"
  printLine = ( self print. '\n' print. self ).  "with a newline"

  "if we send value to something that's not a block, just return itself"
  value = ( self ).

  "test object identity"
  == arg = ( _ObjEQ: arg True: true False: false ).
  !== arg = ( _ObjNE: arg True: true False: false ).

  "nil checking"
  isNil = ( ifNil: true IfNotNil: false ).
  isNotNil = ( isNil not ).
  ifNil: then = ( ifNil: then IfNotNil: [self] ).
  ifNotNil: then = ( ifNil: [self] IfNotNil: then ).
  ifNil: then IfNotNil: else = ( else value ).
  ifNotNil: then IfNil: else = ( ifNil: else IfNotNil: then ).

  "clone"
  clone = ( _Clone ).

  "system controls"
  "tracing of messages as they are sent"
  traceOn = ( _TraceOn ).
  traceOff = ( _TraceOff ).

  "printing out each input expr's AST before it's evaluated"
  inputTraceOn = ( _InputTraceOn ).
  inputTraceOff = ( _InputTraceOff ).
| ).

"the common parent of true & false"
globals _AddSlotsIfAbsent: ( |
  boolTraits = ( ).
| ).
boolTraits _DefineSlots: ( |
  parent* = objectTraits.

  "not"
  not = ( ifTrue: false False: true ).

  "and and or; can do short-circuiting by passing a block as an argument"
  and: arg = ( ifTrue: arg False: false ).
  or: arg = ( ifTrue: true False: arg ).

  "some other flavors of if"
  ifTrue: then = ( ifTrue: then False: nil ).
  ifFalse: then = ( ifTrue: nil False: then ).
  ifFalse: then True: else = ( ifTrue: else False: then ).
| ).

"the true object"
globals _AddSlotsIfAbsent: ( |
  true = ( ).
| ).
true _DefineSlots: ( |
  parent* = boolTraits.

  "the basic ifTrue:False: method, for true objects"
  ifTrue: then False: else = ( then value ).

  "specialized printing for true"
  printString = 'true'.
| ).

"the false object"
globals _AddSlotsIfAbsent: ( |
  false = ( ).
| ).
false _DefineSlots: ( |
  parent* = boolTraits.

  "the basic ifTrue:False: method, for false objects"
  ifTrue: then False: else = ( else value ).

  "specialized printing for false"
  printString = 'false'.
| ).

"the parent of integer constants"
globals _AddSlotsIfAbsent: ( |
  intTraits = ( ).
| ).
intTraits _DefineSlots: ( |
  parent* = objectTraits.

  "negate"
  negate = ( _IntNeg ).

  "arithmetic"
  + arg = ( _IntAdd: arg ).
  - arg = ( _IntSub: arg ).
  * arg = ( _IntMul: arg ).
  / arg = ( _IntDiv: arg ).
  % arg = ( _IntMod: arg ).

  "comparisons"
  =  arg = ( _IntEQ: arg True: true False: false ).
  != arg = ( _IntNE: arg True: true False: false ).
  <  arg = ( _IntLT: arg True: true False: false ).
  <= arg = ( _IntLE: arg True: true False: false ).
  >= arg = ( _IntGE: arg True: true False: false ).
  >  arg = ( _IntGT: arg True: true False: false ).

  "conversion"
  asFloat = ( _IntAsFloat ).

  "printing"
  print = ( _IntPrint ).

  "invoke the argument block on every number in the range [0..self-1]"
  "(this is Self's simple form of counting for loop)"
  do: aBlock = ( | i <- 0 |
    [i < self] whileTrue: [aBlock value: i. i: i + 1] ).
  
  "invoke the argument block on every number in the range [self..end]"
  to: end Do: aBlock = ( | i |
    i: self.
    [i <= end] whileTrue: [aBlock value: i. i: i + 1] ).
  
  upTo: end Do: aBlock = ( to: end - 1 Do: aBlock ).

  downTo: end Do: aBlock = ( | i |
    i: self.
    [i >= end] whileTrue: [aBlock value: i. i: i - 1] ).
  

  "an example function"
  fact = ( (self <= 0) ifTrue: 1 False: [ self * (self - 1) fact ] ).
  factIter = ( | result <- 1. n | 
    n: self.
    [n > 1] whileTrue: [ result: result * n. n: n - 1 ].
    result )
| ).

"the parent of float constants"
globals _AddSlotsIfAbsent: ( |
  floatTraits = ( ).
| ).
floatTraits _DefineSlots: ( |
  parent* = objectTraits.

  "negate"
  negate = ( _FloatNeg ).

  "arithmetic"
  + arg = ( _FloatAdd: arg ).
  - arg = ( _FloatSub: arg ).
  * arg = ( _FloatMul: arg ).
  / arg = ( _FloatDiv: arg ).
  % arg = ( _FloatMod: arg ).

  "comparisons"
  =  arg = ( _FloatEQ: arg True: true False: false ).
  != arg = ( _FloatNE: arg True: true False: false ).
  <  arg = ( _FloatLT: arg True: true False: false ).
  <= arg = ( _FloatLE: arg True: true False: false ).
  >= arg = ( _FloatGE: arg True: true False: false ).
  >  arg = ( _FloatGT: arg True: true False: false ).

  "conversion"
  asInt = ( _FloatAsInt ).

  "printing"
  print = ( _FloatPrint ).

  "math"
  floor = ( _FloatFloor ).
  ceil = ( _FloatCeil ).
  round = ( _FloatRound ).
  truncate = ( _FloatTruncate ).
| ).

"the parent of string constants"
globals _AddSlotsIfAbsent: ( |
  stringTraits = ( ).
| ).
stringTraits _DefineSlots: ( |
  parent* = objectTraits.

  "string printing"
  print = ( _StringPrint ).

  "string concatenation"
  + arg = ( _StringConcat: arg ).

  "string comparisons (lexicographic, a.k.a. dictionary order)"
  =  arg = ( _StringEQ: arg True: true False: false ).
  != arg = ( _StringNE: arg True: true False: false ).
  <  arg = ( _StringLT: arg True: true False: false ).
  <= arg = ( _StringLE: arg True: true False: false ).
  >= arg = ( _StringGE: arg True: true False: false ).
  >  arg = ( _StringGT: arg True: true False: false ).

  "operations for manipulating the characters in a string:"

  "return the number of characters in the string"
  length = ( _StringLength ).

  "return the one-character string at the given index (base 0) in the
   receiver, or send value to the outOfBoundsBlock if the index isn't
   in bounds"
  at: index IfOutOfBounds: outOfBoundsBlock = ( 
    _StringAt: index IfOutOfBounds: outOfBoundsBlock ).

  "store the given one-character string at the given index in the
   receiver, or send value to the outOfBoundsBock if the index isn't
   in bounds"
  at: index Put: char IfOutOfBounds: outOfBoundsBlock = ( 
    _StringAt: index Put: char IfOutOfBounds: outOfBoundsBlock ).

  "other string operations"

  "read and evaluate a file of Self expressions"
  includeFile = ( _StringIncludeFile ).

  "fail with an error message"
  error = ( _StringError ).
| ).

"the parent of blocks"
globals _AddSlotsIfAbsent: ( |
  blockTraits = ( ).
| ).
blockTraits _DefineSlots: ( |
  parent* = objectTraits.

  "repeatedly send 'value' to the receiver"
  loop = ( _Loop ).

  "while the receiver block evaluates to true, evaluate the argument block"
  whileTrue: aBlock = (
    [ value ifTrue: aBlock False: [ "break out of the loop" ^ ] ] loop ).

  whileFalse: aBlock = ( [self value not] whileTrue: aBlock ).

  "evaluate the receiver block until the argument block evaluates to true"
  untilTrue: aBlock = ( 
    "invoke the loop body:"  value.
    "now do a while loop:"   aBlock whileTrue: [self value] ).

  untilFalse: aBlock = ( untilTrue: [aBlock value not] ).
| ).

"the nil object"
globals _AddSlotsIfAbsent: ( |
  nil = ( ).
| ).
nil _DefineSlots: ( |
  parent* = objectTraits.

  "printing"
  printString = 'nil'.

  "nil checking"
  ifNil: then IfNotNil: else = ( then value ).
| ).

"read in other files"
'collection.self' includeFile.
'list.self' includeFile.
'assocList.self' includeFile.
