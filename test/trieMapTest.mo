import Prim "mo:⛔";
import H "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

debug {
  let a = H.TrieMap<Text, Nat>(Text.equal, Text.hash);

  assert a.size() == 0;
  ignore a.remove("apple");
  assert a.size() == 0;

  a.put("apple", 1);
  assert a.size() == 1;
  ignore a.remove("apple");
  assert a.size() == 0;

  a.put("apple", 1);
  a.put("banana", 2);
  a.put("pear", 3);
  a.put("avocado", 4);
  a.put("Apple", 11);
  a.put("Banana", 22);
  a.put("Pear", 33);
  a.put("Avocado", 44);
  a.put("ApplE", 111);
  a.put("BananA", 222);
  a.put("PeaR", 333);
  a.put("AvocadO", 444);

  // need to resupply the constructor args; they are private to the object; but, should they be?
  let b = H.clone<Text, Nat>(a, Text.equal, Text.hash);

  // ensure clone has each key-value pair present in original
  for ((k,v) in a.entries()) {
    Prim.debugPrint(debug_show (k,v));
    switch (b.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k,v) in b.entries()) {
    Prim.debugPrint(debug_show (k,v));
    switch (a.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // do some more operations:
  a.put("apple", 1111);
  a.put("banana", 2222);
  a.delete("pear");
  a.delete("avocado");

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
  a.put("apple", 1);
  a.put("banana", 2);
  a.put("pear", 3);
  a.put("avocado", 4);

  // ensure clone has each key-value pair present in original
  for ((k,v) in a.entries()) {
    Prim.debugPrint(debug_show (k,v));
    switch (b.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k,v) in b.entries()) {
    Prim.debugPrint(debug_show (k,v));
    switch (a.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };


  // test fromEntries method
  let c = H.fromEntries<Text, Nat>(b.entries(), Text.equal, Text.hash);

  // c agrees with each entry of b
  for ((k,v) in b.entries()) {
    Prim.debugPrint(debug_show (k,v));
    switch (c.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // b agrees with each entry of c
  for ((k,v) in c.entries()) {
    Prim.debugPrint(debug_show (k,v));
    switch (b.get(k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

};
