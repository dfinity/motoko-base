///Class `TrieMap<K, V>` provides a map from keys of type `K` to values of type `V`.
///The class wraps and manipulates an underlying hash trie, found in the `Trie` module.
///The trie is a binary tree where element positions are determined using the hash of the keys.
///
///:::warning [Limitations]
///
///This data structure allows at most `MAX_LEAF_SIZE = 8` hash collisions.
///Attempts to insert more than 8 keys (whether directly via `put` or indirectly via other operations) with the same hash value will trap.
///This limitation is inherited from the underlying `Trie` data structure.
///:::
///
///:::note [Interface compatibility]
///
///The `class` `TrieMap` exposes the same interface as `HashMap`.
///:::
///
///:::note [Assumptions]
///
///Runtime and space complexity assumes that `hash`, `equal`, and other function parameters execute in `O(1)` time and space.
///Where applicable, runtimes also assume the trie is reasonably balanced.
///:::
///
///:::note [Iterator performance]
///
///All iterator-related runtime and space costs refer to iterator construction.
///The iteration itself takes linear time and logarithmic space to execute.
///:::
///
///Creating a map:
///The equality function is used to compare keys, and the hash function is used to hash keys. See the example below.
///
///```motoko name=initialize
///import TrieMap "mo:base/TrieMap";
///import Nat "mo:base/Nat";
///import Hash "mo:base/Hash";
///import Iter "mo:base/Iter";
///
///let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash)
///```

import T "Trie";
import P "Prelude";
import I "Iter";
import Hash "Hash";
import List "List";

