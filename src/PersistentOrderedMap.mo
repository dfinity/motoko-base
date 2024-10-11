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

// TODO: a faster, more compact and less indirect representation would be:
// type Map<K, V> = {
//  #red : (Map<K, V>, K, V, Map<K, V>);
//  #black : (Map<K, V>, K, V, Map<K, V>);
//  #leaf
//};
// (this inlines the colors into the variant, flattens a tuple, and removes a (now) redundant option, for considerable heap savings.)
// It would also make sense to maintain the size in a separate root for 0(1) access.

module {

  /// Node color: Either red (`#R`) or black (`#B`).
  public type Color = { #R; #B };

  /// Red-black tree of nodes with key-value entries, ordered by the keys.
  /// The keys have the generic type `K` and the values the generic type `V`.
  /// Leaves are considered implicitly black.
  public type Map<K, V> = {
    #node : (Color, Map<K, V>, (K, V), Map<K, V>);
    #leaf
  };

  /// Operations on `Map`, that require a comparator.
  ///
  /// The object should be created once, then used for all the operations
  /// with `Map` to ensure that the same comparator is used for every operation.
  ///
  /// `MapOps` contains methods that require `compare` internally:
  /// operations that may reshape a `Map` or should find something.
  public class MapOps<K>(compare : (K,K) -> O.Order) {

    /// Returns a new map, containing all entries given by the iterator `i`.
    /// If there are multiple entries with the same key the last one is taken.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let m = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(m))));
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
    public func fromIter<V>(i : I.Iter<(K,V)>) : Map<K, V>
      = Internal.fromIter(i, compare);

    /// Insert the value `value` with key `key` into the map `m`. Overwrites any existing entry with key `key`.
    /// Returns a modified map.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// var map = Map.empty<Nat, Text>();
    ///
    /// map := mapOps.put(map, 0, "Zero");
    /// map := mapOps.put(map, 2, "Two");
    /// map := mapOps.put(map, 1, "One");
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(map))));
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
      = Internal.put(m, compare, key, value);

    /// Insert the value `value` with key `key` into the map `m`. Returns modified map and
    /// the previous value associated with key `key` or `null` if no such value exists.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map0 = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// let (map1, old1) = mapOps.replace(map0, 0, "Nil");
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(map1))));
    /// Debug.print(debug_show(old1));
    /// // [(0, "Nil"), (1, "One"), (2, "Two")]
    /// // ?"Zero"
    ///
    /// let (map2, old2) = mapOps.replace(map0, 3, "Three");
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(map2))));
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
    public func replace<V>(m : Map<K, V>, key : K, value : V) : (Map<K,V>, ?V)
      = Internal.replace(m, compare, key, value);

    /// Creates a new map by applying `f` to each entry in the map `m`. For each entry
    /// `(k, v)` in the old map, if `f` evaluates to `null`, the entry is discarded.
    /// Otherwise, the entry is transformed into a new entry `(k, v2)`, where
    /// the new value `v2` is the result of applying `f` to `(k, v)`.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat"
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
    /// Debug.print(debug_show(Iter.toArray(Map.entries(newMap))));
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
    /// import Nat "mo:base/Nat"
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show mapOps.get(map, 1));
    /// Debug.print(debug_show mapOps.get(map, 42));
    ///
    /// // ?"One"
    /// // null
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the map and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func get<V>(m : Map<K, V>, key : K) : ?V
      = Internal.get(m, compare, key);

    /// Deletes the entry with the key `key` from the map `m`. Has no effect if `key` is not
    /// present in the map. Returns modified map.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat"
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(mapOps.delete(map, 1)))));
    /// Debug.print(debug_show(Iter.toArray(Map.entries(mapOps.delete(map, 42)))));
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
      = Internal.delete(m, compare, key);

    /// Deletes the entry with the key `key`. Returns modified map and the
    /// previous value associated with key `key` or `null` if no such value exists.
    ///
    /// Example:
    /// ```motoko
    /// import Map "mo:base/PersistentOrderedMap";
    /// import Nat "mo:base/Nat"
    /// import Iter "mo:base/Iter"
    /// import Debug "mo:base/Debug";
    ///
    /// let mapOps = Map.MapOps<Nat>(Nat.compare);
    /// let map0 = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
    ///
    /// let (map1, old1) = mapOps.remove(map0, 0);
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(map1))));
    /// Debug.print(debug_show(old1));
    /// // [(1, "One"), (2, "Two")]
    /// // ?"Zero"
    ///
    /// let (map2, old2) = mapOps.remove(map0, 42);
    ///
    /// Debug.print(debug_show(Iter.toArray(Map.entries(map2))));
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
    public func remove<V>(m : Map<K, V>, key : K) : (Map<K,V>, ?V)
      = Internal.remove(m, compare, key);

  };

  /// Create a new empty map.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Debug "mo:base/Debug";
  ///
  /// let map = Map.empty<Nat, Text>();
  ///
  /// Debug.print(debug_show(Map.size(map)));
  ///
  /// // 0
  /// ```
  ///
  /// Cost of empty map creation
  /// Runtime: `O(1)`.
  /// Space: `O(1)`
  public func empty<K, V>() : Map<K, V> = #leaf;

  type IterRep<K, V> = List.List<{ #tr : Map<K, V>; #xy : (K, V) }>;

  public type Direction = { #fwd; #bwd };

  /// Get an iterator for the entries of the map `m`, in ascending (`#fwd`) or descending (`#bwd`) order as specified by `direction`.
  /// The iterator takes a snapshot view of the map and is not affected by concurrent modifications.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Map.iter(map, #fwd))));
  /// Debug.print(debug_show(Iter.toArray(Map.iter(map, #bwd))));
  ///
  /// //  [(0, "Zero"), (1, "One"), (2, "Two")]
  /// //  [(2, "Two"), (1, "One"), (0, "Zero")]
  /// ```
  ///
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the map.
  ///
  /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func iter<K, V>(m : Map<K, V>, direction : Direction) : I.Iter<(K, V)> {
    let turnLeftFirst : MapTraverser<K, V>
     = func (l, xy, r, ts) { ?(#tr(l), ?(#xy(xy), ?(#tr(r), ts))) };

    let turnRightFirst : MapTraverser<K, V>
     = func (l, xy, r, ts) { ?(#tr(r), ?(#xy(xy), ?(#tr(l), ts))) };

    switch direction {
      case (#fwd) IterMap(m, turnLeftFirst);
      case (#bwd) IterMap(m, turnRightFirst)
    }
  };

  type MapTraverser<K, V> = (Map<K, V>, (K, V), Map<K, V>, IterRep<K, V>) -> IterRep<K, V>;

  class IterMap<K, V>(m : Map<K, V>, mapTraverser : MapTraverser<K, V>) {
    var trees : IterRep<K, V> = ?(#tr(m), null);
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
          case (?(#tr(#node(_, l, xy, r)), ts)) {
            trees := mapTraverser(l, xy, r, ts);
            next()
          }
        }
      }
  };

  /// Returns an Iterator (`Iter`) over the key-value pairs in the map.
  /// Iterator provides a single method `next()`, which returns
  /// pairs in ascending order by keys, or `null` when out of pairs to iterate over.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Map.entries(map))));
  ///
  ///
  /// // [(0, "Zero"), (1, "One"), (2, "Two")]
  /// ```
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the map.
  ///
  /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func entries<K, V>(m : Map<K, V>) : I.Iter<(K, V)> = iter(m, #fwd);

  /// Returns an Iterator (`Iter`) over the keys of the map.
  /// Iterator provides a single method `next()`, which returns
  /// keys in ascending order, or `null` when out of keys to iterate over.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Map.keys(map))));
  ///
  /// // [0, 1, 2]
  /// ```
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the map.
  ///
  /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func keys<K, V>(m : Map<K, V>) : I.Iter<K>
    = I.map(entries(m), func(kv : (K, V)) : K {kv.0});

  /// Returns an Iterator (`Iter`) over the values of the map.
  /// Iterator provides a single method `next()`, which returns
  /// values in no specific order, or `null` when out of values to iterate over.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// Debug.print(debug_show(Iter.toArray(Map.vals(map))));
  ///
  /// // ["Zero", "One", "Two"]
  /// ```
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the map.
  ///
  /// Note: Full map iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func vals<K, V>(m : Map<K, V>) : I.Iter<V>
    = I.map(entries(m), func(kv : (K, V)) : V {kv.1});

  /// Creates a new map by applying `f` to each entry in the map `m`. Each entry
  /// `(k, v)` in the old map is transformed into a new entry `(k, v2)`, where
  /// the new value `v2` is created by applying `f` to `(k, v)`.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let m = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// func f(key : Nat, _val : Text) : Nat = key * 2;
  ///
  /// let resMap = Map.map(m, f);
  ///
  /// Debug.print(debug_show(Iter.toArray(Map.entries(resMap))));
  ///
  /// // [(0, 0), (1, 2), (2, 4)]
  /// ```
  ///
  /// Cost of mapping all the elements:
  /// Runtime: `O(n)`.
  /// Space: `O(n)` retained memory
  /// where `n` denotes the number of key-value entries stored in the map.
  public func map<K, V1, V2>(m : Map<K, V1>, f : (K, V1) -> V2) : Map<K, V2> {
    func mapRec(m : Map<K, V1>) : Map<K, V2> {
      switch m {
        case (#leaf) { #leaf };
        case (#node(c, l, xy, r)) {
          #node(c, mapRec l, (xy.0, f xy), mapRec r) // TODO: try destination-passing style to avoid non tail-call recursion
        };
      }
    };
    mapRec(m)
  };

  /// Determine the size of the map as the number of key-value entries.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// Debug.print(debug_show(Map.size(map)));
  ///
  /// // 3
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of key-value entries stored in the map.
  public func size<K, V>(m : Map<K, V>) : Nat {
    switch m {
      case (#leaf) { 0 };
      case (#node(_, l, _, r)) {
        size(l) + size(r) + 1
      }
    }
  };

  /// Collapses the elements in `map` into a single value by starting with `base`
  /// and progressively combining keys and values into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// func folder(key : Nat, val : Text, accum : (Nat, Text)) : ((Nat, Text))
  ///   = (key + accum.0, accum.1 # val);
  ///
  /// Debug.print(debug_show(Map.foldLeft(map, (0, ""), folder)));
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
  public func foldLeft<Key, Value, Accum>(
    map : Map<Key, Value>,
    base : Accum,
    combine : (Key, Value, Accum) -> Accum
  ) : Accum
  {
    var acc = base;
    for(val in iter(map, #fwd)){
      acc := combine(val.0, val.1, acc);
    };
    acc
  };

  /// Collapses the elements in `map` into a single value by starting with `base`
  /// and progressively combining keys and values into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/PersistentOrderedMap";
  /// import Nat "mo:base/Nat"
  /// import Iter "mo:base/Iter"
  /// import Debug "mo:base/Debug";
  ///
  /// let mapOps = Map.MapOps<Nat>(Nat.compare);
  /// let map = mapOps.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// func folder(key : Nat, val : Text, accum : (Nat, Text)) : ((Nat, Text))
  ///   = (key + accum.0, accum.1 # val);
  ///
  /// Debug.print(debug_show(Map.foldRight(map, (0, ""), folder)));
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
  public func foldRight<Key, Value, Accum>(
    map : Map<Key, Value>,
    base : Accum,
    combine : (Key, Value, Accum) -> Accum
  ) : Accum
  {
    var acc = base;
    for(val in iter(map, #bwd)){
      acc := combine(val.0, val.1, acc);
    };
    acc
  };


  module Internal {

    public func fromIter<K, V>(i : I.Iter<(K,V)>, compare : (K, K) -> O.Order) : Map<K, V>
    {
      var map = #leaf : Map<K,V>;
      for(val in i) {
        map := put(map, compare, val.0, val.1);
      };
      map
    };

    public func mapFilter<K, V1, V2>(t : Map<K, V1>, compare : (K, K) -> O.Order, f : (K, V1) -> ?V2) : Map<K, V2>{
      var map = #leaf : Map<K, V2>;
      for(kv in iter(t, #fwd))
      {
        switch(f kv){
          case null {};
          case (?v1) {
            // The keys still are monotonic, so we can
            // merge trees using `append` and avoid compare here
            map := put(map, compare, kv.0, v1);
          }
        }
      };
      map
    };

    public func get<K, V>(t : Map<K, V>, compare : (K, K) -> O.Order, x : K) : ?V {
      switch t {
        case (#leaf) { null };
        case (#node(_c, l, xy, r)) {
          switch (compare(x, xy.0)) {
            case (#less) { get(l, compare, x) };
            case (#equal) { ?xy.1 };
            case (#greater) { get(r, compare, x) }
          }
        }
      }
    };

    func redden<K, V>(t : Map<K, V>) : Map<K, V> {
      switch t {
        case (#node (#B, l, xy, r)) {
          (#node (#R, l, xy, r))
        };
        case _ {
          Debug.trap "RBTree.red"
        }
      }
    };

    func lbalance<K,V>(left : Map<K, V>, xy : (K,V), right : Map<K, V>) : Map<K,V> {
      switch (left, right) {
        case (#node(#R, #node(#R, l1, xy1, r1), xy2, r2), r) {
          #node(
            #R,
            #node(#B, l1, xy1, r1),
            xy2,
            #node(#B, r2, xy, r))
        };
        case (#node(#R, l1, xy1, #node(#R, l2, xy2, r2)), r) {
          #node(
            #R,
            #node(#B, l1, xy1, l2),
            xy2,
            #node(#B, r2, xy, r))
        };
        case _ {
          #node(#B, left, xy, right)
        }
      }
    };

    func rbalance<K,V>(left : Map<K, V>, xy : (K,V), right : Map<K, V>) : Map<K,V> {
      switch (left, right) {
        case (l, #node(#R, l1, xy1, #node(#R, l2, xy2, r2))) {
          #node(
            #R,
            #node(#B, l, xy, l1),
            xy1,
            #node(#B, l2, xy2, r2))
        };
        case (l, #node(#R, #node(#R, l1, xy1, r1), xy2, r2)) {
          #node(
            #R,
            #node(#B, l, xy, l1),
            xy1,
            #node(#B, r1, xy2, r2))
        };
        case _ {
          #node(#B, left, xy, right)
        };
      }
    };

    type ClashResolver<A> = { old : A; new : A } -> A;

    func insertWith<K, V> (
      m : Map<K, V>,
      compare : (K, K) -> O.Order,
      key : K,
      val : V,
      onClash : ClashResolver<V>
    )
    : Map<K, V>{
      func ins(tree : Map<K,V>) : Map<K,V> {
        switch tree {
          case (#leaf) {
            #node(#R, #leaf, (key,val), #leaf)
          };
          case (#node(#B, left, xy, right)) {
            switch (compare (key, xy.0)) {
              case (#less) {
                lbalance(ins left, xy, right)
              };
              case (#greater) {
                rbalance(left, xy, ins right)
              };
              case (#equal) {
                let newVal = onClash({ new = val; old = xy.1 });
                #node(#B, left, (key,newVal), right)
              }
            }
          };
          case (#node(#R, left, xy, right)) {
            switch (compare (key, xy.0)) {
              case (#less) {
                #node(#R, ins left, xy, right)
              };
              case (#greater) {
                #node(#R, left, xy, ins right)
              };
              case (#equal) {
                let newVal = onClash { new = val; old = xy.1 };
                #node(#R, left, (key,newVal), right)
              }
            }
          }
        };
      };
      switch (ins m) {
        case (#node(#R, left, xy, right)) {
          #node(#B, left, xy, right);
        };
        case other { other };
      };
    };

    public func replace<K, V>(
      m : Map<K, V>,
      compare : (K, K) -> O.Order,
      key : K,
      val : V
    )
    : (Map<K,V>, ?V) {
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
      m : Map<K, V>,
      compare : (K, K) -> O.Order,
      key : K,
      val : V
    ) : Map<K, V> = replace(m, compare, key, val).0;


    func balLeft<K,V>(left : Map<K, V>, xy : (K,V), right : Map<K, V>) : Map<K,V> {
      switch (left, right) {
        case (#node(#R, l1, xy1, r1), r) {
          #node(
            #R,
            #node(#B, l1, xy1, r1),
            xy,
            r)
        };
        case (_, #node(#B, l2, xy2, r2)) {
          rbalance(left, xy, #node(#R, l2, xy2, r2))
        };
        case (_, #node(#R, #node(#B, l2, xy2, r2), xy3, r3)) {
          #node(#R,
            #node(#B, left, xy, l2),
            xy2,
            rbalance(r2, xy3, redden r3))
        };
        case _ { Debug.trap "balLeft" };
      }
    };

    func balRight<K,V>(left : Map<K, V>, xy : (K,V), right : Map<K, V>) : Map<K,V> {
      switch (left, right) {
        case (l, #node(#R, l1, xy1, r1)) {
          #node(#R,
            l,
            xy,
            #node(#B, l1, xy1, r1))
        };
        case (#node(#B, l1, xy1, r1), r) {
          lbalance(#node(#R, l1, xy1, r1), xy, r);
        };
        case (#node(#R, l1, xy1, #node(#B, l2, xy2, r2)), r3) {
          #node(#R,
            lbalance(redden l1, xy1, l2),
            xy2,
            #node(#B, r2, xy, r3))
        };
        case _ { Debug.trap "balRight" };
      }
    };

    func append<K,V>(left : Map<K, V>, right: Map<K, V>) : Map<K, V> {
      switch (left, right) {
        case (#leaf,  _) { right };
        case (_,  #leaf) { left };
        case (#node (#R, l1, xy1, r1),
              #node (#R, l2, xy2, r2)) {
          switch (append (r1, l2)) {
            case (#node (#R, l3, xy3, r3)) {
              #node(
                #R,
                #node(#R, l1, xy1, l3),
                xy3,
                #node(#R, r3, xy2, r2))
            };
            case r1l2 {
              #node(#R, l1, xy1, #node(#R, r1l2, xy2, r2))
            }
          }
        };
        case (t1, #node(#R, l2, xy2, r2)) {
          #node(#R, append(t1, l2), xy2, r2)
        };
        case (#node(#R, l1, xy1, r1), t2) {
          #node(#R, l1, xy1, append(r1, t2))
        };
        case (#node(#B, l1, xy1, r1), #node (#B, l2, xy2, r2)) {
          switch (append (r1, l2)) {
            case (#node (#R, l3, xy3, r3)) {
              #node(#R,
                #node(#B, l1, xy1, l3),
                xy3,
                #node(#B, r3, xy2, r2))
            };
            case r1l2 {
              balLeft (
                l1,
                xy1,
                #node(#B, r1l2, xy2, r2)
              )
            }
          }
        }
      }
    };

    public func delete<K, V>(m : Map<K, V>, compare : (K, K) -> O.Order, key : K) : Map<K, V>
      = remove(m, compare, key).0;

    public func remove<K, V>(tree : Map<K, V>, compare : (K, K) -> O.Order, x : K) : (Map<K,V>, ?V) {
      var y0 : ?V = null;
      func delNode(left : Map<K,V>, xy : (K, V), right : Map<K,V>) : Map<K,V> {
        switch (compare (x, xy.0)) {
          case (#less) {
            let newLeft = del left;
            switch left {
              case (#node(#B, _, _, _)) {
                balLeft(newLeft, xy, right)
              };
              case _ {
                #node(#R, newLeft, xy, right)
              }
            }
          };
          case (#greater) {
            let newRight = del right;
            switch right {
              case (#node(#B, _, _, _)) {
                balRight(left, xy, newRight)
              };
              case _ {
                #node(#R, left, xy, newRight)
              }
            }
          };
          case (#equal) {
            y0 := ?xy.1;
            append(left, right)
          };
        }
      };
      func del(tree : Map<K,V>) : Map<K,V> {
        switch tree {
          case (#leaf) {
            tree
          };
          case (#node(_, left, xy, right)) {
            delNode(left, xy, right)
          }
        };
      };
      switch (del(tree)) {
        case (#node(#R, left, xy, right)) {
          (#node(#B, left, xy, right), y0);
        };
        case other { (other, y0) };
      };
    }
  }
}
