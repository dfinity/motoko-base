import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Word32 "mo:base/Word32";
import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let set1 = TrieSet.fromArray<Nat>([ 1, 2, 3, 1, 2, 3, 1 ], Word32.fromNat, Nat.equal);

let suite = Suite.suite("TrieSet fromArray", [
  Suite.test(
    "mem",
    TrieSet.mem<Nat>(set1, 1, 1, Nat.equal),
    M.equals(T.bool true)
  ),
  Suite.test(
    "size",
    TrieSet.size(set1),
    M.equals(T.nat 3)
  ),
  Suite.test(
    "toArray",
    TrieSet.toArray<Nat>(set1),
    M.equals(T.array<Nat>(T.natTestable, [ 1, 2, 3 ]))
  )
]);

Suite.run(suite);
