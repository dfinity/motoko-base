import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let simpleTests = do {
  let set1 = TrieSet.fromArray<Nat>([1, 2, 3, 1, 2, 3, 1], Nat32.fromNat, Nat.equal);

  let suite = Suite.suite(
    "TrieSet fromArray",
    [
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
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      )
    ]
  );
  Suite.run(suite)
};

let binopTests = do {
  let a = TrieSet.fromArray<Nat>([1, 3], Hash.hash, Nat.equal);
  let b = TrieSet.fromArray<Nat>([2, 3], Hash.hash, Nat.equal);

  let suite = Suite.suite(
    "TrieSet -- binary operations",
    [
      Suite.test(
        "union",
        TrieSet.toArray(TrieSet.union(a, b, Nat.equal)),
        M.equals(T.array<Nat>(T.natTestable, [1, 2, 3]))
      ),
      Suite.test(
        "intersect",
        TrieSet.toArray(TrieSet.intersect(a, b, Nat.equal)),
        M.equals(T.array<Nat>(T.natTestable, [3]))
      ),
      Suite.test(
        "diff",
        TrieSet.toArray(TrieSet.diff(a, b, Nat.equal)),
        M.equals(T.array<Nat>(T.natTestable, [1]))
      )
    ]
  );
  Suite.run(suite)
}
