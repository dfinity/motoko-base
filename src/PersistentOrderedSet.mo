/// Stable ordered set implemented as a red-black tree.
///
/// A red-black tree is a balanced binary search tree ordered by the elements.
///
/// The tree data structure internally colors each of its nodes either red or black,
/// and uses this information to balance the tree during the modifying operations.
///
/// Performance:
/// * Runtime: `O(log(n))` worst case cost per insertion, removal, and retrieval operation.
/// * Space: `O(n)` for storing the entire tree.
/// `n` denotes the number of elements (i.e. nodes) stored in the tree.
///
/// Credits:
///
/// The core of this implementation is derived from:
///
/// * Ken Friis Larsen's [RedBlackMap.sml](https://github.com/kfl/mosml/blob/master/src/mosmllib/Redblackmap.sml), which itself is based on:
/// * Stefan Kahrs, "Red-black trees with types", Journal of Functional Programming, 11(4): 425-432 (2001), [version 1 in web appendix](http://www.cs.ukc.ac.uk/people/staff/smk/redblack/rb.html).
/// The set operations implementation is derived from:
/// Tobias Nipkow's "Functional Data Structures and Algorithms", 10: 117-125 (2024).

import Debug "Debug";
import I "Iter";
import List "List";
import Nat "Nat";
import Option "Option";
import O "Order";

