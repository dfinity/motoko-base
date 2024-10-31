/// Stable key-value map implemented as a red-black tree with nodes storing key-value pairs.
///
/// A red-black tree is a balanced binary search tree ordered by the keys.
///
/// The tree data structure internally colors each of its nodes either red or black,
/// and uses this information to balance the tree during the modifying operations.
///
/// Performance:
/// * Runtime: `O(log(n))` worst case cost per insertion, removal, and retrieval operation.
/// * Space: `O(n)` for storing the entire tree.
/// `n` denotes the number of key-value entries (i.e. nodes) stored in the tree.
///
/// Note:
/// * Map operations, such as retrieval, insertion, and removal create `O(log(n))` temporary objects that become garbage.
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
import O "Order";

module {

  /// Red-black tree of nodes with key-value entries, ordered by the keys.
  /// The keys have the generic type `K` and the values the generic type `V`.
  /// Leaves are considered implicitly black.
  public type Map<K, V> = {
    size: Nat;
    root: Tree<K, V>;
  };

  public type Tree<K, V> = {
    #red : (Tree<K, V>, K, V, Tree<K, V>);
    #black : (Tree<K, V>, K, V, Tree<K, V>);
    #leaf
  };

  /// Operations on `Map`, that require a comparator.
  ///
  /// The object should be created once, then used for all the operations
  /// with `Map` to ensure that the same comparator is used for every operation.
  ///
  /// `MapOps` contains methods that require `compare` internally:
  /// operations that may reshape a `Map` or should find something.
  public class MapOps<K>(compare : (K, K) -> O.Order) {

    /// Returns a new map, containing all entries given by the iterator `i`.
    /// If there are multiple entries with the same key the last one is taken.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let m = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(m))));
    ///
    /// // [(0, "Zero"), (1, "One"), (2, "Two")]
    /// ```
    ///
    /// Runtime: `O(n * log(n))`.
    /// Space: `O(n)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(n * log(n))` temporary objects that will be collected as garbage.
    public func fromIter<V>(i : I.Iter<(K, V)>) : Map<K, V>
      = Internal.fromIter(i, compare);

    /// Insert the value `value` with key `key` into the map `m`. Overwrites any existing entry with key `key`.
    /// Returns a modified map.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// var map = Map.empty<Text>();
    ///
    /// map := mapOps.put(map, 0, "Zero");
    /// map := mapOps.put(map, 2, "Two");
    /// map := mapOps.put(map, 1, "One");
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(map))));
    ///
    /// // [(0, "Zero"), (1, "One"), (2, "Two")]
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func put<V>(m : Map<K, V>, key : K, value : V) : Map<K, V>
      = replace(m, key, value).0;

    /// Insert the value `value` with key `key` into the map `m`. Returns modified map and
    /// the previous value associated with key `key` or `null` if no such value exists.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map0 = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// let (map1, old1) = mapOps.replace(map0, 0, "Nil");
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(map1))));
    /// Debug.print(debug_show(old1));
    /// // [(0, "Nil"), (1, "One"), (2, "Two")]
    /// // ?"Zero"
    ///
    /// let (map2, old2) = mapOps.replace(map0, 3, "Three");
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(map2))));
    /// Debug.print(debug_show(old2));
    /// // [(0, "Zero"), (1, "One"), (2, "Two"), (3, "Three")]
    /// // null
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func replace<V>(m : Map<K, V>, key : K, value : V) : (Map<K, V>, ?V) {
      switch (Internal.replace(m.root, compare, key, value)) {
        case (t, null) { ({root = t; size = m.size + 1}, null) };
        case (t, v)    { ({root = t; size = m.size}, v)}
      }
    };

    /// Creates a new map by applying `f` to each entry in the map `m`. For each entry
    /// `(k, v)` in the old map, if `f` evaluates to `null`, the entry is discarded.
    /// Otherwise, the entry is transformed into a new entry `(k, v2)`, where
    /// the new value `v2` is the result of applying `f` to `(k, v)`.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// func f(key : Nat, val : Text) : ?Text {
    ///   if(key == 0) {null}
    ///   else { ?("Twenty " # val)}
    /// };
    ///
    /// let newMap = mapOps.mapFilter(map, f);
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(newMap))));
    ///
    /// // [(1, "Twenty One"), (2, "Twenty Two")]
    /// ```
    ///
    /// Runtime: `O(n)`.
    /// Space: `O(n)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func mapFilter<V1, V2>(m : Map<K, V1>, f : (K, V1) -> ?V2) : Map<K, V2>
      = Internal.mapFilter(m, compare, f);

    /// Get the value associated with key `key` in the given map `m` if present and `null` otherwise.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(mapOps.get(map, 1)));
    /// Debug.print(debug_show(mapOps.get(map, 42)));
    ///
    /// // ?"One"
    /// // null
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    public func get<V>(m : Map<K, V>, key : K) : ?V
      = Internal.get(m.root, compare, key);

    /// Test whether the map `m` contains any binding for the given `key`.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show mapOps.contains(map, 1)); // => true
    /// Debug.print(debug_show mapOps.contains(map, 42)); // => false
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    public func contains<V>(m: Map<K, V>, key: K): Bool 
      = Internal.contains(m.root, compare, key);

    /// Retrieves a key-value pair from the map `m` with a maximal key. If the map is empty returns `null`.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(mapOps.maxEntry(map))); // => ?(2, "Two")
    /// Debug.print(debug_show(mapOps.maxEntry(mapOps.empty()))); // => null
    /// ```
    ///
    /// Runtime: `O(log(n))`
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the map.
    public func maxEntry<V>(m: Map<K, V>): ?(K, V)
      = Internal.maxEntry(m.root);

    /// Retrieves a key-value pair from the map `m` with a minimal key. If the map is empty returns `null`.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(mapOps.minEntry(map))); // => ?(0, "Zero")
    /// Debug.print(debug_show(mapOps.minEntry(mapOps.empty()))); // => null
    /// ```
    ///
    /// Runtime: `O(log(n))`
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the map.
    public func minEntry<V>(m: Map<K, V>): ?(K, V)
      = Internal.minEntry(m.root);

    /// Deletes the entry with the key `key` from the map `m`. Has no effect if `key` is not
    /// present in the map. Returns modified map.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(mapOps.delete(map, 1)))));
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(mapOps.delete(map, 42)))));
    ///
    /// // [(0, "Zero"), (2, "Two")]
    /// // [(0, "Zero"), (1, "One"), (2, "Two")]
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func delete<V>(m : Map<K, V>, key : K) : Map<K, V>
      = remove(m, key).0;

    /// Deletes the entry with the key `key`. Returns modified map and the
    /// previous value associated with key `key` or `null` if no such value exists.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map0 = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// let (map1, old1) = mapOps.remove(map0, 0);
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(map1))));
    /// Debug.print(debug_show(old1));
    /// // [(1, "One"), (2, "Two")]
    /// // ?"Zero"
    ///
    /// let (map2, old2) = mapOps.remove(map0, 42);
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(map2))));
    /// Debug.print(debug_show(old2));
    /// // [(0, "Zero"), (1, "One"), (2, "Two")]
    /// // null
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func remove<V>(m : Map<K, V>, key : K) : (Map<K, V>, ?V) {
      switch (Internal.remove(m.root, compare, key)) {
        case (t, null) { ({root = t; size = m.size }, null) };
        case (t, v)    { ({root = t; size = m.size - 1}, v) }
      }
    };

    /// Create a new empty map.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    ///
    /// let map = mapOps.empty<Text>();
    ///
    /// Debug.print(debug_show(mapOps.size(map)));
    ///
    /// // 0
    /// ```
    ///
    /// Cost of empty map creation
    /// Runtime: `O(1)`.
    /// Space: `O(1)`
    public func empty<V>() : Map<K, V> 
      = Internal.empty();

    /// Returns an Iterator (`Iter`) over the key-value pairs in the map.
    /// Iterator provides a single method `next()`, which returns
    /// pairs in ascending order by keys, or `null` when out of pairs to iterate over.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(map))));
    /// // [(0, "Zero"), (1, "One"), (2, "Two")]
    /// var sum = 0;
    /// for ((k, _) in map.entries()) { sum += k; }
    /// Debug.print(debug_show(sum)); // => 3
    /// ```
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: `O(log(n))` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map.
    ///
    /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func entries<V>(m : Map<K, V>) : I.Iter<(K, V)> = Internal.iter(m.root, #fwd);

    /// Same as `entries` but iterates in the descending order.
    public func entriesRev<V>(m : Map<K, V>) : I.Iter<(K, V)> = Internal.iter(m.root, #bwd);

    /// Returns an Iterator (`Iter`) over the keys of the map.
    /// Iterator provides a single method `next()`, which returns
    /// keys in ascending order, or `null` when out of keys to iterate over.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.keys(map))));
    ///
    /// // [0, 1, 2]
    /// ```
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: `O(log(n))` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map.
    ///
    /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func keys<V>(m : Map<K, V>) : I.Iter<K>
      = I.map(entries(m), func(kv : (K, V)) : K {kv.0});


    /// Returns an Iterator (`Iter`) over the values of the map.
    /// Iterator provides a single method `next()`, which returns
    /// values in no specific order, or `null` when out of values to iterate over.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.vals(map))));
    ///
    /// // ["Zero", "One", "Two"]
    /// ```
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: `O(log(n))` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map.
    ///
    /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func vals<V>(m : Map<K, V>) : I.Iter<V>
      = I.map(entries(m), func(kv : (K, V)) : V {kv.1});

    /// Creates a new map by applying `f` to each entry in the map `m`. Each entry
    /// `(k, v)` in the old map is transformed into a new entry `(k, v2)`, where
    /// the new value `v2` is created by applying `f` to `(k, v)`.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// func f(key : Nat, _val : Text) : Nat = key * 2;
    ///
    /// let resMap = mapOps.map(map, f);
    ///
    /// Debug.print(debug_show(Iter.toArray(mapOps.entries(resMap))));
    /// // [(0, 0), (1, 2), (2, 4)]
    /// ```
    ///
    /// Cost of mapping all the elements:
    /// Runtime: `O(n)`.
    /// Space: `O(n)` retained memory
    /// where `n` denotes the number of key-value entries stored in the map.
    public func map<V1, V2>(m : Map<K, V1>, f : (K, V1) -> V2) : Map<K, V2>
      = Internal.map(m, f);

    /// Determine the size of the map as the number of key-value entries.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(mapOps.size(map)));
    ///
    /// // 3
    /// ```
    ///
    /// Runtime: `O(n)`.
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the tree.
    public func size<V>(m : Map<K, V>) : Nat
      = m.size;

    /// Collapses the elements in the `map` into a single value by starting with `base`
    /// and progressively combining keys and values into `base` with `combine`. Iteration runs
    /// left to right.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// func folder(key : Nat, val : Text, accum : (Nat, Text)) : ((Nat, Text))
    ///   = (key + accum.0, accum.1 # val);
    ///
    /// Debug.print(debug_show(mapOps.foldLeft(map, (0, ""), folder)));
    ///
    /// // (3, "ZeroOneTwo")
    /// ```
    ///
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: depends on `combine` function plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map.
    ///
    /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func foldLeft<Value, Accum>(
      map : Map<K, Value>,
      base : Accum,
      combine : (K, Value, Accum) -> Accum
    ) : Accum
    = Internal.foldLeft(map.root, base, combine);

    /// Collapses the elements in the `map` into a single value by starting with `base`
    /// and progressively combining keys and values into `base` with `combine`. Iteration runs
    /// right to left.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Iter "mo:base/Iter";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// func folder(key : Nat, val : Text, accum : (Nat, Text)) : ((Nat, Text))
    ///   = (key + accum.0, accum.1 # val);
    ///
    /// Debug.print(debug_show(mapOps.foldRight(map, (0, ""), folder)));
    ///
    /// // (3, "TwoOneZero")
    /// ```
    ///
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: depends on `combine` function plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map.
    ///
    /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func foldRight<Value, Accum>(
      map : Map<K, Value>,
      base : Accum,
      combine : (K, Value, Accum) -> Accum
    ) : Accum
    = Internal.foldRight(map.root, base, combine);

    /// Test whether all key-value pairs satisfy a given predicate `pred`.
    ///
    /// Example:
    /// ```
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "0"), (2, "2"), (1, "1")]));
    ///
    /// Debug.print(debug_show(mapOps.all(map, func (k, v) = (v == debug_show(k)))));
    /// // true
    /// Debug.print(debug_show(mapOps.all(map, func (k, v) = (k < 2))));
    /// // false
    /// ```
    ///
    /// Runtime: `O(n)`.
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the tree.
    public func all<V>(m: Map<K, V>, pred: (K, V) -> Bool): Bool
      = Internal.all(m.root, pred);

    /// Test if there exists a key-value pair satisfying a given predicate `pred`.
    ///
    /// Example:
    /// ```
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat";
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "0"), (2, "2"), (1, "1")]));
    ///
    /// Debug.print(debug_show(mapOps.some(map, func (k, v) = (k >= 3))));
    /// // false
    /// Debug.print(debug_show(mapOps.some(map, func (k, v) = (k >= 0))));
    /// // true
    /// ```
    ///
    /// Runtime: `O(n)`.
    /// Space: `O(1)`.
    /// where `n` denotes the number of key-value entries stored in the tree.
    public func some<V>(m: Map<K, V>, pred: (K, V) -> Bool): Bool
      = Internal.some(m.root, pred);
  };

  module Internal {

    public func empty<K, V>(): Map<K, V> {
      { size = 0; root = #leaf }
    };

    public func fromIter<K, V>(i : I.Iter<(K,V)>, compare : (K, K) -> O.Order) : Map<K, V> {
      var map = #leaf : Tree<K, V>;
      var size = 0;
      for(val in i) {
        map := put(map, compare, val.0, val.1);
        size += 1;
      };
      {root = map; size}
    };

    type IterRep<K, V> = List.List<{ #tr : Tree<K, V>; #xy : (K, V) }>;

    public func iter<K, V>(map : Tree<K, V>, direction : { #fwd; #bwd }) : I.Iter<(K, V)> {
      let turnLeftFirst : MapTraverser<K, V>
      = func (l, x, y, r, ts) { ?(#tr(l), ?(#xy(x, y), ?(#tr(r), ts))) };

      let turnRightFirst : MapTraverser<K, V>
      = func (l, x, y, r, ts) { ?(#tr(r), ?(#xy(x, y), ?(#tr(l), ts))) };

      switch direction {
        case (#fwd) IterMap(map, turnLeftFirst);
        case (#bwd) IterMap(map, turnRightFirst)
      }
    };

    type MapTraverser<K, V> = (Tree<K, V>, K, V, Tree<K, V>, IterRep<K, V>) -> IterRep<K, V>;

    class IterMap<K, V>(tree : Tree<K, V>, mapTraverser : MapTraverser<K, V>) {
      var trees : IterRep<K, V> = ?(#tr(tree), null);
      public func next() : ?(K, V) {
        switch (trees) {
          case (null) { null };
          case (?(#tr(#leaf), ts)) {
            trees := ts;
            next()
          };
          case (?(#xy(xy), ts)) {
            trees := ts;
            ?xy
          };
          case (?(#tr(#red(l, x, y, r)), ts)) {
            trees := mapTraverser(l, x, y, r, ts);
            next()
          };
          case (?(#tr(#black(l, x, y, r)), ts)) {
            trees := mapTraverser(l, x, y, r, ts);
            next()
          }
        }
      }
    };

    public func map<K, V1, V2>(map : Map<K, V1>, f : (K, V1) -> V2) : Map<K, V2> {
      func mapRec(m : Tree<K, V1>) : Tree<K, V2> {
        switch m {
          case (#leaf) { #leaf };
          case (#red(l, x, y, r)) {
            #red(mapRec l, x, f(x,y), mapRec r)
          };
          case (#black(l, x, y, r)) {
            #black(mapRec l, x, f(x, y), mapRec r)
          };
        }
      };
      {size = map.size; root = mapRec(map.root)}
    };

    public func foldLeft<Key, Value, Accum>(
      map : Tree<Key, Value>,
      base : Accum,
      combine : (Key, Value, Accum) -> Accum
    ) : Accum
    {
      switch (map) {
        case (#leaf) { base };
        case (#red(l, k, v, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(k, v, left);
          foldLeft(r, middle, combine)
        };
        case (#black(l, k, v, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(k, v, left);
          foldLeft(r, middle, combine)
        }
      }
    };

    public func foldRight<Key, Value, Accum>(
      map : Tree<Key, Value>,
      base : Accum,
      combine : (Key, Value, Accum) -> Accum
    ) : Accum
    {
      switch (map) {
        case (#leaf) { base };
        case (#red(l, k, v, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(k, v, right);
          foldRight(l, middle, combine)
        };
        case (#black(l, k, v, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(k, v, right);
          foldRight(l, middle, combine)
        }
      }
    };

    public func mapFilter<K, V1, V2>(map : Map<K, V1>, compare : (K, K) -> O.Order, f : (K, V1) -> ?V2) : Map<K, V2> {
      var size = 0;
      func combine(key : K, value1 : V1, acc : Tree<K, V2>) : Tree<K, V2> {
        switch (f(key, value1)){
          case null { acc };
          case (?value2) {
            size += 1;
            put(acc, compare, key, value2)
          }
        }
      };
      { root = foldLeft(map.root, #leaf, combine); size }
    };

    public func get<K, V>(t : Tree<K, V>, compare : (K, K) -> O.Order, x : K) : ?V {
      switch t {
        case (#red(l, x1, y1, r)) {
          switch (compare(x, x1)) {
            case (#less) { get(l, compare, x) };
            case (#equal) { ?y1 };
            case (#greater) { get(r, compare, x) }
          }
        };
        case (#black(l, x1, y1, r)) {
          switch (compare(x, x1)) {
            case (#less) { get(l, compare, x) };
            case (#equal) { ?y1 };
            case (#greater) { get(r, compare, x) }
          }
        };
        case (#leaf) { null }
      }
    };

    public func contains<K, V>(m: Tree<K, V>, compare : (K, K) -> O.Order, key: K): Bool { 
      switch (get(m, compare, key)) {
        case(null) { false }; 
        case(_)    { true } 
      }
    };

    public func maxEntry<K, V>(m: Tree<K, V>): ?(K, V) {
      func rightmost(m: Tree<K, V>): (K, V) {
        switch m {
          case (#red(_, k, v, #leaf))   { (k, v) };
          case (#red(_, _, _, r))       { rightmost(r) };
          case (#black(_, k, v, #leaf)) { (k, v) };
          case (#black(_, _, _, r))     { rightmost(r) };
          case (#leaf)                  { Debug.trap "PersistentOrderedMap.impossible" }
        }
      };
      switch m {
        case (#leaf) { null };
        case (_)     { ?rightmost(m) }
      }
    };

    public func minEntry<K, V>(m: Tree<K, V>): ?(K, V) {
      func leftmost(m: Tree<K, V>): (K, V) {
        switch m {
          case (#red(#leaf, k, v, _))   { (k, v) };
          case (#red(l, _, _, _))       { leftmost(l) };
          case (#black(#leaf, k, v, _)) { (k, v) };
          case (#black(l, _, _, _))     { leftmost(l)};
          case (#leaf)                  { Debug.trap "PersistentOrderedMap.impossible" }
        }
      };
      switch m {
        case (#leaf) { null };
        case (_)     { ?leftmost(m) }
      }
    };

    public func all<K, V>(m: Tree<K, V>, pred: (K, V) -> Bool): Bool {
      switch m {
        case (#red(l, k, v, r)) {
          pred(k, v) and all(l, pred) and all(r, pred)
        };
        case (#black(l, k, v, r)) {
          pred(k, v) and all(l, pred) and all(r, pred)
        };
        case (#leaf) { true }
      }
    };

    public func some<K, V>(m: Tree<K, V>, pred: (K, V) -> Bool): Bool {
      switch m {
        case (#red(l, k, v, r)) {
          pred(k, v) or some(l, pred) or some(r, pred)
        };
        case (#black(l, k, v, r)) {
          pred(k, v) or some(l, pred) or some(r, pred)
        };
        case (#leaf) { false }
      }
    };

    func redden<K, V>(t : Tree<K, V>) : Tree<K, V> {
      switch t {
        case (#black (l, x, y, r)) {
          (#red (l, x, y, r))
        };
        case _ {
          Debug.trap "PersistentOrderedMap.red"
        }
      }
    };

    func lbalance<K, V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (#red(#red(l1, x1, y1, r1), x2, y2, r2), r) {
          #red(
            #black(l1, x1, y1, r1),
            x2, y2,
            #black(r2, x, y, r))
        };
        case (#red(l1, x1, y1, #red(l2, x2, y2, r2)), r) {
          #red(
            #black(l1, x1, y1, l2),
            x2, y2,
            #black(r2, x, y, r))
        };
        case _ {
          #black(left, x, y, right)
        }
      }
    };

    func rbalance<K, V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (l, #red(l1, x1, y1, #red(l2, x2, y2, r2))) {
          #red(
            #black(l, x, y, l1),
            x1, y1,
            #black(l2, x2, y2, r2))
        };
        case (l, #red(#red(l1, x1, y1, r1), x2, y2, r2)) {
          #red(
            #black(l, x, y, l1),
            x1, y1,
            #black(r1, x2, y2, r2))
        };
        case _ {
          #black(left, x, y, right)
        };
      }
    };

    type ClashResolver<A> = { old : A; new : A } -> A;

    func insertWith<K, V> (
      m : Tree<K, V>,
      compare : (K, K) -> O.Order,
      key : K,
      val : V,
      onClash : ClashResolver<V>
    )
    : Tree<K, V>{
      func ins(tree : Tree<K, V>) : Tree<K, V> {
        switch tree {
          case (#black(left, x, y, right)) {
            switch (compare (key, x)) {
              case (#less) {
                lbalance(ins left, x, y, right)
              };
              case (#greater) {
                rbalance(left, x, y, ins right)
              };
              case (#equal) {
                let newVal = onClash({ new = val; old = y });
                #black(left, key, newVal, right)
              }
            }
          };
          case (#red(left, x, y, right)) {
            switch (compare (key, x)) {
              case (#less) {
                #red(ins left, x, y, right)
              };
              case (#greater) {
                #red(left, x, y, ins right)
              };
              case (#equal) {
                let newVal = onClash { new = val; old = y };
                #red(left, key, newVal, right)
              }
            }
          };
          case (#leaf) {
            #red(#leaf, key, val, #leaf)
          }
        };
      };
      switch (ins m) {
        case (#red(left, x, y, right)) {
          #black(left, x, y, right);
        };
        case other { other };
      };
    };

    public func replace<K, V>(
      m : Tree<K, V>,
      compare : (K, K) -> O.Order,
      key : K,
      val : V
    )
    : (Tree<K, V>, ?V) {
      var oldVal : ?V = null;
      func onClash( clash : { old : V; new : V } ) : V
      {
        oldVal := ?clash.old;
        clash.new
      };
      let res = insertWith(m, compare, key, val, onClash);
      (res, oldVal)
    };

    public func put<K, V> (
      m : Tree<K, V>,
      compare : (K, K) -> O.Order,
      key : K,
      val : V
    ) : Tree<K, V> = replace(m, compare, key, val).0;


    func balLeft<K,V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (#red(l1, x1, y1, r1), r) {
          #red(
            #black(l1, x1, y1, r1),
            x, y,
            r)
        };
        case (_, #black(l2, x2, y2, r2)) {
          rbalance(left, x, y, #red(l2, x2, y2, r2))
        };
        case (_, #red(#black(l2, x2, y2, r2), x3, y3, r3)) {
          #red(
            #black(left, x, y, l2),
            x2, y2,
            rbalance(r2, x3, y3, redden r3))
        };
        case _ { Debug.trap "balLeft" };
      }
    };

    func balRight<K,V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (l, #red(l1, x1, y1, r1)) {
          #red(
            l,
            x, y,
            #black(l1, x1, y1, r1))
        };
        case (#black(l1, x1, y1, r1), r) {
          lbalance(#red(l1, x1, y1, r1), x, y, r);
        };
        case (#red(l1, x1, y1, #black(l2, x2, y2, r2)), r3) {
          #red(
            lbalance(redden l1, x1, y1, l2),
            x2, y2,
            #black(r2, x, y, r3))
        };
        case _ { Debug.trap "balRight" };
      }
    };

    func append<K,V>(left : Tree<K, V>, right: Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (#leaf,  _) { right };
        case (_,  #leaf) { left };
        case (#red (l1, x1, y1, r1),
              #red (l2, x2, y2, r2)) {
          switch (append (r1, l2)) {
            case (#red (l3, x3, y3, r3)) {
              #red(
                #red(l1, x1, y1, l3),
                x3, y3,
                #red(r3, x2, y2, r2))
            };
            case r1l2 {
              #red(l1, x1, y1, #red(r1l2, x2, y2, r2))
            }
          }
        };
        case (t1, #red(l2, x2, y2, r2)) {
          #red(append(t1, l2), x2, y2, r2)
        };
        case (#red(l1, x1, y1, r1), t2) {
          #red(l1, x1, y1, append(r1, t2))
        };
        case (#black(l1, x1, y1, r1), #black (l2, x2, y2, r2)) {
          switch (append (r1, l2)) {
            case (#red (l3, x3, y3, r3)) {
              #red(
                #black(l1, x1, y1, l3),
                x3, y3,
                #black(r3, x2, y2, r2))
            };
            case r1l2 {
              balLeft (
                l1,
                x1, y1,
                #black(r1l2, x2, y2, r2)
              )
            }
          }
        }
      }
    };

    public func delete<K, V>(m : Tree<K, V>, compare : (K, K) -> O.Order, key : K) : Tree<K, V>
      = remove(m, compare, key).0;

    public func remove<K, V>(tree : Tree<K, V>, compare : (K, K) -> O.Order, x : K) : (Tree<K, V>, ?V) {
      var y0 : ?V = null;
      func delNode(left : Tree<K, V>, x1 : K, y1 : V, right : Tree<K, V>) : Tree<K, V> {
        switch (compare (x, x1)) {
          case (#less) {
            let newLeft = del left;
            switch left {
              case (#black(_, _, _, _)) {
                balLeft(newLeft, x1, y1, right)
              };
              case _ {
                #red(newLeft, x1, y1, right)
              }
            }
          };
          case (#greater) {
            let newRight = del right;
            switch right {
              case (#black(_, _, _, _)) {
                balRight(left, x1, y1, newRight)
              };
              case _ {
                #red(left, x1, y1, newRight)
              }
            }
          };
          case (#equal) {
            y0 := ?y1;
            append(left, right)
          };
        }
      };
      func del(tree : Tree<K, V>) : Tree<K, V> {
        switch tree {
          case (#red(left, x, y, right)) {
            delNode(left, x, y, right)
          };
          case (#black(left, x, y, right)) {
            delNode(left, x, y, right)
          };
          case (#leaf) {
            tree
          }
        };
      };
      switch (del(tree)) {
        case (#red(left, x, y, right)) {
          (#black(left, x, y, right), y0);
        };
        case other { (other, y0) };
      };
    }
  }
}
