import Prim "mo:prim";
import H "mo:base/HashMap";
import Hash "mo:base/Hash";

func textIsEq(x:Text,y:Text):Bool { x == y };

debug {
  let a = H.HashMap<Text, Nat>(3, textIsEq, Hash.hashOfText);

  ignore a.set("apple", 1);
  ignore a.set("banana", 2);
  ignore a.set("pear", 3);
  ignore a.set("avocado", 4);
  ignore a.set("Apple", 11);
  ignore a.set("Banana", 22);
  ignore a.set("Pear", 33);
  ignore a.set("Avocado", 44);
  ignore a.set("ApplE", 111);
  ignore a.set("BananA", 222);
  ignore a.set("PeaR", 333);
  ignore a.set("AvocadO", 444);

  // need to resupply the constructor args; they are private to the object; but, should they be?
  let b = H.clone<Text, Nat>(a, textIsEq, Hash.hashOfText);

  // ensure clone has each key-value pair present in original
  for ((k,v) in a.iter()) {
    Prim.debugPrint(debug_show (k,v));
    switch (b.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k,v) in b.iter()) {
    Prim.debugPrint(debug_show (k,v));
    switch (a.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // do some more operations:
  a.set("apple", 1111);
  a.set("banana", 2222);
  switch a.rem("pear") {
    case null { assert false };
    case (?three) { assert three == 3 };
  };
  a.del("avocado");

  // check them:
  switch (a.get("apple")) {
  case (?1111) { };
  case _ { assert false };
  };
  switch (a.get("banana")) {
  case (?2222) { };
  case _ { assert false };
  };
  switch (a.get("pear")) {
  case null {  };
  case (?_) { assert false };
  };
  switch (a.get("avocado")) {
  case null {  };
  case (?_) { assert false };
  };

  // undo operations above:
  a.set("apple", 1);
  // .. and test that swap works
  switch (a.swap("apple", 666)) {
    case null { assert false };
    case (?one) { assert one == 1; // ...and revert
                  a.set("apple", 1)
         };
  };
  a.set("banana", 2);
  a.set("pear", 3);
  a.set("avocado", 4);

  // ensure clone has each key-value pair present in original
  for ((k,v) in a.iter()) {
    Prim.debugPrint(debug_show (k,v));
    switch (b.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k,v) in b.iter()) {
    Prim.debugPrint(debug_show (k,v));
    switch (a.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };


  // test fromIter method
  let c = H.fromIter<Text, Nat>(b.iter(), 0, textIsEq, Hash.hashOfText);

  // c agrees with each entry of b
  for ((k,v) in b.iter()) {
    Prim.debugPrint(debug_show (k,v));
    switch (c.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // b agrees with each entry of c
  for ((k,v) in c.iter()) {
    Prim.debugPrint(debug_show (k,v));
    switch (b.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

};
