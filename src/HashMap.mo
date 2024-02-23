/// Class `HashMap<K, V>` provides a hashmap from keys of type `K` to values of type `V`.

/// The class is parameterized by the key's equality and hash functions,
/// and an initial capacity.  However, the underlying allocation happens only when
/// the first key-value entry is inserted.
///
/// Internally, the map is represented as an array of `AssocList` (buckets).
/// The growth policy of the underyling array is very simple, for now: double
/// the current capacity when the expected bucket list size grows beyond a
/// certain constant.
///
/// WARNING: Certain operations are amortized O(1) time, such as `put`, but run
/// in worst case O(size) time. These worst case runtimes may exceed the cycles limit
/// per message if the size of the map is large enough. Further, this runtime analysis
/// assumes that the hash functions uniformly maps keys over the hash space. Grow these structures
/// with discretion, and with good hash functions. All amortized operations
/// below also list the worst case runtime.
///
/// For maps without amortization, see `TrieMap`.
///
/// Note on the constructor:
/// The argument `initCapacity` determines the initial number of buckets in the
/// underyling array. Also, the runtime and space anlyses in this documentation
/// assumes that the equality and hash functions for keys used to construct the
/// map run in O(1) time and space.
///
/// Example:
/// ```motoko name=initialize
/// import HashMap "mo:base/HashMap";
/// import Text "mo:base/Text";
///
/// let map = HashMap.HashMap<Text, Nat>(5, Text.equal, Text.hash);
/// ```
///
/// Runtime: O(1)
///
/// Space: O(1)

import Prim "mo:⛔";
import P "Prelude";
import A "Array";
import Hash "Hash";
import Iter "Iter";
import AssocList "AssocList";
import Nat32 "Nat32";

