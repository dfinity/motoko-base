/// Map implementation backed by Trie.
///
/// FIXME rework description
/// An imperative hash map, with a general key and value type.
///
/// - The `class` `TrieMap` exposes the same interface as `HashMap`.
///
/// - Unlike HashMap, the internal representation uses a functional representation (via `Trie` module).
///
/// - This class does not permit a direct `clone` operation (neither does `HashMap`), but it does permit creating iterators via `iter()`.  Each iterator costs `O(1)` to create, but represents a fixed view of the mapping that does not interfere with mutations (it will _not_ reflect subsequent insertions or mutations, if any).
///
/// FIXME add description about initialization details
/// ```motoko name=initialize
/// import TrieMap "mo:base/TrieMap";
/// import Nat "mo:base/Nat";
/// import Hash "mo:base/Hash";
/// import Iter "mo:base/Iter";
///
/// let map = TrieMap.TrieMap<Nat, Nat>(Nat.equal, Hash.hash)
/// ```

import T "Trie";
import P "Prelude";
import I "Iter";
import Hash "Hash";
import List "List";

// FIXME Hash.hash deprecated and warning shows up in interpreter

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
    /// Runtime: O(1)
    /// Space: O(1)
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
    /// Runtime: O(log(size))
    /// Space: O(log(size))
    ///
    /// *Runtime and space assumes that the trie is reasonably balanced.
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
    /// Runtime: O(log(size))
    /// Space: O(log(size))
    ///
    /// *Runtime and space assumes that the trie is reasonably balanced.
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
    /// Runtime: O(log(size))
    /// Space: O(log(size))
    ///
    /// *Runtime and space assumes that the trie is reasonably balanced.
    public func get(key : K) : ?V {
      let keyObj = { key; hash = hashOf(key) };
      T.find<K, V>(map, keyObj, isEq)
    };

    /// Delete the entry associated with key `key`, if it exists.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.delete(0);
    /// map.get(0)
    /// ```
    ///
    /// Runtime: O(log(size))
    /// Space: O(log(size))
    ///
    /// *Runtime and space assumes that the trie is reasonably balanced.
    public func delete(key : K) = ignore remove(key);

    /// Delete the entry associated with key `key`. Return the deleted value
    /// as an option if it exists, and `null` otherwise.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put(0, 10);
    /// map.remove(0)
    /// ```
    ///
    /// Runtime: O(log(size))
    /// Space: O(log(size))
    ///
    /// *Runtime and space assumes that the trie is reasonably balanced.
    public func remove(k : K) : ?V {
      let keyObj = { key = k; hash = hashOf(k) };
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
    /// Each iterator gets a _persistent view_ of the mapping, and is unaffected
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
    /// Runtime: O(FIXME)
    /// Space: O(FIXME)
    public func keys() : I.Iter<K> {
      I.map(entries(), func(kv : (K, V)) : K { kv.0 })
    };

    /// Returns an iterator over the values in the map.
    ///
    /// Each iterator gets a _persistent view_ of the mapping, and is unaffected
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
    /// Runtime: O(FIXME)
    /// Space: O(FIXME)
    public func vals() : I.Iter<V> {
      I.map(entries(), func(kv : (K, V)) : V { kv.1 })
    };

    /// Returns an iterator over the entries (key-value pairs) in the map.
    ///
    /// Each iterator gets a _persistent view_ of the mapping, and is unaffected
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
    /// Runtime: O(FIXME)
    /// Space: O(FIXME)
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
  /// Runtime: O(FIXME)
  /// Space: O(FIXME)
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
  /// Runtime: O(FIXME)
  /// Space: O(FIXME)
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

  /// Transform (map) the values in `map` using function `f`, retaining its keys.
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
  /// Runtime: O(FIXME)
  /// Space: O(FIXME)
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
  /// Runtime: O(FIXME)
  /// Space: O(FIXME)
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
