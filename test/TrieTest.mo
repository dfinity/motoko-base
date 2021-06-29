import Trie "mo:base/Trie";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

debug {
  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;

  func key(t: Text) : Key<Text> { { key = t; hash = Text.hash t } };

  let t0 : Trie<Text, Nat> = Trie.empty();
  let t1 : Trie<Text, Nat> = Trie.put(t0, key "hello", Text.equal, 42).0;
  let t2 : Trie<Text, Nat> = Trie.put(t1, key "world", Text.equal, 24).0;
  let n : ?Nat = Trie.put(t1, key "hello", Text.equal, 0).1;
  assert (n == ?42);

  /// Compare two arrays as sets, using O(n^2) time.
  func equalAsSets<X>(a : [X], b : [X], (X, X) -> Bool) : Bool {
    for ((k, v) in expected.vals()) {
      var found = false;
      label here : () {
        for ((k2, v2) in actual.vals()) {
          if (k == k2 and v == v2) { found := true; break here };
        }
      };
      if not found { return false };
    };
    for ((k, v) in actual.vals()) {
      var found = false;
      label here : () {
        for ((k2, v2) in expected.vals()) {
          if (k == k2 and v == v2) { found := true; break here };
        }
      };
      if not found { return false };
    };
    return true
  };

  // note that `put("hello", ..., 0)` happens "after" t2, but map is immutable (applicative).
  let actual : [(Text, Nat)] = Iter.toArray(Trie.iter(t2));
  let expected : [(Text, Nat)] = [("hello", 42), ("world", 24)];
  assert (equalAsSets(actual, expected));

};
