///Stable ordered set implemented as a red-black tree.
///
///A red-black tree is a balanced binary search tree ordered by the elements.
///
///The tree data structure internally colors each of its nodes either red or black,
///and uses this information to balance the tree during the modifying operations.
///
///| Runtime   | Space |
///|----------|------------|
///| `O(log(n))` (worst case per insertion, removal, or retrieval)  | `O(n)` (for storing the entire tree) |
///
///`n` denotes the number of key-value entries (i.e. nodes) stored in the tree.
///
///:::note [Garbage collection]
///
///Unless stated otherwise, operations that iterate over or modify the map (such as insertion, deletion, traversal, and transformation) may create temporary objects with worst-case space usage of `O(log(n))` or `O(n)`. These objects are short-lived and will be collected by the garbage collector automatically.
///
///:::
///
///:::note [Assumptions]
///
///Runtime and space complexity assumes that `compare`, `equal`, and other functions execute in `O(1)` time and space.
///:::
///
///:::info [Credits]
///
///The core of this implementation is derived from:
///
///* Ken Friis Larsen's [RedBlackMap.sml](https://github.com/kfl/mosml/blob/master/src/mosmllib/Redblackmap.sml), which itself is based on:
///* Stefan Kahrs, "Red-black trees with types", Journal of Functional Programming, 11(4): 425-432 (2001), [version 1 in web appendix](http://www.cs.ukc.ac.uk/people/staff/smk/redblack/rb.html).
///:::
///
import Debug "Debug";
import Buffer "Buffer";
import I "Iter";
import List "List";
import Nat "Nat";
import O "Order";

