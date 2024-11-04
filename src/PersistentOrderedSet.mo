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

import Debug "Debug";
import I "Iter";
import List "List";
import Nat "Nat";
import Option "Option";
import O "Order";

module {
  /// Red-black tree of nodes with ordered set elements.
  /// Leaves are considered implicitly black.
  public type Tree<T> = {
    #red : (Tree<T>, T, Tree<T>);
    #black : (Tree<T>, T, Tree<T>);
    #leaf
  };

  /// Set type with a size attached to the root node of the rbtree.
  public type Set <T> = { size: Nat; root: Tree<T> };

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
      var set = empty() : Set<T>;
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
    public func put(rbSet : Set<T>, value : T) : Set<T> 
      = Internal.put(rbSet, compare, value);

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
    public func delete(rbSet : Set<T>, value : T) : Set<T> 
      = Internal.delete(rbSet, compare, value);

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
    public func contains(rbSet : Set<T>, value : T) : Bool 
      = Internal.contains(rbSet, compare, value);

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
    /// Runtime: `O(m * log(n))`.
    /// Space: `O(1)`, retained memory plus garbage, see the note below.
    /// where `m` and `n` denote the number of elements in the sets, and `m <= n`.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func union(rbSet1 : Set<T>, rbSet2 : Set<T>) : Set<T> {
      if (size rbSet1 < size rbSet2) {
        foldLeft(rbSet1, rbSet2, func (elem : T, acc : Set<T>) : Set<T> { Internal.put(acc, compare, elem) })
      }
      else {
        foldLeft(rbSet2, rbSet1, func (elem : T, acc : Set<T>) : Set<T> { Internal.put(acc, compare, elem) })
      }
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
    /// Runtime: `O(m * log(n))`.
    /// Space: `O(1)`, retained memory plus garbage, see the note below.
    /// where `m` and `n` denote the number of elements in the sets, and `m <= n`.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func intersect(rbSet1 : Set<T>, rbSet2 : Set<T>) : Set<T> {
      if (size rbSet1 < size rbSet2) {
        foldLeft(rbSet1, empty(),
          func (elem : T, acc : Set<T>) : Set<T> {
            if (Internal.contains(rbSet2, compare, elem)) { Internal.put(acc, compare, elem) } else { acc }
          }
        )
      }
      else {
        foldLeft(rbSet2, empty(),
          func (elem : T, acc : Set<T>) : Set<T> {
            if (Internal.contains(rbSet1, compare, elem)) { Internal.put(acc, compare, elem) } else { acc }
          }
        )
      }
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
    /// Runtime: `O(m * log(n))`.
    /// Space: `O(1)`, retained memory plus garbage, see the note below.
    /// where `m` and `n` denote the number of elements in the sets, and `m <= n`.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func diff(rbSet1 : Set<T>, rbSet2 : Set<T>) : Set<T> {
      if (size rbSet1 < size rbSet2) {
        foldLeft(rbSet1, empty(),
          func (elem : T, acc : Set<T>) : Set<T> {
            if (Internal.contains(rbSet2, compare, elem)) { acc } else { Internal.put(acc, compare, elem) }
          }
        )
      }
      else {
        foldLeft(rbSet2, rbSet1,
          func (elem : T, acc : Set<T>) : Set<T> {
            if (Internal.contains(acc, compare, elem)) { Internal.delete(acc, compare, elem) } else { acc }
          }
        )
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
    public func map<T1>(rbSet : Set<T1>, f : T1 -> T) : Set<T> = // TODO: optimize via direct recursion
      foldLeft(rbSet, empty(), func (elem : T1, acc : Set<T>) : Set<T> { put(acc, f elem) });

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
      func combine(elem : T1, acc : Set<T>) : Set<T> {
        switch (f(elem)){
          case null { acc };
          case (?elem2) {
            put(acc, elem2)
          }
        }
      };
      foldLeft(rbSet, empty(), combine)
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
      for (x in vals(rbSet1)) {
        if (not (contains(rbSet2, x))) {
          return false;
        }
      };
      return true;
    };
  };

  /// Returns an Iterator (`Iter`) over the elements of the set.
  /// Iterator provides a single method `next()`, which returns
  /// elements in ascending order, or `null` when out of elements to iterate over.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat";
  /// import Iter "mo:base/Iter";
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let rbSet = setOps.fromIter(Iter.fromArray([0, 2, 1]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Set.vals(rbSet))));
  ///
  /// // [0, 1, 2]
  /// ```
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of elements stored in the set.
  ///
  /// Note: Full set iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func vals<T>(s : Set<T>) : I.Iter<T> 
    = Internal.iter(s.root, #fwd);

  /// Same as `vals()` but iterates over elements of the set `s` in the descending order.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/PersistentOrderedSet";
  /// import Nat "mo:base/Nat";
  /// import Iter "mo:base/Iter";
  /// import Debug "mo:base/Debug";
  ///
  /// let setOps = Set.SetOps<Nat>(Nat.compare);
  /// let set = setOps.fromIter(Iter.fromArray([0, 2, 1]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Set.valsRev(set))));
  /// // [2, 1, 0]
  /// ```
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of elements stored in the set.
  ///
  /// Note: Full set iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func valsRev<T>(s : Set<T>) : I.Iter<T>
    = Internal.iter(s.root, #bwd);

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
  public func empty<T>() : Set<T> 
    = { root = #leaf; size = 0};

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
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func size<T>(s : Set<T>) : Nat
    = s.size;

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
    set : Set<T>,
    base : Accum,
    combine : (T, Accum) -> Accum
  ) : Accum
    = Internal.foldLeft(set.root, base, combine);

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
    set : Set<T>,
    base : Accum,
    combine : (T, Accum) -> Accum
  ) : Accum
    = Internal.foldRight(set.root, base, combine);

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
  public func isEmpty<T> (s : Set<T>) : Bool {
    switch (s.root) {
      case (#leaf) { true };
      case _ { false };
    };
  };

  module Internal {
    public func contains<T>(s : Set<T>, compare : (T, T) -> O.Order, elem : T) : Bool {
      func f (t: Tree<T>, x : T)  : Bool {
      switch t {
        case (#leaf) { false };
        case (#black(l, x1, r)) {
          switch (compare(x, x1)) {
            case (#less) { f(l, x) };
            case (#equal) { true };
            case (#greater) { f(r, x) }
          }
        };
        case (#red(l, x1, r)) {
          switch (compare(x, x1)) {
            case (#less) { f(l, x) };
            case (#equal) { true };
            case (#greater) { f(r, x) }
          }
        }
      }
      };
      f (s.root, elem);
    };

    type IterRep<T> = List.List<{ #tr : Tree<T>; #x : T }>;

    type SetTraverser<T> = (Tree<T>, T, Tree<T>, IterRep<T>) -> IterRep<T>;

    class IterSet<T>(tree : Tree<T>, setTraverser : SetTraverser<T>) {
      var trees : IterRep<T> = ?(#tr(tree), null);
      public func next() : ?T {
          switch (trees) {
            case (null) { null };
            case (?(#tr(#leaf), ts)) {
              trees := ts;
              next()
            };
            case (?(#x(x), ts)) {
              trees := ts;
              ?x
            };
            case (?(#tr(#black(l, x, r)), ts)) {
              trees := setTraverser(l, x, r, ts);
              next()
            };
            case (?(#tr(#red(l, x, r)), ts)) {
              trees := setTraverser(l, x, r, ts);
              next()
            }
          }
        }
    };

    public func iter<T>(s : Tree<T>, direction : {#fwd; #bwd}) : I.Iter<T> {
      let turnLeftFirst : SetTraverser<T>
      = func (l, x, r, ts) { ?(#tr(l), ?(#x(x), ?(#tr(r), ts))) };

      let turnRightFirst : SetTraverser<T>
      = func (l, x, r, ts) { ?(#tr(r), ?(#x(x), ?(#tr(l), ts))) };

      switch direction {
        case (#fwd) IterSet(s, turnLeftFirst);
        case (#bwd) IterSet(s, turnRightFirst)
      }
    };

    public func foldLeft<T, Accum>(
      tree : Tree<T>,
      base : Accum,
      combine : (T, Accum) -> Accum
    ) : Accum
    {
      switch (tree) {
        case (#leaf) { base };
        case (#black(l, x, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(x, left);
          foldLeft(r, middle, combine)
        };
        case (#red(l, x, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(x, left);
          foldLeft(r, middle, combine)
        }
      }
    };

    public func foldRight<T, Accum>(
      tree : Tree<T>,
      base : Accum,
      combine : (T, Accum) -> Accum
    ) : Accum
    {
      switch (tree) {
        case (#leaf) { base };
        case (#black (l, x, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(x, right);
          foldRight(l, middle, combine)
        };
        case (#red (l, x, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(x, right);
          foldRight(l, middle, combine)
        }
      }
    };

    func redden<T>(t : Tree<T>) : Tree<T> {
      switch t {
        case (#black (l, x, r)) {
          (#red (l, x, r))
        };
        case _ {
          Debug.trap "PersistentOrderedSet.red"
        }
      }
    };

    func lbalance<T>(left : Tree<T>, x : T, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (#red(#red(l1, x1, r1), x2, r2), r) {
          #red(
            #black(l1, x1, r1),
            x2,
            #black(r2, x, r))
        };
        case (#red(l1, x1, #red(l2, x2, r2)), r) {
          #red(
            #black(l1, x1, l2),
            x2,
            #black(r2, x, r))
        };
        case _ {
          #black(left, x, right)
        }
      }
    };

    func rbalance<T>(left : Tree<T>, x : T, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (l, #red(l1, x1, #red(l2, x2, r2))) {
          #red(
            #black(l, x, l1),
            x1,
            #black(l2, x2, r2))
        };
        case (l, #red(#red(l1, x1, r1), x2, r2)) {
          #red(
            #black(l, x, l1),
            x1,
            #black(r1, x2, r2))
        };
        case _ {
          #black(left, x, right)
        };
      }
    };

    public func put<T> (
      s : Set<T>,
      compare : (T, T) -> O.Order,
      elem : T,
    ) : Set<T> {
      var newNodeIsCreated: Bool = false;
      func ins(tree : Tree<T>) : Tree<T> {
        switch tree {
          case (#leaf) {
            newNodeIsCreated := true;
            #red(#leaf, elem, #leaf)
          };
          case (#black(left, x, right)) {
            switch (compare (elem, x)) {
              case (#less) {
                lbalance(ins left, x, right)
              };
              case (#greater) {
                rbalance(left, x, ins right)
              };
              case (#equal) {
                #black(left, x, right)
              }
            }
          };
          case (#red(left, x, right)) {
            switch (compare (elem, x)) {
              case (#less) {
                #red(ins left, x, right)
              };
              case (#greater) {
                #red(left, x, ins right)
              };
              case (#equal) {
                #red(left, x, right)
              }
            }
          }
        };
      };
      let newRoot = switch (ins(s.root)) {
        case (#red(left, x, right)) {
          #black(left, x, right);
        };
        case other { other };
      };
      { root = newRoot; 
        size = if newNodeIsCreated {s.size + 1} else {s.size}}
    };

    func balLeft<T>(left : Tree<T>, x : T, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (#red(l1, x1, r1), r) {
          #red(#black(l1, x1, r1), x, r)
        };
        case (_, #black(l2, x2, r2)) {
          rbalance(left, x, #red(l2, x2, r2))
        };
        case (_, #red(#black(l2, x2, r2), x3, r3)) {
          #red(
            #black(left, x, l2),
            x2,
            rbalance(r2, x3, redden r3))
        };
        case _ { Debug.trap "balLeft" };
      }
    };

    func balRight<T>(left : Tree<T>, x : T, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (l, #red(l1, x1, r1)) {
          #red(l, x, #black(l1, x1, r1))
        };
        case (#black(l1, x1, r1), r) {
          lbalance(#red(l1, x1, r1), x, r);
        };
        case (#red(l1, x1, #black(l2, x2, r2)), r3) {
          #red(
            lbalance(redden l1, x1, l2),
            x2,
            #black(r2, x, r3))
        };
        case _ { Debug.trap "balRight" };
      }
    };

    func append<T>(left : Tree<T>, right: Tree<T>) : Tree<T> {
      switch (left, right) {
        case (#leaf,  _) { right };
        case (_,  #leaf) { left };
        case (#red (l1, x1, r1),
              #red (l2, x2, r2)) {
               switch (append (r1, l2)) {
               case (#red (l3, x3, r3)) {
              #red(
                #red(l1, x1, l3),
                x3,
                #red(r3, x2, r2))
            };
            case r1l2 {
              #red(l1, x1, #red(r1l2, x2, r2))
            }
          }
        };
        case (t1, #red(l2, x2, r2)) {
          #red(append(t1, l2), x2, r2)
        };
        case (#red(l1, x1, r1), t2) {
          #red(l1, x1, append(r1, t2))
        };
        case (#black(l1, x1, r1), #black (l2, x2, r2)) {
          switch (append (r1, l2)) {
            case (#red (l3, x3, r3)) {
              #red(
                #black(l1, x1, l3),
                x3,
                #black(r3, x2, r2))
            };
            case r1l2 {
              balLeft (
                l1,
                x1,
                #black(r1l2, x2, r2)
              )
            }
          }
        }
      }
    };

    public func delete<T>(s : Set<T>, compare : (T, T) -> O.Order, x : T) : Set<T> {
      var changed : Bool = false;
      func delNode(left : Tree<T>, x1 : T, right : Tree<T>) : Tree<T> {
        switch (compare (x, x1)) {
          case (#less) {
            let newLeft = del left;
            switch left {
              case (#black(_, _, _)) {
                balLeft(newLeft, x1, right)
              };
              case _ {
                #red(newLeft, x1, right)
              }
            }
          };
          case (#greater) {
            let newRight = del right;
            switch right {
              case (#black(_, _, _)) {
                balRight(left, x1, newRight)
              };
              case _ {
                #red(left, x1, newRight)
              }
            }
          };
          case (#equal) {
            changed := true;
            append(left, right)
          };
        }
      };
      func del(tree : Tree<T>) : Tree<T> {
        switch tree {
          case (#leaf) {
            tree
          };
          case (#black(left, x1, right)) {
            delNode(left, x1, right)
          };
          case (#red(left, x1, right)) {
            delNode(left, x1, right)
          }
        };
      };
      let newRoot = switch (del(s.root)) {
        case (#red(left, x1, right)) {
          #black(left, x1, right);
        };
        case other { other };
      };
      { root = newRoot;
        size = if changed {s.size-1} else {s.size}}
    };
  }
}
