import Trie "mo:base/Trie";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Debug "mo:base/Debug";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let test = Suite;

let suite = Suite.suite("Array", [
  Suite.test(
    "empty trie size 0",
    Trie.size(Trie.empty<Nat, Nat>()),
    M.equals(T.nat(0))),
  ]
);

Suite.run(suite);

debug {
  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;

  func key(i: Nat) : Key<Text> {
    let t = Nat.toText i;
    { key = t ; hash = Text.hash t }
  };

  let max = 100;

  // put k-v elements, one by one (but hashes are expected random).
  Debug.print "Trie.put";
  var t : Trie<Text, Nat> = Trie.empty();
  for (i in Iter.range(0, max - 1)) {
    let (t1_, x) = Trie.put<Text, Nat>(t, key i, Text.equal, i);
    assert (Option.isNull(x));
    assert Trie.isValid(t1_, false);
    t := t1_;
  };
  assert Trie.size(t) == max;

  // remove all elements, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.remove";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      let (t1_, x) = Trie.remove<Text, Nat>(t1, key i, Text.equal);
      assert Trie.isValid(t1_, false);
      assert (Option.isSome(x));
      t1 := t1_;
    }
  };

  // filter all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.filter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.filter (t1, func (t : Text, n : Nat) : Bool { n != i } );
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat);
    }
  };

  // filter-map all elements away, one by one (but hashes are expected random).
  do {
    Debug.print "Trie.mapFilter";
    var t1 = t;
    for (i in Iter.range(0, max - 1)) {
      t1 := Trie.mapFilter (t1,
       func (t : Text, n : Nat) : ?Nat {
         if (n != i) ?n else null }
      );
      assert Trie.isValid(t1, false);
      assert Trie.size(t1) == (max - (i + 1) : Nat);
    }
  }
};
