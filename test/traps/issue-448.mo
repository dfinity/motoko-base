import Trie "mo:base/Trie";
import Text "mo:base/Text";

func key(t : Text) : Trie.Key<Text> = {key = t; hash = Text.hash(t)};

var trie = Trie.empty<Text,Nat>();

trie := Trie.put(trie, key "hello", Text.equal, 42).0;
trie := Trie.put(trie, key "bye", Text.equal, 42).0;
// trie2 is a copy of trie
var trie2 = Trie.clone(trie);
// trie2 has a different value for "hello"
trie2 := Trie.put(trie2, key "hello", Text.equal, 33).0;
// mergeDisjoint should signal a dynamic error
// in the case of a collision
Trie.mergeDisjoint(trie, trie2, Text.equal); // should trap