module {

  // hash field avoids re-hashing the key when the array grows.
  type Key<K> = (Hash.Hash, K);

  // key-val list type
  type KVs<K, V> = AssocList.AssocList<Key<K>, V>;

  public class HashMap<K, V>(
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) {

    var table : [var KVs<K, V>] = [var];
    var _count : Nat = 0;

    /// Returns the current number of key-value entries in the map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.size() // => 0
    /// ```
    ///
    /// Runtime: O(1)
    ///
    /// Space: O(1)
    public func size() : Nat = _count;

    /// Returns the value assocaited with key `key` if present and `null` otherwise.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put("key", 3);
    /// map.get("key") // => ?3
    /// ```
    ///
    /// Expected Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Space: O(1)
    public func get(key : K) : (value : ?V) {
      let h = Prim.nat32ToNat(keyHash(key));
      let m = table.size();
      if (m > 0) {
        AssocList.find<Key<K>, V>(table[h % m], keyHash_(key), keyHashEq)
      } else {
        null
      }
    };

    /// Insert the value `value` with key `key`. Overwrites any existing entry with key `key`.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put("key", 3);
    /// map.get("key") // => ?3
    /// ```
    ///
    /// Expected Amortized Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Expected Amortized Space: O(1), Worst Case Space: O(size)
    ///
    /// Note: If this is the first entry into this map, this operation will cause
    /// the initial allocation of the underlying array.
    public func put(key : K, value : V) = ignore replace(key, value);

    /// Insert the value `value` with key `key`. Returns the previous value
    /// associated with key `key` or `null` if no such value exists.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put("key", 3);
    /// ignore map.replace("key", 2); // => ?3
    /// map.get("key") // => ?2
    /// ```
    ///
    /// Expected Amortized Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Expected Amortized Space: O(1), Worst Case Space: O(size)
    ///
    /// Note: If this is the first entry into this map, this operation will cause
    /// the initial allocation of the underlying array.
    public func replace(key : K, value : V) : (oldValue : ?V) {
      if (_count >= table.size()) {
        let size = if (_count == 0) {
          if (initCapacity > 0) {
            initCapacity
          } else {
            1
          }
        } else {
          table.size() * 2
        };
        let table2 = A.init<KVs<K, V>>(size, null);
        for (i in table.keys()) {
          var kvs = table[i];
          label moveKeyVals : () loop {
            switch kvs {
              case null { break moveKeyVals };
              case (?((k, v), kvsTail)) {
                let pos2 = Nat32.toNat(k.0) % table2.size(); // critical: uses saved hash. no re-hash.
                table2[pos2] := ?((k, v), table2[pos2]);
                kvs := kvsTail
              }
            }
          }
        };
        table := table2
      };
      let h = Prim.nat32ToNat(keyHash(key));
      let pos = h % table.size();
      let (kvs2, ov) = AssocList.replace<Key<K>, V>(table[pos], keyHash_(key), keyHashEq, ?value);
      table[pos] := kvs2;
      switch (ov) {
        case null { _count += 1 };
        case _ {}
      };
      ov
    };

    /// Deletes the entry with the key `key`. Has no effect if `key` is not
    /// present in the map.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put("key", 3);
    /// map.delete("key");
    /// map.get("key"); // => null
    /// ```
    ///
    /// Expected Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Expected Space: O(1), Worst Case Space: O(size)
    public func delete(key : K) = ignore remove(key);

    func keyHash_(k : K) : Key<K> = (keyHash(k), k);

    func keyHashEq(k1 : Key<K>, k2 : Key<K>) : Bool {
      k1.0 == k2.0 and keyEq(k1.1, k2.1)
    };

    /// Deletes the entry with the key `key`. Returns the previous value
    /// associated with key `key` or `null` if no such value exists.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// map.put("key", 3);
    /// map.remove("key"); // => ?3
    /// ```
    ///
    /// Expected Runtime: O(1), Worst Case Runtime: O(size)
    ///
    /// Expected Space: O(1), Worst Case Space: O(size)
    public func remove(key : K) : (oldValue : ?V) {
      let m = table.size();
      if (m > 0) {
        let h = Prim.nat32ToNat(keyHash(key));
        let pos = h % m;
        let (kvs2, ov) = AssocList.replace<Key<K>, V>(table[pos], keyHash_(key), keyHashEq, null);
        table[pos] := kvs2;
        switch (ov) {
          case null {};
          case _ { _count -= 1 }
        };
        ov
      } else {
        null
      }
    };

    /// Returns an Iterator (`Iter`) over the keys of the map.
    /// Iterator provides a single method `next()`, which returns
    /// keys in no specific order, or `null` when out of keys to iterate over.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// map.put("key1", 1);
    /// map.put("key2", 2);
    /// map.put("key3", 3);
    ///
    /// var keys = "";
    /// for (key in map.keys()) {
    ///   keys := key # " " # keys
    /// };
    /// keys // => "key3 key2 key1 "
    /// ```
    ///
    /// Cost of iteration over all keys:
    ///
    /// Runtime: O(size)
    ///
    /// Space: O(1)
    public func keys() : Iter.Iter<K> {
      Iter.map(entries(), func(kv : (K, V)) : K { kv.0 })
    };

    /// Returns an Iterator (`Iter`) over the values of the map.
    /// Iterator provides a single method `next()`, which returns
    /// values in no specific order, or `null` when out of values to iterate over.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// map.put("key1", 1);
    /// map.put("key2", 2);
    /// map.put("key3", 3);
    ///
    /// var sum = 0;
    /// for (value in map.vals()) {
    ///   sum += value;
    /// };
    /// sum // => 6
    /// ```
    ///
    /// Cost of iteration over all values:
    ///
    /// Runtime: O(size)
    ///
    /// Space: O(1)
    public func vals() : Iter.Iter<V> {
      Iter.map(entries(), func(kv : (K, V)) : V { kv.1 })
    };

    /// Returns an Iterator (`Iter`) over the key-value pairs in the map.
    /// Iterator provides a single method `next()`, which returns
    /// pairs in no specific order, or `null` when out of pairs to iterate over.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Nat "mo:base/Nat";
    ///
    /// map.put("key1", 1);
    /// map.put("key2", 2);
    /// map.put("key3", 3);
    ///
    /// var pairs = "";
    /// for ((key, value) in map.entries()) {
    ///   pairs := "(" # key # ", " # Nat.toText(value) # ") " # pairs
    /// };
    /// pairs // => "(key3, 3) (key2, 2) (key1, 1)"
    /// ```
    ///
    /// Cost of iteration over all pairs:
    ///
    /// Runtime: O(size)
    ///
    /// Space: O(1)
    public func entries() : Iter.Iter<(K, V)> {
      if (table.size() == 0) {
        object { public func next() : ?(K, V) { null } }
      } else {
        object {
          var kvs = table[0];
          var nextTablePos = 1;
          public func next() : ?(K, V) {
            switch kvs {
              case (?(kv, kvs2)) {
                kvs := kvs2;
                ?(kv.0.1, kv.1)
              };
              case null {
                if (nextTablePos < table.size()) {
                  kvs := table[nextTablePos];
                  nextTablePos += 1;
                  next()
                } else {
                  null
                }
              }
            }
          }
        }
      }
    };

  };

  /// Returns a copy of `map`, initializing the copy with the provided equality
  /// and hash functions.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// map.put("key1", 1);
  /// map.put("key2", 2);
  /// map.put("key3", 3);
  ///
  /// let map2 = HashMap.clone(map, Text.equal, Text.hash);
  /// map2.get("key1") // => ?1
  /// ```
  ///
  /// Expected Runtime: O(size), Worst Case Runtime: O(size * size)
  ///
  /// Expected Space: O(size), Worst Case Space: O(size)
  public func clone<K, V>(
    map : HashMap<K, V>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap<K, V> {
    let h2 = HashMap<K, V>(map.size(), keyEq, keyHash);
    for ((k, v) in map.entries()) {
      h2.put(k, v)
    };
    h2
  };

  /// Returns a new map, containing all entries given by the iterator `iter`.
  /// The new map is initialized with the provided initial capacity, equality,
  /// and hash functions.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// let entries = [("key3", 3), ("key2", 2), ("key1", 1)];
  /// let iter = entries.vals();
  ///
  /// let map2 = HashMap.fromIter<Text, Nat>(iter, entries.size(), Text.equal, Text.hash);
  /// map2.get("key1") // => ?1
  /// ```
  ///
  /// Expected Runtime: O(size), Worst Case Runtime: O(size * size)
  ///
  /// Expected Space: O(size), Worst Case Space: O(size)
  public func fromIter<K, V>(
    iter : Iter.Iter<(K, V)>,
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap<K, V> {
    let h = HashMap<K, V>(initCapacity, keyEq, keyHash);
    for ((k, v) in iter) {
      h.put(k, v)
    };
    h
  };

  /// Creates a new map by applying `f` to each entry in `hashMap`. Each entry
  /// `(k, v)` in the old map is transformed into a new entry `(k, v2)`, where
  /// the new value `v2` is created by applying `f` to `(k, v)`.
  ///
  /// ```motoko include=initialize
  /// map.put("key1", 1);
  /// map.put("key2", 2);
  /// map.put("key3", 3);
  ///
  /// let map2 = HashMap.map<Text, Nat, Nat>(map, Text.equal, Text.hash, func (k, v) = v * 2);
  /// map2.get("key2") // => ?4
  /// ```
  ///
  /// Expected Runtime: O(size), Worst Case Runtime: O(size * size)
  ///
  /// Expected Space: O(size), Worst Case Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<K, V1, V2>(
    hashMap : HashMap<K, V1>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    f : (K, V1) -> V2
  ) : HashMap<K, V2> {
    let h2 = HashMap<K, V2>(hashMap.size(), keyEq, keyHash);
    for ((k, v1) in hashMap.entries()) {
      let v2 = f(k, v1);
      h2.put(k, v2)
    };
    h2
  };

  /// Creates a new map by applying `f` to each entry in `hashMap`. For each entry
  /// `(k, v)` in the old map, if `f` evaluates to `null`, the entry is discarded.
  /// Otherwise, the entry is transformed into a new entry `(k, v2)`, where
  /// the new value `v2` is the result of applying `f` to `(k, v)`.
  ///
  /// ```motoko include=initialize
  /// map.put("key1", 1);
  /// map.put("key2", 2);
  /// map.put("key3", 3);
  ///
  /// let map2 =
  ///   HashMap.mapFilter<Text, Nat, Nat>(
  ///     map,
  ///     Text.equal,
  ///     Text.hash,
  ///     func (k, v) = if (v == 2) { null } else { ?(v * 2)}
  /// );
  /// map2.get("key3") // => ?6
  /// ```
  ///
  /// Expected Runtime: O(size), Worst Case Runtime: O(size * size)
  ///
  /// Expected Space: O(size), Worst Case Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapFilter<K, V1, V2>(
    hashMap : HashMap<K, V1>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    f : (K, V1) -> ?V2
  ) : HashMap<K, V2> {
    let h2 = HashMap<K, V2>(hashMap.size(), keyEq, keyHash);
    for ((k, v1) in hashMap.entries()) {
      switch (f(k, v1)) {
        case null {};
        case (?v2) {
          h2.put(k, v2)
        }
      }
    };
    h2
  };

}
