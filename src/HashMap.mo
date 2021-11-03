/// Mutable hash map (aka Hashtable)
///
/// This module defines an imperative hash map (hash table), with a general key and value type.
///
/// It has a minimal object-oriented interface: `get`, `set`, `delete`, `count` and `entries`.
///
/// The class is parameterized by the key's equality and hash functions,
/// and an initial capacity.  However, as with the `Buffer` class, no array allocation
/// happens until the first `set`.
///
/// Internally, table growth policy is very simple, for now:
///  Double the current capacity when the expected bucket list size grows beyond a certain constant.

import Prim "mo:⛔";
import P "Prelude";
import A "Array";
import Hash "Hash";
import Iter "Iter";
import AssocList "AssocList";

module {


  // key-val list type
  type KVs<K, V> = AssocList.AssocList<K, V>;

  // The mutable bits of a HashMap, put in their own type
  type S<K,V> = {
    var table : [var KVs<K, V>];
    var _count : Nat;
  };

  /// See `wrapS`
  func newS<K,V>() : S<K,V>{
    return {
      var table : [var KVs<K, V>] = [var];
      var _count : Nat = 0;
    };
  };

  /// This is an alternative constructor for `HashMap` that allows the backing
  /// store for the HashMap to live in stable memory. Use it as follows:
  /// ```
  /// stable var userS : HashMap.S <UserId,UserData> = newS();
  /// let user : HashMap.HashMap<UserId,UserData> = HashMap.wrapS(10, Nat.eq, Nat.hash, userS)
  /// ```
  public func wrapS<K,V>(
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    s : S<K,V>) : HashMap<K,V> {
    HashMap_(initCapacity, keyEq, keyHash, s);
  };

  // not public, same type as HashMap
  // more general constructor than HashMap
  class HashMap_<K, V>(
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    s : S<K,V>) {

    /// Returns the number of entries in this HashMap.
    public func size() : Nat = s._count;

    /// Deletes the entry with the key `k`. Doesn't do anything if the key doesn't
    /// exist.
    public func delete(k : K) = ignore remove(k);

    /// Removes the entry with the key `k` and returns the associated value if it
    /// existed or `null` otherwise.
    public func remove(k : K) : ?V {
      let m = s.table.size();
      if (m > 0) {
        let h = Prim.nat32ToNat(keyHash(k));
        let pos = h % m;
        let (kvs2, ov) = AssocList.replace<K, V>(s.table[pos], k, keyEq, null);
        s.table[pos] := kvs2;
        switch(ov){
          case null { };
          case _ { s._count -= 1; }
        };
        ov
      } else {
        null
      };
    };

    /// Gets the entry with the key `k` and returns its associated value if it
    /// existed or `null` otherwise.
    public func get(k : K) : ?V {
      let h = Prim.nat32ToNat(keyHash(k));
      let m = s.table.size();
      let v = if (m > 0) {
        AssocList.find<K, V>(s.table[h % m], k, keyEq)
      } else {
        null
      };
    };

    /// Insert the value `v` at key `k`. Overwrites an existing entry with key `k`
    public func put(k : K, v : V) = ignore replace(k, v);

    /// Insert the value `v` at key `k` and returns the previous value stored at
    /// `k` or `null` if it didn't exist.
    public func replace(k : K, v : V) : ?V {
      if (s._count >= s.table.size()) {
        let size =
          if (s._count == 0) {
            if (initCapacity > 0) {
              initCapacity
            } else {
              1
            }
          } else {
            s.table.size() * 2;
          };
        let table2 = A.init<KVs<K, V>>(size, null);
        for (i in s.table.keys()) {
          var kvs = s.table[i];
          label moveKeyVals : ()
          loop {
            switch kvs {
              case null { break moveKeyVals };
              case (?((k, v), kvsTail)) {
                let h = Prim.nat32ToNat(keyHash(k));
                let pos2 = h % table2.size();
                table2[pos2] := ?((k,v), table2[pos2]);
                kvs := kvsTail;
              };
            }
          };
        };
        s.table := table2;
      };
      let h = Prim.nat32ToNat(keyHash(k));
      let pos = h % s.table.size();
      let (kvs2, ov) = AssocList.replace<K, V>(s.table[pos], k, keyEq, ?v);
      s.table[pos] := kvs2;
      switch(ov){
        case null { s._count += 1 };
        case _ {}
      };
      ov
    };

    /// An `Iter` over the keys.
    public func keys() : Iter.Iter<K>
    { Iter.map(entries(), func (kv : (K, V)) : K { kv.0 }) };

    /// An `Iter` over the values.
    public func vals() : Iter.Iter<V>
    { Iter.map(entries(), func (kv : (K, V)) : V { kv.1 }) };

    /// Returns an iterator over the key value pairs in this
    /// `HashMap`. Does _not_ modify the `HashMap`.
    public func entries() : Iter.Iter<(K, V)> {
      if (s.table.size() == 0) {
        object { public func next() : ?(K, V) { null } }
      }
      else {
        object {
          var kvs = s.table[0];
          var nextTablePos = 1;
          public func next () : ?(K, V) {
            switch kvs {
              case (?(kv, kvs2)) {
                kvs := kvs2;
                ?kv
              };
              case null {
                if (nextTablePos < s.table.size()) {
                  kvs := s.table[nextTablePos];
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

  /// An imperative HashMap with a minimal object-oriented interface.
  /// Maps keys of type `K` to values of type `V`.
  public class HashMap<K, V>(
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash) {

    let i : HashMap_<K,V> = HashMap_(initCapacity, keyEq, keyHash, newS<K,V>());

    /// Returns the number of entries in this HashMap.
    public let size = i.size;

    /// Deletes the entry with the key `k`. Doesn't do anything if the key doesn't
    /// exist.
    public let delete = i.delete;

    /// Removes the entry with the key `k` and returns the associated value if it
    /// existed or `null` otherwise.
    public let remove = i.remove;

    /// Gets the entry with the key `k` and returns its associated value if it
    /// existed or `null` otherwise.
    public let get = i.get;

    /// Insert the value `v` at key `k`. Overwrites an existing entry with key `k`
    public let put = i.put;

    /// Insert the value `v` at key `k` and returns the previous value stored at
    /// `k` or `null` if it didn't exist.
    public let replace = i.replace;

    /// An `Iter` over the keys.
    public let keys = i.keys;

    /// An `Iter` over the values.
    public let vals = i.vals;

    /// Returns an iterator over the key value pairs in this
    /// `HashMap`. Does _not_ modify the `HashMap`.
    public let entries = i.entries;
  };

  /// clone cannot be an efficient object method,
  /// ...but is still useful in tests, and beyond.
  public func clone<K, V> (
    h : HashMap<K, V>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap<K, V> {
    let h2 = HashMap<K, V>(h.size(), keyEq, keyHash);
    for ((k,v) in h.entries()) {
      h2.put(k,v);
    };
    h2
  };

  /// Clone from any iterator of key-value pairs
  public func fromIter<K, V>(
    iter : Iter.Iter<(K, V)>,
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap<K, V> {
    let h = HashMap<K, V>(initCapacity, keyEq, keyHash);
    for ((k, v) in iter) {
      h.put(k, v);
    };
    h
  };

  public func map<K, V1, V2>(
    h : HashMap<K, V1>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    mapFn : (K, V1) -> V2,
  ) : HashMap<K, V2> {
    let h2 = HashMap<K, V2>(h.size(), keyEq, keyHash);
    for ((k, v1) in h.entries()) {
      let v2 = mapFn(k, v1);
      h2.put(k, v2);
    };
    h2
  };

  public func mapFilter<K, V1, V2>(
    h : HashMap<K, V1>,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash,
    mapFn : (K, V1) -> ?V2,
  ) : HashMap<K, V2> {
    let h2 = HashMap<K, V2>(h.size(), keyEq, keyHash);
    for ((k, v1) in h.entries()) {
      switch (mapFn(k, v1)) {
        case null { };
        case (?v2) {
          h2.put(k, v2);
        };
      }
    };
    h2
  };

}