module {
  /// Red-black tree of nodes with ordered set elements.
  /// Leaves are considered implicitly black.
  type Tree<T> = {
    #red : (Tree<T>, T, Tree<T>);
    #black : (Tree<T>, T, Tree<T>);
    #leaf
  };

  /// Ordered collection of unique elements of the generic type `T`.
  /// If type `T` is stable then `Set<T>` is also stable.
  /// To ensure that property the `Set<T>` does not have any methods,
  /// instead they are gathered in the functor-like class `Operations` (see example there).
  public type Set<T> = { size : Nat; root : Tree<T> };

  /// Class that captures element type `T` along with its ordering function `compare`
  /// and provide all operations to work with a set of type `Set<T>`.
  ///
  /// An instance object should be created once as a canister field to ensure
  /// that the same ordering function is used for every operation.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/OrderedSet";
  /// import Nat "mo:base/Nat";
  ///
  /// actor {
  ///   let natSet = Set.Make<Nat>(Nat.compare); // : Operations<Nat>
  ///   stable var usedIds : Set.Set<Nat> = natSet.empty();
  ///
  ///   public func createId(id : Nat) : async () {
  ///     usedIds := natSet.put(usedIds, id);
  ///   };
  ///
  ///   public func idIsUsed(id: Nat) : async Bool {
  ///      natSet.contains(usedIds, id)
  ///   }
  /// }
  /// ```
  public class Operations<T>(compare : (T, T) -> O.Order) {

    /// Returns a new Set, containing all entries given by the iterator `i`.
    /// If there are multiple identical entries only one is taken.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(set))));
    /// // [0, 1, 2]
    /// ```
    ///
    ///| Runtime   | Space |
    ///|----------|------------|
    ///| `O(n * log(n))`  | `O(n)` (retained memory + garbage) |
    public func fromIter(i : I.Iter<T>) : Set<T> {
      var set = empty() : Set<T>;
      for (val in i) {
        set := Internal.put(set, compare, val)
      };
      set
    };

    /// Insert the value `value` into the set `s`. Has no effect if `value` is already
    /// present in the set. Returns a modified set.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// var set = natSet.empty();
    ///
    /// set := natSet.put(set, 0);
    /// set := natSet.put(set, 2);
    /// set := natSet.put(set, 1);
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(set))));
    /// // [0, 1, 2]
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(log(n))`.
    /// where `n` denotes the number of elements stored in the set and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: The returned set shares with the `s` most of the tree nodes.
    /// Garbage collecting one of sets (e.g. after an assignment `m := natSet.delete(m, k)`)
    /// causes collecting `O(log(n))` nodes.
    public func put(s : Set<T>, value : T) : Set<T> = Internal.put(s, compare, value);

    /// Deletes the value `value` from the set `s`. Has no effect if `value` is not
    /// present in the set. Returns modified set.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(natSet.delete(set, 1)))));
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(natSet.delete(set, 42)))));
    /// // [0, 2]
    /// // [0, 1, 2]
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(log(n))` | `O(log(n))`   |
    public func delete(s : Set<T>, value : T) : Set<T> = Internal.delete(s, compare, value);

    /// Test if the set 's' contains a given element.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show natSet.contains(set, 1)); // => true
    /// Debug.print(debug_show natSet.contains(set, 42)); // => false
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(log(n))` | `O(1)`   |
    public func contains(s : Set<T>, value : T) : Bool = Internal.contains(s.root, compare, value);

    /// Get a maximal element of the set `s` if it is not empty, otherwise returns `null`
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let s1 = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    /// let s2 = natSet.empty();
    ///
    /// Debug.print(debug_show(natSet.max(s1))); // => ?2
    /// Debug.print(debug_show(natSet.max(s2))); // => null
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(log(n))` | `O(1)`   |
    public func max(s : Set<T>) : ?T = Internal.max(s.root);

    /// Get a minimal element of the set `s` if it is not empty, otherwise returns `null`
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let s1 = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    /// let s2 = natSet.empty();
    ///
    /// Debug.print(debug_show(natSet.min(s1))); // => ?0
    /// Debug.print(debug_show(natSet.min(s2))); // => null
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(log(n))` | `O(log(1))`   |
    public func min(s : Set<T>) : ?T = Internal.min(s.root);

    /// [Set union](https://en.wikipedia.org/wiki/Union_(set_theory)) operation.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set1 = natSet.fromIter(Iter.fromArray([0, 1, 2]));
    /// let set2 = natSet.fromIter(Iter.fromArray([2, 3, 4]));
    ///
    /// Debug.print(debug_show Iter.toArray(natSet.vals(natSet.union(set1, set2))));
    /// // [0, 1, 2, 3, 4]
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(m* log(n))` | `O(m)`retained + garbage   |
    public func union(s1 : Set<T>, s2 : Set<T>) : Set<T> {
      if (size(s1) < size(s2)) {
        foldLeft(s1, s2, func(acc : Set<T>, elem : T) : Set<T> { Internal.put(acc, compare, elem) })
      } else {
        foldLeft(s2, s1, func(acc : Set<T>, elem : T) : Set<T> { Internal.put(acc, compare, elem) })
      }
    };

    /// [Set intersection](https://en.wikipedia.org/wiki/Intersection_(set_theory)) operation.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set1 = natSet.fromIter(Iter.fromArray([0, 1, 2]));
    /// let set2 = natSet.fromIter(Iter.fromArray([1, 2, 3]));
    ///
    /// Debug.print(debug_show Iter.toArray(natSet.vals(natSet.intersect(set1, set2))));
    /// // [1, 2]
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(m* log(n))` | `O(m)`retained + garbage   |
    ///
    /// Note: Creates `O(m)` temporary objects that will be collected as garbage.
    public func intersect(s1 : Set<T>, s2 : Set<T>) : Set<T> {
      let elems = Buffer.Buffer<T>(Nat.min(Nat.min(s1.size, s2.size), 100));
      if (s1.size < s2.size) {
        Internal.iterate(
          s1.root,
          func(x : T) {
            if (Internal.contains(s2.root, compare, x)) {
              elems.add(x)
            }
          }
        )
      } else {
        Internal.iterate(
          s2.root,
          func(x : T) {
            if (Internal.contains(s1.root, compare, x)) {
              elems.add(x)
            }
          }
        )
      };
      { root = Internal.buildFromSorted(elems); size = elems.size() }
    };

    /// [Set difference](https://en.wikipedia.org/wiki/Difference_(set_theory)).
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set1 = natSet.fromIter(Iter.fromArray([0, 1, 2]));
    /// let set2 = natSet.fromIter(Iter.fromArray([1, 2, 3]));
    ///
    /// Debug.print(debug_show Iter.toArray(natSet.vals(natSet.diff(set1, set2))));
    /// // [0]
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(m* log(n))` | `O(m)`retained + garbage   |
    public func diff(s1 : Set<T>, s2 : Set<T>) : Set<T> {
      if (size(s1) < size(s2)) {
        let elems = Buffer.Buffer<T>(Nat.min(s1.size, 100));
        Internal.iterate(
          s1.root,
          func(x : T) {
            if (not Internal.contains(s2.root, compare, x)) {
              elems.add(x)
            }
          }
        );
        { root = Internal.buildFromSorted(elems); size = elems.size() }
      } else {
        foldLeft(
          s2,
          s1,
          func(acc : Set<T>, elem : T) : Set<T> {
            if (Internal.contains(acc.root, compare, elem)) {
              Internal.delete(acc, compare, elem)
            } else { acc }
          }
        )
      }
    };

    /// Creates a new `Set` by applying `f` to each entry in the set `s`. Each element
    /// `x` in the old set is transformed into a new entry `x2`, where
    /// the new value `x2` is created by applying `f` to `x`.
    /// The result set may be smaller than the original set due to duplicate elements.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 1, 2, 3]));
    ///
    /// func f(x : Nat) : Nat = if (x < 2) { x } else { 0 };
    ///
    /// let resSet = natSet.map(set, f);
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(resSet))));
    /// // [0, 1]
    /// ```
    ///
    /// Cost of mapping all the elements:
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(n* log(n))` | `O(n)`retained + garbage   |
    public func map<T1>(s : Set<T1>, f : T1 -> T) : Set<T> = Internal.foldLeft(s.root, empty(), func(acc : Set<T>, elem : T1) : Set<T> { Internal.put(acc, compare, f(elem)) });

    /// Creates a new set by applying `f` to each element in the set `s`. For each element
    /// `x` in the old set, if `f` evaluates to `null`, the element is discarded.
    /// Otherwise, the entry is transformed into a new entry `x2`, where
    /// the new value `x2` is the result of applying `f` to `x`.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 1, 2, 3]));
    ///
    /// func f(x : Nat) : ?Nat {
    ///   if(x == 0) {null}
    ///   else { ?( x * 2 )}
    /// };
    ///
    /// let newRbSet = natSet.mapFilter(set, f);
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(newRbSet))));
    /// // [2, 4, 6]
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(n* log(n))` | `O(n)`retained + garbage   |
    public func mapFilter<T1>(s : Set<T1>, f : T1 -> ?T) : Set<T> {
      func combine(acc : Set<T>, elem : T1) : Set<T> {
        switch (f(elem)) {
          case null { acc };
          case (?elem2) {
            Internal.put(acc, compare, elem2)
          }
        }
      };
      Internal.foldLeft(s.root, empty(), combine)
    };

    /// Test if `set1` is subset of `set2`.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set1 = natSet.fromIter(Iter.fromArray([1, 2]));
    /// let set2 = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show natSet.isSubset(set1, set2)); // => true
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(n* log(n))` | `O(1)`   |
    public func isSubset(s1 : Set<T>, s2 : Set<T>) : Bool {
      if (s1.size > s2.size) { return false };
      isSubsetHelper(s1.root, s2.root)
    };

    /// Test if two sets are equal.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set1 = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    /// let set2 = natSet.fromIter(Iter.fromArray([1, 2]));
    ///
    /// Debug.print(debug_show natSet.equals(set1, set1)); // => true
    /// Debug.print(debug_show natSet.equals(set1, set2)); // => false
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(m * log(n))` | `O(1)`   |
    public func equals(s1 : Set<T>, s2 : Set<T>) : Bool {
      if (s1.size != s2.size) { return false };
      isSubsetHelper(s1.root, s2.root)
    };

    func isSubsetHelper(t1 : Tree<T>, t2 : Tree<T>) : Bool {
      switch (t1, t2) {
        case (#leaf, _) { true };
        case (_, #leaf) { false };
        case ((#red(t1l, x1, t1r) or #black(t1l, x1, t1r)), (#red(t2l, x2, t2r)) or #black(t2l, x2, t2r)) {
          switch (compare(x1, x2)) {
            case (#equal) {
              isSubsetHelper(t1l, t2l) and isSubsetHelper(t1r, t2r)
            };
            // x1 < x2 ==> x1 \in t2l /\ t1l \subset t2l
            case (#less) {
              Internal.contains(t2l, compare, x1) and isSubsetHelper(t1l, t2l) and isSubsetHelper(t1r, t2)
            };
            // x2 < x1 ==> x1 \in t2r /\ t1r \subset t2r
            case (#greater) {
              Internal.contains(t2r, compare, x1) and isSubsetHelper(t1l, t2) and isSubsetHelper(t1r, t2r)
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
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.vals(set))));
    /// // [0, 1, 2]
    /// ```

    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(n)` | `O(log(n))` retained + garbage  |
    public func vals(s : Set<T>) : I.Iter<T> = Internal.iter(s.root, #fwd);

    /// Same as `vals()` but iterates over elements of the set `s` in the descending order.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(Iter.toArray(natSet.valsRev(set))));
    /// // [2, 1, 0]
    /// ```

    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(n)` | `O(log(n))` retained + garbage  |
    public func valsRev(s : Set<T>) : I.Iter<T> = Internal.iter(s.root, #bwd);

    /// Create a new empty Set.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.empty();
    ///
    /// Debug.print(debug_show(natSet.size(set))); // => 0
    /// ```
    ///
    /// Cost of empty set creation
    /// Runtime: `O(1)`.
    /// Space: `O(1)`
    public func empty() : Set<T> = { root = #leaf; size = 0 };

    /// Returns the number of elements in the set.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(natSet.size(set))); // => 3
    /// ```
    ///
    ///| Runtime     | Space         |
    ///|-------------|---------------|
    ///| `O(1)` | `O(1)` |
    public func size(s : Set<T>) : Nat = s.size;

    /// Collapses the elements in `set` into a single value by starting with `base`
    /// and progessively combining elements into `base` with `combine`. Iteration runs
    /// left to right.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// func folder(accum : Nat, val : Nat) : Nat = val + accum;
    ///
    /// Debug.print(debug_show(natSet.foldLeft(set, 0, folder)));
    /// // 3
    /// ```
    ///

    ///| Runtime | Space                        |
    ///|---------|------------------------------|
    ///| `O(n)`  | Depends on `combine` + `O(n)` garbage |
    public func foldLeft<Accum>(
      set : Set<T>,
      base : Accum,
      combine : (Accum, T) -> Accum
    ) : Accum = Internal.foldLeft(set.root, base, combine);

    /// Collapses the elements in `set` into a single value by starting with `base`
    /// and progessively combining elements into `base` with `combine`. Iteration runs
    /// right to left.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// func folder(val : Nat, accum : Nat) : Nat = val + accum;
    ///
    /// Debug.print(debug_show(natSet.foldRight(set, 0, folder)));
    /// // 3
    /// ```
    ///

    ///| Runtime | Space                        |
    ///|---------|------------------------------|
    ///| `O(n)`  | Depends on `combine` + `O(n)` garbage |
    public func foldRight<Accum>(
      set : Set<T>,
      base : Accum,
      combine : (T, Accum) -> Accum
    ) : Accum = Internal.foldRight(set.root, base, combine);

    /// Test if the given set `s` is empty.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.empty();
    ///
    /// Debug.print(debug_show(natSet.isEmpty(set))); // => true
    /// ```
    ///
    /// Runtime: `O(1)`.
    /// Space: `O(1)`.
    public func isEmpty(s : Set<T>) : Bool {
      switch (s.root) {
        case (#leaf) { true };
        case _ { false }
      }
    };

    /// Test whether all values in the set `s` satisfy a given predicate `pred`.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(natSet.all(set, func (v) = (v < 10))));
    /// // true
    /// Debug.print(debug_show(natSet.all(set, func (v) = (v < 2))));
    /// // false
    /// ```
    ///
    ///| Runtime | Space                        |
    ///|---------|------------------------------|
    ///| `O(n)`  | `O(n)` |
    public func all(s : Set<T>, pred : T -> Bool) : Bool = Internal.all(s.root, pred);

    /// Test if there exists an element in the set `s` satisfying the given predicate `pred`.
    ///
    /// Example:
    /// ```motoko
    /// import Set "mo:base/OrderedSet";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let natSet = Set.Make<Nat>(Nat.compare);
    /// let set = natSet.fromIter(Iter.fromArray([0, 2, 1]));
    ///
    /// Debug.print(debug_show(natSet.some(set, func (v) = (v >= 3))));
    /// // false
    /// Debug.print(debug_show(natSet.some(set, func (v) = (v >= 0))));
    /// // true
    /// ```
    ///
    ///| Runtime | Space                        |
    ///|---------|------------------------------|
    ///| `O(n)`  | `O(1)` |
    public func some(s : Set<T>, pred : (T) -> Bool) : Bool = Internal.some(s.root, pred);

    /// Test helper that check internal invariant for the given set `s`.
    /// Raise an error (for a stack trace) if invariants are violated.
    public func validate(s : Set<T>) : () {
      Internal.validate(s, compare)
    }
  };

  module Internal {
    public func contains<T>(tree : Tree<T>, compare : (T, T) -> O.Order, elem : T) : Bool {
      func f(t : Tree<T>, x : T) : Bool {
        switch t {
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
          };
          case (#leaf) { false }
        }
      };
      f(tree, elem)
    };

    public func max<V>(m : Tree<V>) : ?V {
      func rightmost(m : Tree<V>) : V {
        switch m {
          case (#red(_, v, #leaf)) { v };
          case (#red(_, _, r)) { rightmost(r) };
          case (#black(_, v, #leaf)) { v };
          case (#black(_, _, r)) { rightmost(r) };
          case (#leaf) { Debug.trap "OrderedSet.impossible" }
        }
      };
      switch m {
        case (#leaf) { null };
        case (_) { ?rightmost(m) }
      }
    };

    public func min<V>(m : Tree<V>) : ?V {
      func leftmost(m : Tree<V>) : V {
        switch m {
          case (#red(#leaf, v, _)) { v };
          case (#red(l, _, _)) { leftmost(l) };
          case (#black(#leaf, v, _)) { v };
          case (#black(l, _, _)) { leftmost(l) };
          case (#leaf) { Debug.trap "OrderedSet.impossible" }
        }
      };
      switch m {
        case (#leaf) { null };
        case (_) { ?leftmost(m) }
      }
    };

    public func all<V>(m : Tree<V>, pred : V -> Bool) : Bool {
      switch m {
        case (#red(l, v, r)) {
          pred(v) and all(l, pred) and all(r, pred)
        };
        case (#black(l, v, r)) {
          pred(v) and all(l, pred) and all(r, pred)
        };
        case (#leaf) { true }
      }
    };

    public func some<V>(m : Tree<V>, pred : V -> Bool) : Bool {
      switch m {
        case (#red(l, v, r)) {
          pred(v) or some(l, pred) or some(r, pred)
        };
        case (#black(l, v, r)) {
          pred(v) or some(l, pred) or some(r, pred)
        };
        case (#leaf) { false }
      }
    };

    public func iterate<V>(m : Tree<V>, f : V -> ()) {
      switch m {
        case (#leaf) {};
        case (#black(l, v, r)) { iterate(l, f); f(v); iterate(r, f) };
        case (#red(l, v, r)) { iterate(l, f); f(v); iterate(r, f) }
      }
    };

    // build tree from elements arr[l]..arr[r-1]
    public func buildFromSorted<V>(buf : Buffer.Buffer<V>) : Tree<V> {
      var maxDepth = 0;
      var maxSize = 1;
      while (maxSize < buf.size()) {
        maxDepth += 1;
        maxSize += maxSize + 1
      };
      maxDepth := if (maxDepth == 0) { 1 } else { maxDepth }; // keep root black for 1 element tree
      func buildFromSortedHelper(l : Nat, r : Nat, depth : Nat) : Tree<V> {
        if (l + 1 == r) {
          if (depth == maxDepth) {
            return #red(#leaf, buf.get(l), #leaf)
          } else {
            return #black(#leaf, buf.get(l), #leaf)
          }
        };
        if (l >= r) {
          return #leaf
        };
        let m = (l + r) / 2;
        return #black(
          buildFromSortedHelper(l, m, depth +1),
          buf.get(m),
          buildFromSortedHelper(m +1, r, depth +1)
        )
      };
      buildFromSortedHelper(0, buf.size(), 0)
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

    public func iter<T>(s : Tree<T>, direction : { #fwd; #bwd }) : I.Iter<T> {
      let turnLeftFirst : SetTraverser<T> = func(l, x, r, ts) {
        ?(#tr(l), ?(#x(x), ?(#tr(r), ts)))
      };

      let turnRightFirst : SetTraverser<T> = func(l, x, r, ts) {
        ?(#tr(r), ?(#x(x), ?(#tr(l), ts)))
      };

      switch direction {
        case (#fwd) IterSet(s, turnLeftFirst);
        case (#bwd) IterSet(s, turnRightFirst)
      }
    };

    public func foldLeft<T, Accum>(
      tree : Tree<T>,
      base : Accum,
      combine : (Accum, T) -> Accum
    ) : Accum {
      switch (tree) {
        case (#leaf) { base };
        case (#black(l, x, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(left, x);
          foldLeft(r, middle, combine)
        };
        case (#red(l, x, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(left, x);
          foldLeft(r, middle, combine)
        }
      }
    };

    public func foldRight<T, Accum>(
      tree : Tree<T>,
      base : Accum,
      combine : (T, Accum) -> Accum
    ) : Accum {
      switch (tree) {
        case (#leaf) { base };
        case (#black(l, x, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(x, right);
          foldRight(l, middle, combine)
        };
        case (#red(l, x, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(x, right);
          foldRight(l, middle, combine)
        }
      }
    };

    func redden<T>(t : Tree<T>) : Tree<T> {
      switch t {
        case (#black(l, x, r)) { (#red(l, x, r)) };
        case _ {
          Debug.trap "OrderedSet.red"
        }
      }
    };

    func lbalance<T>(left : Tree<T>, x : T, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (#red(#red(l1, x1, r1), x2, r2), r) {
          #red(
            #black(l1, x1, r1),
            x2,
            #black(r2, x, r)
          )
        };
        case (#red(l1, x1, #red(l2, x2, r2)), r) {
          #red(
            #black(l1, x1, l2),
            x2,
            #black(r2, x, r)
          )
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
            #black(l2, x2, r2)
          )
        };
        case (l, #red(#red(l1, x1, r1), x2, r2)) {
          #red(
            #black(l, x, l1),
            x1,
            #black(r1, x2, r2)
          )
        };
        case _ {
          #black(left, x, right)
        }
      }
    };

    public func put<T>(
      s : Set<T>,
      compare : (T, T) -> O.Order,
      elem : T
    ) : Set<T> {
      var newNodeIsCreated : Bool = false;
      func ins(tree : Tree<T>) : Tree<T> {
        switch tree {
          case (#black(left, x, right)) {
            switch (compare(elem, x)) {
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
            switch (compare(elem, x)) {
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
          };
          case (#leaf) {
            newNodeIsCreated := true;
            #red(#leaf, elem, #leaf)
          }
        }
      };
      let newRoot = switch (ins(s.root)) {
        case (#red(left, x, right)) {
          #black(left, x, right)
        };
        case other { other }
      };
      {
        root = newRoot;
        size = if newNodeIsCreated { s.size + 1 } else { s.size }
      }
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
            rbalance(r2, x3, redden r3)
          )
        };
        case _ { Debug.trap "balLeft" }
      }
    };

    func balRight<T>(left : Tree<T>, x : T, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (l, #red(l1, x1, r1)) {
          #red(l, x, #black(l1, x1, r1))
        };
        case (#black(l1, x1, r1), r) {
          lbalance(#red(l1, x1, r1), x, r)
        };
        case (#red(l1, x1, #black(l2, x2, r2)), r3) {
          #red(
            lbalance(redden l1, x1, l2),
            x2,
            #black(r2, x, r3)
          )
        };
        case _ { Debug.trap "balRight" }
      }
    };

    func append<T>(left : Tree<T>, right : Tree<T>) : Tree<T> {
      switch (left, right) {
        case (#leaf, _) { right };
        case (_, #leaf) { left };
        case (
          #red(l1, x1, r1),
          #red(l2, x2, r2)
        ) {
          switch (append(r1, l2)) {
            case (#red(l3, x3, r3)) {
              #red(
                #red(l1, x1, l3),
                x3,
                #red(r3, x2, r2)
              )
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
        case (#black(l1, x1, r1), #black(l2, x2, r2)) {
          switch (append(r1, l2)) {
            case (#red(l3, x3, r3)) {
              #red(
                #black(l1, x1, l3),
                x3,
                #black(r3, x2, r2)
              )
            };
            case r1l2 {
              balLeft(
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
        switch (compare(x, x1)) {
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
          }
        }
      };
      func del(tree : Tree<T>) : Tree<T> {
        switch tree {
          case (#black(left, x1, right)) {
            delNode(left, x1, right)
          };
          case (#red(left, x1, right)) {
            delNode(left, x1, right)
          };
          case (#leaf) {
            tree
          }
        }
      };
      let newRoot = switch (del(s.root)) {
        case (#red(left, x1, right)) {
          #black(left, x1, right)
        };
        case other { other }
      };
      {
        root = newRoot;
        size = if changed { s.size -1 } else { s.size }
      }
    };

    // check binary search tree order of elements and black depth invariant of the RB-tree
    public func validate<T>(s : Set<T>, comp : (T, T) -> O.Order) {
      ignore blackDepth(s.root, comp)
    };

    func blackDepth<T>(node : Tree<T>, comp : (T, T) -> O.Order) : Nat {
      func checkNode(left : Tree<T>, x1 : T, right : Tree<T>) : Nat {
        checkElem(left, func(x : T) : Bool { comp(x, x1) == #less });
        checkElem(right, func(x : T) : Bool { comp(x, x1) == #greater });
        let leftBlacks = blackDepth(left, comp);
        let rightBlacks = blackDepth(right, comp);
        assert (leftBlacks == rightBlacks);
        leftBlacks
      };
      switch node {
        case (#leaf) 0;
        case (#red(left, x1, right)) {
          assert (not isRed(left));
          assert (not isRed(right));
          checkNode(left, x1, right)
        };
        case (#black(left, x1, right)) {
          checkNode(left, x1, right) + 1
        }
      }
    };

    func isRed<T>(node : Tree<T>) : Bool {
      switch node {
        case (#red(_, _, _)) true;
        case _ false
      }
    };

    func checkElem<T>(node : Tree<T>, isValid : T -> Bool) {
      switch node {
        case (#leaf) {};
        case (#black(_, elem, _)) {
          assert (isValid(elem))
        };
        case (#red(_, elem, _)) {
          assert (isValid(elem))
        }
      }
    }
  };

  /// Create `OrderedSet.Operations` object capturing element type `T` and `compare` function.
  /// It is an alias for the `Operations` constructor.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/OrderedSet";
  /// import Nat "mo:base/Nat";
  ///
  /// actor {
  ///   let natSet = Set.Make<Nat>(Nat.compare);
  ///   stable var set : Set.Set<Nat> = natSet.empty();
  /// };
  /// ```
  public let Make : <T>(compare : (T, T) -> O.Order) -> Operations<T> = Operations
}