module {
  /// Node color: Either red (`#R`) or black (`#B`).
  public type Color = { #R; #B };

  /// Red-black tree of nodes with ordered set elements.
  /// Leaves are considered implicitly black.
  public type Set<T> = {
    #node : (Color, Set<T>, T, Set<T>);
    #leaf
  };

  /// Opertaions on `Set`, that require a comparator.
  ///
  /// The object should be created once, then used for all the operations
  /// with `Set` to maintain invariant that comparator did not changed.
  ///
  /// `SetOps` contains methods that require `compare` internally:
  /// operations that may reshape a `Set` or should find something.
  public class SetOps<T>(compare : (T, T) -> O.Order) {

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
    public func put(rbSet : Set<T>, value : T) : Set<T> = Internal.put(rbSet, compare, value);

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
    public func delete(rbSet : Set<T>, value : T) : Set<T> = Internal.delete(rbSet, compare, value);

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
    public func contains(rbSet : Set<T>, value : T) : Bool = Internal.contains(rbSet, compare, value);

    /// [Set union](https://en.wikipedia.org/wiki/Union_(set_theory)) operation.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet1 = setOps.fromIter(Iter.fromArray([0, 1, 2]));
    /// let rbSet2 = setOps.fromIter(Iter.fromArray([2, 3, 4]));
    ///
    /// Debug.print(debug_show Iter.toArray(Set.elements(setOps.union(rbSet1, rbSet2))));
    ///
    /// // [0, 1, 2, 3, 4]
    /// ```
    ///
    /// Runtime: `O(m * log(n/m + 1))`.
    /// Space: `O(m * log(n/m + 1))`, where `m` and `n` denote the number of elements
    /// in the sets, and `m <= n`.
    public func union(rbSet1 : Set<T>, rbSet2 : Set<T>) : Set<T> {
      switch (rbSet1, rbSet2) {
        case (#leaf, rbSet) { rbSet };
        case (rbSet, #leaf) { rbSet };
        case (#node (_, l1, x, r1), _) {
          let (l2, _, r2) = Internal.split(x, rbSet2, compare);
          Internal.join(union(l1, l2), x, union(r1, r2))
        };
      };
    };

    /// [Set intersection](https://en.wikipedia.org/wiki/Intersection_(set_theory)) operation.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet1 = setOps.fromIter(Iter.fromArray([0, 1, 2]));
    /// let rbSet2 = setOps.fromIter(Iter.fromArray([1, 2, 3]));
    ///
    /// Debug.print(debug_show Iter.toArray(Set.elements(setOps.intersect(rbSet1, rbSet2))));
    ///
    /// // [1, 2]
    /// ```
    ///
    /// Runtime: `O(m * log(n/m + 1))`.
    /// Space: `O(m * log(n/m + 1))`, where `m` and `n` denote the number of elements
    /// in the sets, and `m <= n`.
    public func intersect(rbSet1 : Set<T>, rbSet2 : Set<T>) : Set<T> {
      switch (rbSet1, rbSet2) {
        case (#leaf, _) { #leaf };
        case (_, #leaf) { #leaf };
        case (#node (_, l1, x, r1), _) {
          let (l2, b2, r2) = Internal.split(x, rbSet2, compare);
          let l = intersect(l1, l2);
          let r = intersect(r1, r2);
          if b2 { Internal.join (l, x, r) }
          else { Internal.join2(l, r) };
        };
      };
    };

    /// [Set difference](https://en.wikipedia.org/wiki/Difference_(set_theory)).
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet1 = setOps.fromIter(Iter.fromArray([0, 1, 2]));
    /// let rbSet2 = setOps.fromIter(Iter.fromArray([1, 2, 3]));
    ///
    /// Debug.print(debug_show Iter.toArray(Set.elements(setOps.diff(rbSet1, rbSet2))));
    ///
    /// // [0]
    /// ```
    ///
    /// Runtime: `O(m * log(n/m + 1))`.
    /// Space: `O(m * log(n/m + 1))`, where `m` and `n` denote the number of elements
    /// in the sets, and `m <= n`.
    public func diff(rbSet1 : Set<T>, rbSet2 : Set<T>) : Set<T> {
      switch (rbSet1, rbSet2) {
        case (#leaf, _) { #leaf };
        case (rbSet, #leaf) { rbSet };
        case (_, (#node(_, l2, x, r2))) {
          let (l1, _, r1) = Internal.split(x, rbSet1, compare);
          Internal.join2(diff(l1, l2), diff(r1, r2));
        }
      }
    };

    /// Creates a new Set by applying `f` to each entry in `rbSet`. Each element
    /// `x` in the old set is transformed into a new entry `x2`, where
    /// the new value `x2` is created by applying `f` to `x`.
    /// The result set may be smaller than the original set due to duplicate elements.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet = setOps.fromIter(Iter.fromArray([0, 1, 2, 3]));
    ///
    /// func f(x : Nat) : Nat = if (x < 2) { x } else { 0 };
    ///
    /// let resSet = setOps.map(rbSet, f);
    ///
    /// Debug.print(debug_show(Iter.toArray(Set.elements(resSet))));
    /// // [0, 1]
    /// ```
    ///
    /// Cost of mapping all the elements:
    /// Runtime: `O(n)`.
    /// Space: `O(n)` retained memory
    /// where `n` denotes the number of elements stored in the set.
    public func map<T1>(rbSet : Set<T1>, f : T1 -> T) : Set<T> = fromIter(I.map(elements(rbSet), f));

    /// Creates a new map by applying `f` to each element in `rbSet`. For each element
    /// `x` in the old set, if `f` evaluates to `null`, the element is discarded.
    /// Otherwise, the entry is transformed into a new entry `x2`, where
    /// the new value `x2` is the result of applying `f` to `x`.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter";
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet = setOps.fromIter(Iter.fromArray([0, 1, 2, 3]));
    ///
    /// func f(x : Nat) : ?Nat {
    ///   if(x == 0) {null}
    ///   else { ?( x * 2 )}
    /// };
    ///
    /// let newRbSet = setOps.mapFilter(rbSet, f);
    ///
    /// Debug.print(debug_show(Iter.toArray(Set.elements(newRbSet))));
    ///
    /// // [2, 4, 6]
    /// ```
    ///
    /// Runtime: `O(n)`.
    /// Space: `O(n)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of elements stored in the set and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func mapFilter<T1>(rbSet: Set<T1>, f : T1 -> ?T) : Set<T> {
        var set = #leaf : Set<T>;
        for(x in elements(rbSet)) {
          switch(f x){
            case null {};
            case (?x2) {
              set := put(set, x2);
            }
          }
        };
        set
    };

    /// Test if `rbSet1` is subset of `rbSet2`.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet1 = setOps.fromIter(Iter.fromArray([1, 2]));
    /// let rbSet2 = setOps.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show setOps.isSubset(rbSet1, rbSet2));
    ///
    /// // true
    /// ```
    ///
    /// Runtime: `O(m * log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `m` and `n` denote the number of elements stored in the sets rbSet1 and rbSet2, respectively,
    /// and assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(m * log(n))` temporary objects that will be collected as garbage.
    public func isSubset(rbSet1 : Set<T>, rbSet2 : Set<T>) : Bool {
      if (size(rbSet1) > size(rbSet2)) { return false; };
      isSubsetHelper(rbSet1, rbSet2)
    };

    /// Test if two sets are equal.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/PersistentOrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter"
    ///
    /// let setOps = Set.SetOps<Nat>(Nat.compare);
    /// let rbSet1 = setOps.fromIter(Iter.fromArray([0, 2, 1]));
    /// let rbSet2 = setOps.fromIter(Iter.fromArray([1, 2]));
    ///
    /// Debug.print(debug_show setOps.equals(rbSet1, rbSet1));
    /// Debug.print(debug_show setOps.equals(rbSet1, rbSet2));
    ///
    /// // true
    /// // false
    /// ```
    ///
    /// Runtime: `O(m * log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `m` and `n` denote the number of elements stored in the sets rbSet1 and rbSet2, respectively,
    /// and assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(m * log(n))` temporary objects that will be collected as garbage.
    public func equals (rbSet1 : Set<T>, rbSet2 : Set<T>) : Bool {
      if (size(rbSet1) != size(rbSet2)) { return false; };
      isSubsetHelper(rbSet1, rbSet2)
    };

    func isSubsetHelper(rbSet1 : Set<T>, rbSet2 : Set<T>) : Bool {
      for (x in elements(rbSet1)) {
        if (not (contains(rbSet2, x))) {
          return false;
        }
      };
      return true;
    };
  };

  type IterRep<T> = List.List<{ #tr : Set<T>; #x : T }>;

  public type Direction = { #fwd; #bwd };

  /// Get an iterator for the elements of the `rbSet`, in ascending (`#fwd`) or descending (`#bwd`) order as specified by `direction`.
  /// The iterator takes a snapshot view of the set and is not affected by concurrent modifications.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let rbSet = setOps.fromIter(Iter.fromArray([(0, 2, 1)]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Set.iter(rbSet, #fwd))));
  /// Debug.print(debug_show(Iter.toArray(Map.iter(rbSet, #bwd))));
  ///
  /// //  [0, 1, 2]
  /// //  [2, 1, 0]
  /// ```
  ///
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of elements stored in the set.
  ///
  /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func iter<T>(rbSet : Set<T>, direction : Direction) : I.Iter<T> {
    object {
      var trees : IterRep<T> = ?(#tr(rbSet), null);
      public func next() : ?T {
        switch (direction, trees) {
          case (_, null) { null };
          case (_, ?(#tr(#leaf), ts)) {
            trees := ts;
            next()
          };
          case (_, ?(#x(x), ts)) {
            trees := ts;
            ?x
          }; // TODO: Let's float-out case on direction
          case (#fwd, ?(#tr(#node(_, l, x, r)), ts)) {
            trees := ?(#tr(l), ?(#x(x), ?(#tr(r), ts)));
            next()
          };
          case (#bwd, ?(#tr(#node(_, l, x, r)), ts)) {
            trees := ?(#tr(r), ?(#x(x), ?(#tr(l), ts)));
            next()
          }
        }
      }
    }
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
  public func elements<T>(s : Set<T>) : I.Iter<T> = iter(s, #fwd);

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
  /// Cost of empty set creation
  /// Runtime: `O(1)`.
  /// Space: `O(1)`
  public func empty<T>() : Set<T> = #leaf;

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
  /// Debug.print(debug_show(Set.size(rbSet)));
  ///
  /// // 3
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of elements stored in the tree.
  public func size<T>(t : Set<T>) : Nat {
    switch t {
      case (#leaf) { 0 };
      case (#node(_, l, _, r)) {
        size(l) + size(r) + 1
      }
    }
  };

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
  public func foldLeft<T, Accum>(
    rbSet : Set<T>,
    base : Accum,
    combine : (T, Accum) -> Accum
  ) : Accum
  {
    var acc = base;
    for(val in iter(rbSet, #fwd)){
      acc := combine(val, acc);
    };
    acc
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
  public func foldRight<T, Accum>(
    rbSet : Set<T>,
    base : Accum,
    combine : (T, Accum) -> Accum
  ) : Accum
  {
    var acc = base;
    for(val in iter(rbSet, #bwd)){
      acc := combine(val, acc);
    };
    acc
  };

  /// Test if set is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  ///
  /// let rbSet = Set.empty<Nat>();
  ///
  /// Debug.print(debug_show(Set.isEmpty(rbSet)));
  ///
  /// // true
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`
  public func isEmpty<T> (rbSet : Set<T>) : Bool {
    switch rbSet {
      case (#leaf) { true };
      case _ { false };
    };
  };

  module Internal {
    public func contains<T>(t : Set<T>, compare : (T, T) -> O.Order, x : T) : Bool {
      switch t {
        case (#leaf) { false };
        case (#node(_c, l, x1, r)) {
          switch (compare(x, x1)) {
            case (#less) { contains(l, compare, x) };
            case (#equal) { true };
            case (#greater) { contains(r, compare, x) }
          }
        }
      }
    };

    func redden<T>(t : Set<T>) : Set<T> {
      switch t {
        case (#node (#B, l, x, r)) {
          (#node (#R, l, x, r))
        };
        case _ {
          Debug.trap "RBTree.red"
        }
      }
    };

    func lbalance<T>(left : Set<T>, x : T, right : Set<T>) : Set<T> {
      switch (left, right) {
        case (#node(#R, #node(#R, l1, x1, r1), x2, r2), r) {
          #node(
            #R,
            #node(#B, l1, x1, r1),
            x2,
            #node(#B, r2, x, r))
        };
        case (#node(#R, l1, x1, #node(#R, l2, x2, r2)), r) {
          #node(
            #R,
            #node(#B, l1, x1, l2),
            x2,
            #node(#B, r2, x, r))
        };
        case _ {
          #node(#B, left, x, right)
        }
      }
    };

    func rbalance<T>(left : Set<T>, x : T, right : Set<T>) : Set<T> {
      switch (left, right) {
        case (l, #node(#R, l1, x1, #node(#R, l2, x2, r2))) {
          #node(
            #R,
            #node(#B, l, x, l1),
            x1,
            #node(#B, l2, x2, r2))
        };
        case (l, #node(#R, #node(#R, l1, x1, r1), x2, r2)) {
          #node(
            #R,
            #node(#B, l, x, l1),
            x1,
            #node(#B, r1, x2, r2))
        };
        case _ {
          #node(#B, left, x, right)
        };
      }
    };

    public func put<T> (
      s : Set<T>,
      compare : (T, T) -> O.Order,
      elem : T,
    )
    : Set<T>{
      func ins(tree : Set<T>) : Set<T> {
        switch tree {
          case (#leaf) {
            #node(#R, #leaf, elem, #leaf)
          };
          case (#node(#B, left, x, right)) {
            switch (compare (elem, x)) {
              case (#less) {
                lbalance(ins left, x, right)
              };
              case (#greater) {
                rbalance(left, x, ins right)
              };
              case (#equal) {
                #node(#B, left, x, right)
              }
            }
          };
          case (#node(#R, left, x, right)) {
            switch (compare (elem, x)) {
              case (#less) {
                #node(#R, ins left, x, right)
              };
              case (#greater) {
                #node(#R, left, x, ins right)
              };
              case (#equal) {
                #node(#R, left, x, right)
              }
            }
          }
        };
      };
      switch (ins s) {
        case (#node(#R, left, x, right)) {
          #node(#B, left, x, right);
        };
        case other { other };
      };
    };

    func balLeft<T>(left : Set<T>, x : T, right : Set<T>) : Set<T> {
      switch (left, right) {
        case (#node(#R, l1, x1, r1), r) {
          #node(#R, #node(#B, l1, x1, r1), x, r)
        };
        case (_, #node(#B, l2, x2, r2)) {
          rbalance(left, x, #node(#R, l2, x2, r2))
        };
        case (_, #node(#R, #node(#B, l2, x2, r2), x3, r3)) {
          #node(#R,
            #node(#B, left, x, l2),
            x2,
            rbalance(r2, x3, redden r3))
        };
        case _ { Debug.trap "balLeft" };
      }
    };

    func balRight<T>(left : Set<T>, x : T, right : Set<T>) : Set<T> {
      switch (left, right) {
        case (l, #node(#R, l1, x1, r1)) {
          #node(#R, l, x, #node(#B, l1, x1, r1))
        };
        case (#node(#B, l1, x1, r1), r) {
          lbalance(#node(#R, l1, x1, r1), x, r);
        };
        case (#node(#R, l1, x1, #node(#B, l2, x2, r2)), r3) {
          #node(#R,
            lbalance(redden l1, x1, l2),
            x2,
            #node(#B, r2, x, r3))
        };
        case _ { Debug.trap "balRight" };
      }
    };

    func append<T>(left : Set<T>, right: Set<T>) : Set<T> {
      switch (left, right) {
        case (#leaf,  _) { right };
        case (_,  #leaf) { left };
        case (#node (#R, l1, x1, r1),
              #node (#R, l2, x2, r2)) {
          switch (append (r1, l2)) {
            case (#node (#R, l3, x3, r3)) {
              #node(
                #R,
                #node(#R, l1, x1, l3),
                x3,
                #node(#R, r3, x2, r2))
            };
            case r1l2 {
              #node(#R, l1, x1, #node(#R, r1l2, x2, r2))
            }
          }
        };
        case (t1, #node(#R, l2, x2, r2)) {
          #node(#R, append(t1, l2), x2, r2)
        };
        case (#node(#R, l1, x1, r1), t2) {
          #node(#R, l1, x1, append(r1, t2))
        };
        case (#node(#B, l1, x1, r1), #node (#B, l2, x2, r2)) {
          switch (append (r1, l2)) {
            case (#node (#R, l3, x3, r3)) {
              #node(#R,
                #node(#B, l1, x1, l3),
                x3,
                #node(#B, r3, x2, r2))
            };
            case r1l2 {
              balLeft (
                l1,
                x1,
                #node(#B, r1l2, x2, r2)
              )
            }
          }
        }
      }
    };

    public func delete<T>(tree : Set<T>, compare : (T, T) -> O.Order, x : T) : Set<T> {
      func delNode(left : Set<T>, x1 : T, right : Set<T>) : Set<T> {
        switch (compare (x, x1)) {
          case (#less) {
            let newLeft = del left;
            switch left {
              case (#node(#B, _, _, _)) {
                balLeft(newLeft, x1, right)
              };
              case _ {
                #node(#R, newLeft, x1, right)
              }
            }
          };
          case (#greater) {
            let newRight = del right;
            switch right {
              case (#node(#B, _, _, _)) {
                balRight(left, x1, newRight)
              };
              case _ {
                #node(#R, left, x1, newRight)
              }
            }
          };
          case (#equal) {
            append(left, right)
          };
        }
      };
      func del(tree : Set<T>) : Set<T> {
        switch tree {
          case (#leaf) {
            tree
          };
          case (#node(_, left, x1, right)) {
            delNode(left, x1, right)
          }
        };
      };
      switch (del(tree)) {
        case (#node(#R, left, x1, right)) {
          #node(#B, left, x1, right);
        };
        case other { other };
      };
    };

    // TODO: Instead, consider storing the black height in the node constructor
    public func blackHeight<T> (rbSet : Set<T>) : Nat {
      func f (node : Set<T>, acc : Nat) : Nat {
        switch node {
          case (#leaf) { acc };
          case (#node (#R, l1, _, _)) { f(l1, acc) };
          case (#node (#B, l1, _, _)) { f(l1, acc + 1) }
        }
      };
      f (rbSet, 0)
    };

    public func joinL<T>(l : Set<T>, x : T, r : Set<T>) : Set<T> {
      if (blackHeight r <= blackHeight l) { (#node (#R, l, x, r)) }
      else {
        switch r {
          case (#node (#R, rl, rx, rr)) { (#node (#R, joinL(l, x, rl) , rx, rr)) };
          case (#node (#B, rl, rx, rr)) { balLeft (joinL(l, x, rl), rx, rr) };
          case _ { Debug.trap "joinL" };
        }
      }
    };

    public func joinR<T>(l : Set<T>, x : T, r : Set<T>) : Set<T> {
      if (blackHeight l <= blackHeight r) { (#node (#R, l, x, r)) }
      else {
        switch l {
          case (#node (#R, ll, lx, lr)) { (#node (#R, ll , lx, joinR (lr, x, r))) };
          case (#node (#B, ll, lx, lr)) { balRight (ll, lx, joinR (lr, x, r)) };
          case _ { Debug.trap "joinR" };
        }
      }
    };

    public func paint<T>(color : Color, rbMap : Set<T>) : Set<T> {
      switch rbMap {
        case (#leaf) { #leaf };
        case (#node (_, l, x, r)) { (#node (color, l, x, r)) };
      }
    };

    public func splitMin<T> (rbSet : Set<T>) : (T, Set<T>) {
      switch rbSet {
        case (#leaf) { Debug.trap "splitMin" };
        case (#node(_, #leaf, x, r)) { (x, r) };
        case (#node(_, l, x, r)) {
          let (m, l2) = splitMin l;
          (m, join(l2, x, r))
        };
      }
    };

    // Joins an element and two trees.
    // See Tobias Nipkow's "Functional Data Structures and Algorithms", 117
    public func join<T>(l : Set<T>, x : T, r : Set<T>) : Set<T> {
      if (Internal.blackHeight r < Internal.blackHeight l) {
        return Internal.paint(#B, Internal.joinR(l, x, r))
      };
      if (Internal.blackHeight l < Internal.blackHeight r) {
        return Internal.paint(#B, Internal.joinL(l, x, r))
      };
      return (#node (#B, l, x, r))
    };

    // Joins two trees.
    // See Tobias Nipkow's "Functional Data Structures and Algorithms", 117
    public func join2<T>(l : Set<T>, r : Set<T>) : Set<T> {
      switch r {
        case (#leaf) { l };
        case _ {
          let (m, r2) = Internal.splitMin r;
          join(l, m, r2)
        };
      }
    };

    // Splits `rbSet` with respect to a given element `x`, into tuple `(l, b, r)`
    // such that `l` contains the elements less than `x`, `r` contains the elements greater than `x`
    // and `b` is `true` if `x` was in the `rbSet`.
    // See Tobias Nipkow's "Functional Data Structures and Algorithms", 117
    public func split<T>(x : T, rbSet : Set<T>, compare : (T, T) -> O.Order) : (Set<T>, Bool, Set<T>) {
      switch rbSet {
        case (#leaf) { (#leaf, false, #leaf)};
        case (#node (_, l, x1, r)) {
          switch (compare(x, x1)) {
            case (#less) {
              let (l1, b, l2) = split(x, l, compare);
              (l1, b, join(l2, x1, r))
            };
            case (#equal) { (l, true, r) };
            case (#greater) {
              let (r1, b, r2) = split(x, r, compare);
              (join(l, x1, r1), b, r2)
            };
          };
        };
      };
    };
  }
}
