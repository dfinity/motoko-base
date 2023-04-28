import Prim "mo:⛔";
import H "mo:base/StableHashMap";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

debug {
  let a = H.empty_<Text, Nat>(3, Text.equal, Text.hash);

  H.put(a, "apple", 1);
  H.put(a, "banana", 2);
  H.put(a, "pear", 3);
  H.put(a, "avocado", 4);
  H.put(a, "Apple", 11);
  H.put(a, "Banana", 22);
  H.put(a, "Pear", 33);
  H.put(a, "Avocado", 44);
  H.put(a, "ApplE", 111);
  H.put(a, "BananA", 222);
  H.put(a, "PeaR", 333);
  H.put(a, "AvocadO", 444);

  // need to resupply the constructor args; they are private to the object; but, should they be?
  let b = H.clone_<Text, Nat>(a);

  // ensure clone has each key-value pair present in original
  for ((k,v) in H.entries(a)) {
    Prim.debugPrint(debug_show (k,v));
    switch (H.get(b, k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k,v) in H.entries(b)) {
    Prim.debugPrint(debug_show (k,v));
    switch (H.get(a, k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure clone has each key present in original
  for (k in H.keys(a)) {
    switch (H.get(b, k)) {
    case null { assert false };
    case (?_) {  };
    };
  };

  // ensure clone has each value present in original
  for (v in H.vals(a)) {
    var foundMatch = false;
    for (w in H.vals(b)) {
      if (v == w) { foundMatch := true }
    };
    assert foundMatch
  };

  // do some more operations:
  H.put(a, "apple", 1111);
  H.put(a, "banana", 2222);
  switch( H.remove(a, "pear")) {
    case null { assert false };
    case (?three) { assert three == 3 };
  };
  H.delete(a, "avocado");

  // check them:
  switch (H.get(a, "apple")) {
  case (?1111) { };
  case _ { assert false };
  };
  switch (H.get(a, "banana")) {
  case (?2222) { };
  case _ { assert false };
  };
  switch (H.get(a, "pear")) {
  case null {  };
  case (?_) { assert false };
  };
  switch (H.get(a, "avocado")) {
  case null {  };
  case (?_) { assert false };
  };

  // undo operations above:
  H.put(a, "apple", 1);
  // .. and test that replace works
  switch (H.replace(a, "apple", 666)) {
    case null { assert false };
    case (?one) { assert one == 1; // ...and revert
                  H.put(a, "apple", 1)
         };
  };
  H.put(a, "banana", 2);
  H.put(a, "pear", 3);
  H.put(a, "avocado", 4);

  // ensure clone has each key-value pair present in original
  for ((k,v) in H.entries(a)) {
    Prim.debugPrint(debug_show (k,v));
    switch (H.get(b, k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // ensure original has each key-value pair present in clone
  for ((k,v) in H.entries(b)) {
    Prim.debugPrint(debug_show (k,v));
    switch (H.get(a, k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };


  // test fromIter method
  let c = H.fromIter<Text, Nat>(H.entries(b), 0, Text.equal, Text.hash);

  // c agrees with each entry of b
  for ((k,v) in H.entries(b)) {
    Prim.debugPrint(debug_show (k,v));
    switch (H.get(c, k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // b agrees with each entry of c
  for ((k,v) in H.entries(c)) {
    Prim.debugPrint(debug_show (k,v));
    switch (H.get(b, k)) {
    case null { assert false };
    case (?w) { assert v == w };
    };
  };

  // Issue #228
  let d = H.empty_<Text, Nat>(50, Text.equal, Text.hash);
  switch(H.remove(d, "test")) {
    case null { };
    case (?_) { assert false };
  };
};

