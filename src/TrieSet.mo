///  Functional set
/// 
/// Sets are partial maps from element type to unit type,
/// i.e., the partial map represents the set with its domain.
/// 
/// :::warning [Limitations]
/// 
/// This data structure allows at most `MAX_LEAF_SIZE = 8` hash collisions.
/// Attempts to insert more than 8 elements with the same hash value—either directly via `put` or indirectly via other operations—will trap.
/// This limitation is inherited from the underlying `Trie` data structure.
/// :::
/// 

// TODO-Matthew:
// ---------------
//
// - for now, we pass a hash value each time we pass an element value;
//   in the future, we might avoid passing element hashes with each element in the API;
//   related to: https://dfinity.atlassian.net/browse/AST-32
//
// - similarly, we pass an equality function when we do some operations.
//   in the future, we might avoid this via https://dfinity.atlassian.net/browse/AST-32
import Trie "Trie";
import Hash "Hash";
import List "List";
import Iter "Iter";

module {

  public type Hash = Hash.Hash;
  public type Set<T> = Trie.Trie<T, ()>;
  type Key<K> = Trie.Key<K>;
  type Trie<K, V> = Trie.Trie<K, V>;

  // helper for defining equal and sub, avoiding Trie.diff.
  // TODO: add to Trie.mo?
  private func keys<K>(t : Trie<K, Any>) : Iter.Iter<Key<K>> {
    object {
      var stack = ?(t, null) : List.List<Trie<K, Any>>;
      public func next() : ?Key<K> {
        switch stack {
          case null { null };
          case (?(trie, stack2)) {
            switch trie {
              case (#empty) {
                stack := stack2;
                next()
              };
              case (#leaf({ keyvals = null })) {
                stack := stack2;
                next()
              };
              case (#leaf({ size = c; keyvals = ?((k, _v), kvs) })) {
                stack := ?(#leaf({ size = c - 1; keyvals = kvs }), stack2);
                ?k
              };
              case (#branch(br)) {
                stack := ?(br.left, ?(br.right, stack2));
                next()
              }
            }
          }
        }
      }
    }
  };

  ///  Empty set.
  public func empty<T>() : Set<T> { Trie.empty<T, ()>() };

  ///  Put an element into the set.
  public func put<T>(s : Set<T>, x : T, xh : Hash, eq : (T, T) -> Bool) : Set<T> {
    let (s2, _) = Trie.put<T, ()>(s, { key = x; hash = xh }, eq, ());
    s2
  };

  ///  Delete an element from the set.
  public func delete<T>(s : Set<T>, x : T, xh : Hash, eq : (T, T) -> Bool) : Set<T> {
    let (s2, _) = Trie.remove<T, ()>(s, { key = x; hash = xh }, eq);
    s2
  };

  ///  Test if two sets are equal.
  public func equal<T>(s1 : Set<T>, s2 : Set<T>, eq : (T, T) -> Bool) : Bool {
    if (Trie.size(s1) != Trie.size(s2)) return false;
    for (k in keys(s1)) {
      if (Trie.find<T, ()>(s2, k, eq) == null) {
        return false
      }
    };
    return true
  };

  ///  The number of set elements, set's cardinality.
  public func size<T>(s : Set<T>) : Nat {
    Trie.size(s)
  };

  ///  Test if `s` is the empty set.
  public func isEmpty<T>(s : Set<T>) : Bool {
    Trie.size(s) == 0
  };

  ///  Test if `s1` is a subset of `s2`.
  public func isSubset<T>(s1 : Set<T>, s2 : Set<T>, eq : (T, T) -> Bool) : Bool {
    if (Trie.size(s1) > Trie.size(s2)) return false;
    for (k in keys(s1)) {
      if (Trie.find<T, ()>(s2, k, eq) == null) {
        return false
      }
    };
    return true
  };

  ///  @deprecated: use `TrieSet.contains()`
  /// 
  ///  Test if a set contains a given element.
  public func mem<T>(s : Set<T>, x : T, xh : Hash, eq : (T, T) -> Bool) : Bool {
    contains(s, x, xh, eq)
  };

  ///  Test if a set contains a given element.
  public func contains<T>(s : Set<T>, x : T, xh : Hash, eq : (T, T) -> Bool) : Bool {
    switch (Trie.find<T, ()>(s, { key = x; hash = xh }, eq)) {
      case null { false };
      case (?_) { true }
    }
  };

  ///  [Set union](https://en.wikipedia.org/wiki/Union_(set_theory)).
  public func union<T>(s1 : Set<T>, s2 : Set<T>, eq : (T, T) -> Bool) : Set<T> {
    let s3 = Trie.merge<T, ()>(s1, s2, eq);
    s3
  };

  ///  [Set difference](https://en.wikipedia.org/wiki/Difference_(set_theory)).
  public func diff<T>(s1 : Set<T>, s2 : Set<T>, eq : (T, T) -> Bool) : Set<T> {
    let s3 = Trie.diff<T, (), ()>(s1, s2, eq);
    s3
  };

  ///  [Set intersection](https://en.wikipedia.org/wiki/Intersection_(set_theory)).
  public func intersect<T>(s1 : Set<T>, s2 : Set<T>, eq : (T, T) -> Bool) : Set<T> {
    let noop : ((), ()) -> (()) = func(_ : (), _ : ()) : (()) = ();
    let s3 = Trie.join<T, (), (), ()>(s1, s2, eq, noop);
    s3
  };

  /// / Construct a set from an array.
  public func fromArray<T>(arr : [T], elemHash : T -> Hash, eq : (T, T) -> Bool) : Set<T> {
    var s = empty<T>();
    for (elem in arr.vals()) {
      s := put<T>(s, elem, elemHash(elem), eq)
    };
    s
  };

  /// / Returns the set as an array.
  public func toArray<T>(s : Set<T>) : [T] {
    Trie.toArray(s, func(t : T, _ : ()) : T { t })
  }

}