module {
  public class TrieMap<K, V>(isEq : (K, K) -> Bool, hashOf : K -> Hash.Hash) {
    var map = T.empty<K, V>();
    var _size : Nat = 0;

    /// Returns the number of entries in the map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.size()
    /// ```
    ///
    ///| Runtime        | Space         |
    ///|----------------|---------------|
    ///| `O(1)`   | `O(log(1))`  |
    public func size() : Nat { _size };

    /// Maps `key` to `value`, and overwrites the old entry if the key
    /// was already present.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.put(2, 12);
    /// Iter.toArray(map.entries())
    /// ```
    ///
    ///| Runtime        | Space         |
    ///|----------------|---------------|
    ///| `O(log(size))`   | `O(log(size))`  |
    public func put(key : K, value : V) = ignore replace(key, value);

    /// Maps `key` to `value`. Overwrites _and_ returns the old entry as an
    /// option if the key was already present, and `null` otherwise.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.replace(0, 20)
    /// ```
    ///
    ///| Runtime        | Space         |
    ///|----------------|---------------|
    ///| `O(log(size))`   | `O(log(size))`  |
    public func replace(key : K, value : V) : ?V {
      let keyObj = { key; hash = hashOf(key) };
      let (map2, ov) = T.put<K, V>(map, keyObj, isEq, value);
      map := map2;
      switch (ov) {
        case null { _size += 1 };
        case _ {}
      };
      ov
    };

    /// Gets the value associated with the key `key` in an option, or `null` if it
    /// doesn't exist.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.get(0)
    /// ```
    ///
    ///| Runtime        | Space         |
    ///|----------------|---------------|
    ///| `O(log(size))`   | `O(log(size))`  |
    public func get(key : K) : ?V {
      let keyObj = { key; hash = hashOf(key) };
      T.find<K, V>(map, keyObj, isEq)
    };

    /// Delete the entry associated with key `key`, if it exists. If the key is
    /// absent, there is no effect.
    ///
    /// Note: The deletion of an existing key shrinks the trie map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.delete(0);
    /// map.get(0)
    /// ```
    ///
    ///| Runtime        | Space         |
    ///|----------------|---------------|
    ///| `O(log(size))`   | `O(log(size))`  |
    public func delete(key : K) = ignore remove(key);

    /// Delete the entry associated with key `key`. Return the deleted value
    /// as an option if it exists, and `null` otherwise.
    ///
    /// Note: The deletion of an existing key shrinks the trie map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.remove(0)
    /// ```
    ///
    ///| Runtime        | Space         |
    ///|----------------|---------------|
    ///| `O(log(size))`   | `O(log(size))`  |
    public func remove(key : K) : ?V {
      let keyObj = { key; hash = hashOf(key) };
      let (t, ov) = T.remove<K, V>(map, keyObj, isEq);
      map := t;
      switch (ov) {
        case null {};
        case (?_) { _size -= 1 }
      };
      ov
    };

    /// Returns an iterator over the keys of the map.
    ///
    /// Each iterator gets a _snapshot view_ of the mapping, and is unaffected
    /// by concurrent updates to the iterated map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.put(1, 11);
    /// map.put(2, 12);
    ///
    /// // find the sum of all the keys
    /// var sum = 0;
    /// for (key in map.keys()) {
    ///   sum += key;
    /// };
    /// // 0 + 1 + 2
    /// sum
    /// ```
    ///
    ///| Runtime | Space |
    ///|---------|--------|
    ///| `O(1)`    | `O(1)`   |
    public func keys() : I.Iter<K> {
      I.map(entries(), func(kv : (K, V)) : K { kv.0 })
    };

    /// Returns an iterator over the values in the map.
    ///
    /// Each iterator gets a _snapshot view_ of the mapping, and is unaffected
    /// by concurrent updates to the iterated map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.put(1, 11);
    /// map.put(2, 12);
    ///
    /// // find the sum of all the values
    /// var sum = 0;
    /// for (key in map.vals()) {
    ///   sum += key;
    /// };
    /// // 10 + 11 + 12
    /// sum
    /// ```
    ///
    ///| Runtime | Space |
    ///|---------|--------|
    ///| `O(1)`   | `O(1)`  |
    public func vals() : I.Iter<V> {
      I.map(entries(), func(kv : (K, V)) : V { kv.1 })
    };

    /// Returns an iterator over the entries (key-value pairs) in the map.
    ///
    /// Each iterator gets a _snapshot view_ of the mapping, and is unaffected
    /// by concurrent updates to the iterated map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.put(1, 11);
    /// map.put(2, 12);
    ///
    /// // find the sum of all the products of key-value pairs
    /// var sum = 0;
    /// for ((key, value) in map.entries()) {
    ///   sum += key * value;
    /// };
    /// // (0 * 10) + (1 * 11) + (2 * 12)
    /// sum
    /// ```
    ///
    ///| Runtime | Space |
    ///|---------|--------|
    ///| `O(1)`    | `O(1)`   |
    public func entries() : I.Iter<(K, V)> {
      object {
        var stack = ?(map, null) : List.List<T.Trie<K, V>>;
        public func next() : ?(K, V) {
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
                case (#leaf({ size = c; keyvals = ?((k, v), kvs) })) {
                  stack := ?(#leaf({ size = c -1; keyvals = kvs }), stack2);
                  ?(k.key, v)
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
    }
  };

  /// Produce a copy of `map`, using `keyEq` to compare keys and `keyHash` to
  /// hash keys.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// map.put(0, 10);
  /// map.put(1, 11);
  /// map.put(2, 12);
  /// // Clone using the same equality and hash functions used to initialize `map`
  /// let mapCopy = TrieMap.clone(map, Nat.equal, Hash.hash);
  /// Iter.toArray(mapCopy.entries())
  /// ```
  ///
  ///| Runtime             | Space    |
  ///|---------------------|----------|
  ///| `O(size * log(size))` | `O(size)`  |
  public func clone<K, V>(
    map : TrieMap<K, V>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : TrieMap<K, V> {
    let h2 = TrieMap<K, V>(keyEq, keyHash);
    for ((k, v) in map.entries()) {
      h2.put(k, v)
    };
    h2
  };

  /// Create a new map from the entries in `entries`, using `keyEq` to compare
  /// keys and `keyHash` to hash keys.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// let entries = [(0, 10), (1, 11), (2, 12)];
  /// let newMap = TrieMap.fromEntries<Nat, Nat>(entries.vals(), Nat.equal, Hash.hash);
  /// newMap.get(2)
  /// ```
  ///
  ///| Runtime             | Space    |
  ///|---------------------|----------|
  ///| `O(size * log(size))` | `O(size)`  |
  public func fromEntries<K, V>(
    entries : I.Iter<(K, V)>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : TrieMap<K, V> {
    let h = TrieMap<K, V>(keyEq, keyHash);
    for ((k, v) in entries) {
      h.put(k, v)
    };
    h
  };

  /// Transform (map) the values in `map` using function `f`, retaining the keys.
  /// Uses `keyEq` to compare keys and `keyHash` to hash keys.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// map.put(0, 10);
  /// map.put(1, 11);
  /// map.put(2, 12);
  /// // double all the values in map
  /// let newMap = TrieMap.map<Nat, Nat, Nat>(map, Nat.equal, Hash.hash, func(key, value) = value * 2);
  /// Iter.toArray(newMap.entries())
  /// ```
  ///
  ///| Runtime             | Space    |
  ///|---------------------|----------|
  ///| `O(size * log(size))` | `O(size)`  |
  /// time and space.
  public func map<K, V1, V2>(
    map : TrieMap<K, V1>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    f : (K, V1) -> V2
  ) : TrieMap<K, V2> {
    let h2 = TrieMap<K, V2>(keyEq, keyHash);
    for ((k, v1) in map.entries()) {
      let v2 = f(k, v1);
      h2.put(k, v2)
    };
    h2
  };

  /// Transform (map) the values in `map` using function `f`, discarding entries
  /// for which `f` evaluates to `null`. Uses `keyEq` to compare keys and
  /// `keyHash` to hash keys.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// map.put(0, 10);
  /// map.put(1, 11);
  /// map.put(2, 12);
  /// // double all the values in map, only keeping entries that have an even key
  /// let newMap =
  ///   TrieMap.mapFilter<Nat, Nat, Nat>(
  ///     map,
  ///     Nat.equal,
  ///     Hash.hash,
  ///     func(key, value) = if (key % 2 == 0) { ?(value * 2) } else { null }
  ///   );
  /// Iter.toArray(newMap.entries())
  /// ```
  ///
  ///| Runtime             | Space    |
  ///|---------------------|----------|
  ///| `O(size * log(size))` | `O(size)`
  public func mapFilter<K, V1, V2>(
    map : TrieMap<K, V1>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    f : (K, V1) -> ?V2
  ) : TrieMap<K, V2> {
    let h2 = TrieMap<K, V2>(keyEq, keyHash);
    for ((k, v1) in map.entries()) {
      switch (f(k, v1)) {
        case null {};
        case (?v2) {
          h2.put(k, v2)
        }
      }
    };
    h2
  }
}
