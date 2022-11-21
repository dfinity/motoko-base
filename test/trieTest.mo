import Trie "mo:base/Trie";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

debug {
  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;

  func key(i: Nat) : Key<Text> { 
    let t = Nat.toText i;
    { key = t ; hash = Text.hash t }
  };

  let max = 100;

  // put k-v elements, one by one (but hashes are expected random).
  var t : Trie<Text, Nat> = Trie.empty();
  for (i in Iter.range(0, max)) {
    let (t1_, x) = Trie.put<Text, Nat>(t, key i, Text.equal, i);



    assert (Option.isNull(x));



    assert Trie.isValid(t1_, true);



    t := t1_;
  };
  assert Trie.size(t) == max;

  // remove all elements, one by one (but hashes are expected random).
  do {
    var t1 = t;
    for (i in Iter.range(0, max)) {
      let (t1_, x) = Trie.remove<Text, Nat>(t1, key i, Text.equal);
      assert Trie.isValid(t1_, true);
      assert (Option.isSome(x));
      t1 := t1_;
    }
  };

  // filter all elements away, one by one (but hashes are expected random).
  do { 
    var t1 = t;
    for (i in Iter.range(0, max)) {
      t1 := Trie.filter (t1, func (t : Text, n : Nat) : Bool { n != i } );
      assert Trie.isValid(t1, true);
      assert Trie.size(t1) == (max - i : Nat);
    }
  };

  // filter-map all elements away, one by one (but hashes are expected random).
  do { 
    var t1 = t;
    for (i in Iter.range(0, max)) {
      t1 := Trie.mapFilter (t1, 
       func (t : Text, n : Nat) : ?Nat { 
         if (n != i) ?n else null }
      );
      assert Trie.isValid(t1, true);
      assert Trie.size(t1) == (max - i : Nat);
    }
  }
};
