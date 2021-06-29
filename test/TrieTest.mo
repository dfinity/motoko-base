import Trie "mo:base/Trie";
import Text "mo:base/Text";

debug {
  type Trie<K, V> = Trie.Trie<K, V>;
  type Key<K> = Trie.Key<K>;

  func key(t: Text) : Key<Text> { { key = t; hash = Text.hash t } };
  
  let t0 : Trie<Text, Nat> = Trie.empty();
  let t1 : Trie<Text, Nat> = Trie.put(t0, key "hello", Text.equal, 42).0;
  let t2 : Trie<Text, Nat> = Trie.put(t1, key "world", Text.equal, 24).0;
  let n : Nat = Trie.put(t1, key "hello", Text.equal, 0).1;
  assert (n == 42);
};
