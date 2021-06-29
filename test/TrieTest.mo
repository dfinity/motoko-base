import Trie "mo:base/Trie";
import Text "mo:base/Text";

debug {
  type Trie<K, V> = Trie.Trie<K, V>;

  func key(t: Text) : Key<Text> { { key = t; hash = Text.hash t } };
  
  let t0 : Trie<Text, Nat> = Trie.empty();
  let t1 : Trie<Text, Nat> = Trie.put(t0, key "hello", 42).0;
  let t2 : Trie<Text, Nat> = Trie.put(t1, key "world", 24).0;
  let n : Nat = Trie.put(t1, key "hello", 0).1;
  assert (n == 42);
};
