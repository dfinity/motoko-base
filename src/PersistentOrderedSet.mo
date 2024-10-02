/// Stable ordered set implemented as a red-black tree. Currently built on top of PersistentOrderedMap by storing () values.
///
/// Performance:
/// * Runtime: `O(log(n))` worst case cost per insertion, removal, and retrieval operation.
/// * Space: `O(n)` for storing the entire tree.
/// `n` denotes the number of elements (i.e. nodes) stored in the tree.


import Map "PersistentOrderedMap";
import I "Iter";
import Nat "Nat";
import O "Order";
import Option "Option";

module {
  public type Set<T> = Map.Map<T,()>;

  /// Opertaions on `Set`, that require a comparator.
  ///
  /// The object should be created once, then used for all the operations
  /// with `Set` to maintain invariant that comparator did not changed.
  ///
  /// `SetOps` contains methods that require `compare` internally:
  /// operations that may reshape a `Set` or should find something.
  public class SetOps<T>(compare : (T, T) -> O.Order) {
    let mapOps = Map.MapOps<T>(compare);

    /// Returns a new Set, containing all entries given by the iterator `i`.
    /// If there are multiple identical entries only one is taken.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(Iter.toArray(Set.elements(rbSet))));
    ///
    /// // [0, 1, 2]
    /// ```
    ///
    /// Runtime: `O(n * log(n))`.
    /// Space: `O(n)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of elements stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(n * log(n))` temporary objects that will be collected as garbage.
    public func fromIter(i : I.Iter<T>) : Set<T> {
      var set = #leaf : Set<T>;
      for(val in i) {
        set := put(set, val);
      };
      set
    };

    /// Insert the value `value` into set `rbSet`. Has no effect if `value` is already
    /// present in the set. Returns a modified set.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// var rbSet = Set.empty<Nat>();
    ///
    /// rbSet := setOps.put(rbSet, 0);
    /// rbSet := setOps.put(rbSet, 2);
    /// rbSet := setOps.put(rbSet, 1);
    ///
    /// Debug.print(debug_show(Iter.toArray(Set.elements(rbSet))));
    ///
    /// // [0, 1, 2]
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func put(rbSet : Set<T>, value : T) : Set<T> = mapOps.put<()>(rbSet, value, ());

    /// Deletes the value `value` from the `rbSet`. Has no effect if `value` is not
    /// present in the set. Returns modified set.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(Iter.toArray(Set.elements(setOps.delete(rbSet, 1)))));
    /// Debug.print(debug_show(Iter.toArray(Set.elements(setOps.delete(rbSet, 42)))));
    ///
    /// // [0, 2]
    /// // [0, 1, 2]
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of elements stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func delete(rbSet : Set<T>, value : T) : Set<T> = mapOps.delete<()>(rbSet, value);

    /// Test if a set contains a given element.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show setOps.contains(rbSet, 1));
    /// Debug.print(debug_show setOps.contains(rbSet, 42));
    ///
    /// // true
    /// // false
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of elements stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func contains(rbSet : Set<T>, value : T) : Bool = Option.isSome(mapOps.get(rbSet, value));
  };

  /// Returns an Iterator (`Iter`) over the elements of the set.
  /// Iterator provides a single method `next()`, which returns
  /// elements in ascending order, or `null` when out of elements to iterate over.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Set.elements(rbSet))));
  ///
  /// // [0, 1, 2]
  /// ```
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of elements stored in the set.
  ///
  /// Note: Full set iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func elements<T>(s : Set<T>) : I.Iter<T> = Map.keys<T, ()>(s);

  /// Create a new empty Set.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  ///
  /// let rbSet = Set.empty<Nat>();
  ///
  /// Debug.print(debug_show(Set.size(rbSet)));
  ///
  /// // 0
  /// ```
  ///
  /// Cost of empty map creation
  /// Runtime: `O(1)`.
  /// Space: `O(1)`
  public func empty<T>() : Set<T> = Map.empty<T, ()>();

  /// Determine the size of the tree as the number of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
  ///
  /// Debug.print(debug_show(Map.size(rbSet)));
  ///
  /// // 3
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of elements stored in the tree.
  public func size<T>(rbSet : Set<T>) : Nat = Map.size<T, ()>(rbSet);

  /// Collapses the elements in `rbSet` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
  ///
  /// func folder(val : Nat, accum : Nat) : Nat = val + accum;
  ///
  /// Debug.print(debug_show(Set.foldLeft(rbSet, 0, folder)));
  ///
  /// // 3
  /// ```
  ///
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: depends on `combine` function plus garbage, see the note below.
  /// where `n` denotes the number of elements stored in the set.
  ///
  /// Note: Full set iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func foldLeft<T, Accum> (
    rbSet : Set<T>,
    base : Accum,
    combine : (T, Accum) -> Accum
  ) : Accum
  {
    Map.foldLeft(
      rbSet,
      base,
      func (x : T , _ : (), acc : Accum) : Accum { combine(x, acc) }
    )
  };

  /// Collapses the elements in `rbSet` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
  ///
  /// func folder(val : Nat, accum : Nat) : Nat = val + accum;
  ///
  /// Debug.print(debug_show(Set.foldRight(rbSet, 0, folder)));
  ///
  /// // 3
  /// ```
  ///
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: depends on `combine` function plus garbage, see the note below.
  /// where `n` denotes the number of elements stored in the set.
  ///
  /// Note: Full set iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func foldRight<T, Accum> (
    rbSet : Set<T>,
    base : Accum,
    combine : (T, Accum) -> Accum
  ) : Accum
  {
    Map.foldRight(
      rbSet,
      base,
      func (x : T , _ : (), acc : Accum) : Accum { combine(x, acc) }
    )
  };
}
