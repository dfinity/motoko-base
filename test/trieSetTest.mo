import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Array "mo:base/Array";
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
};


let largeTests = do {
  let e = TrieSet.empty<Nat>();
  let a = TrieSet.fromArray<Nat>(Array.tabulate<Nat>(1000, func i { 2 * i }), Hash.hash, Nat.equal);
  let b = TrieSet.fromArray<Nat>(Array.tabulate<Nat>(1000, func i { 1 + 2 * i }), Hash.hash, Nat.equal);
  let c = TrieSet.fromArray<Nat>(Array.tabulate<Nat>(2000, func i { i }), Hash.hash, Nat.equal);
  let a1 = TrieSet.diff(c, b, Nat.equal);
  let b1 = TrieSet.diff(c, a, Nat.equal);
  let e1 = TrieSet.diff(c, c, Nat.equal);
  let suite = Suite.suite(
    "TrieSet -- binary operations",
    [

      Suite.test(
        "isSubset e a = true",
        TrieSet.isSubset(e, a, Nat.equal),
        M.equals(T.bool(true))
      ),

      Suite.test(
        "isSubset a e = false",
        TrieSet.isSubset(a, e, Nat.equal),
        M.equals(T.bool(false))
      ),

      Suite.test(
        "isSubset a a = true",
        TrieSet.isSubset(a, a, Nat.equal),
        M.equals(T.bool(true))
      ),

      Suite.test(
        "isSubset a c = true",
        TrieSet.isSubset(a, c, Nat.equal),
        M.equals(T.bool(true))
      ),

      Suite.test(
        "isSubset a b = false",
        TrieSet.isSubset(a, b, Nat.equal),
        M.equals(T.bool(false))
      ),

      Suite.test(
        "union a b = c",
        TrieSet.equal(TrieSet.union(a, b, Nat.equal), c, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "union a a = a",
        TrieSet.equal(TrieSet.union(a, a, Nat.equal), a, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "union a a = a",
        TrieSet.equal(TrieSet.union(a, e, Nat.equal), a, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "union e a = a",
        TrieSet.equal(TrieSet.union(e, a, Nat.equal), a, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "union e e = e",
        TrieSet.equal(TrieSet.union(e, e, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "intersect a c = a",
        TrieSet.equal(TrieSet.intersect(a, c, Nat.equal), a, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "intersect a b = e",
        TrieSet.equal(TrieSet.intersect(a, b, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "intersect e a = e",
        TrieSet.equal(TrieSet.intersect(e, a, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "intersect a e = e",
        TrieSet.equal(TrieSet.intersect(a, e, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "diff a c = e",
        TrieSet.equal(TrieSet.diff(a, c, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "diff a b = a",
        TrieSet.equal(TrieSet.diff(a, b, Nat.equal), a, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "diff a a = e",
        TrieSet.equal(TrieSet.diff(a, a, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "diff e a = e",
        TrieSet.equal(TrieSet.diff(e, a, Nat.equal), e, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "equal e e = true",
        TrieSet.equal(e, e, Nat.equal),
        M.equals(T.bool(true))
      ),
       Suite.test(
        "equal e e1 = true",
        TrieSet.equal(e, e1, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "equal a e = false",
        TrieSet.equal(a, e, Nat.equal),
        M.equals(T.bool(false))
      ),
      Suite.test(
        "equal a a = true",
        TrieSet.equal(a, a, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "equal a b = false",
        TrieSet.equal(a, b, Nat.equal),
        M.equals(T.bool(false))
      ),
      Suite.test(
        "equal a c = false",
        TrieSet.equal(a, c, Nat.equal),
        M.equals(T.bool(false))
      ),
      Suite.test(
        "equal c a = false",
        TrieSet.equal(c, a, Nat.equal),
        M.equals(T.bool(false))
      ),
      Suite.test(
        "equal a a1 = true",
        TrieSet.equal(a, a1, Nat.equal),
        M.equals(T.bool(true))
      ),
      Suite.test(
        "equal b b1 = true",
        TrieSet.equal(b, b1, Nat.equal),
        M.equals(T.bool(true))
      ),
    ]
  );
  Suite.run(suite)
}
