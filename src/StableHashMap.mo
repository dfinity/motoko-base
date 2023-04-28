/// Mutable hash map (aka Hashtable)
///
/// This module defines an imperative hash map (hash table), with a general key and value type.
///
/// It is like HashMap, but eschews classes and objects so that its type is `stable`.
///

import Prim "mo:⛔";
import P "Prelude";
import A "Array";
import Hash "Hash";
import Iter "Iter";
import AssocList "AssocList";

module {
  // Type parameters that we need for all operations:
  // - K = key type
  // - V = value type


  // key-val list
  public type KVs<K, V> = AssocList.AssocList<K, V>;

  // representation of (the stable types of) the hash map state.
  // can be stored in a stable variable.
  public type HashMap<K, V> = {
    var table : [var KVs<K, V>];
    var count : Nat;
  };

  // representation of hash map including key operations.
  // unlike HashMap, this type is not stable, but is required for
  // some operations (keyEq and keyHash are functions).
  // to use, initialize `hashMap` to be your `stable var` hashmap.
  public type HashMap_<K, V> = {
    keyEq : (K, K) -> Bool;
    keyHash : K -> Hash.Hash;
    initCapacity : Nat;
    var hashMap : HashMap<K, V>;
  };

  public func empty<K, V>() : HashMap<K, V> {
    { var table = [var];
      var count = 0;
    }
  };

  public func empty_<K, V>(
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap_<K, V>
  {
    { var hashMap = { var table = [var];
                      var count = 0 };
      initCapacity;
      keyEq;
      keyHash;
    }
  };

  /// Returns the number of entries in this HashMap.
  public func size<K, V>(self : HashMap<K, V>) : Nat = self.count;

  /// Deletes the entry with the key `k`. Doesn't do anything if the key doesn't
  /// exist.
  public func delete<K, V>(self : HashMap_<K, V>, k : K) = ignore remove(self, k);

  /// Removes the entry with the key `k` and returns the associated value if it
  /// existed or `null` otherwise.
  public func remove<K, V>(self : HashMap_<K, V>, k : K) : ?V {
    let m = self.hashMap.table.size();
    if (m > 0) {
      let h = Prim.nat32ToNat(self.keyHash(k));
      let pos = h % m;
      let (kvs2, ov) = AssocList.replace<K, V>(self.hashMap.table[pos], k, self.keyEq, null);
      self.hashMap.table[pos] := kvs2;
      switch(ov){
      case null { };
      case _ { self.hashMap.count -= 1; }
      };
      ov
    } else {
      null
    };
  };

  /// Gets the entry with the key `k` and returns its associated value if it
  /// existed or `null` otherwise.
  public func get<K, V>(self : HashMap_<K, V>, k : K) : ?V {
    let h = Prim.nat32ToNat(self.keyHash(k));
    let m = self.hashMap.table.size();
    let v = if (m > 0) {
      AssocList.find<K, V>(self.hashMap.table[h % m], k, self.keyEq)
    } else {
      null
    };
  };

  /// Insert the value `v` at key `k`. Overwrites an existing entry with key `k`
  public func put<K, V>(self : HashMap_<K, V>, k : K, v : V) =
    ignore replace(self, k, v);

  /// Insert the value `v` at key `k` and returns the previous value stored at
  /// `k` or `null` if it didn't exist.
  public func replace<K, V>(self : HashMap_<K, V>, k : K, v : V) : ?V {
    if (self.hashMap.count >= self.hashMap.table.size()) {
      let size =
        if (self.hashMap.count == 0) {
          if (self.initCapacity > 0) {
            self.initCapacity
          } else {
            1
          }
        } else {
          self.hashMap.table.size() * 2;
        };
      let table2 = A.init<KVs<K, V>>(size, null);
      for (i in self.hashMap.table.keys()) {
        var kvs = self.hashMap.table[i];
        label moveKeyVals : ()
        loop {
          switch kvs {
          case null { break moveKeyVals };
          case (?((k, v), kvsTail)) {
                 let h = Prim.nat32ToNat(self.keyHash(k));
                 let pos2 = h % table2.size();
                 table2[pos2] := ?((k,v), table2[pos2]);
                 kvs := kvsTail;
               };
          }
        };
      };
      self.hashMap.table := table2;
    };
    let h = Prim.nat32ToNat(self.keyHash(k));
    let pos = h % self.hashMap.table.size();
    let (kvs2, ov) = AssocList.replace<K, V>(self.hashMap.table[pos], k, self.keyEq, ?v);
    self.hashMap.table[pos] := kvs2;
    switch(ov){
    case null { self.hashMap.count += 1 };
    case _ {}
    };
    ov
  };

  /// An `Iter` over the keys.
  public func keys<K, V>(self : HashMap<K, V>) : Iter.Iter<K>
  { Iter.map(entries(self), func (kv : (K, V)) : K { kv.0 }) };

  /// An `Iter` over the values.
  public func vals<K, V>(self : HashMap<K, V>) : Iter.Iter<V>
  { Iter.map(entries(self), func (kv : (K, V)) : V { kv.1 }) };

  /// Returns an iterator over the key value pairs in this
  /// `HashMap`. Does _not_ modify the `HashMap`.
  public func entries<K, V>(self : HashMap<K, V>) : Iter.Iter<(K, V)> {
    if (self.table.size() == 0) {
      object { public func next() : ?(K, V) { null } }
    }
    else {
      object {
        var kvs = self.table[0];
        var nextTablePos = 1;
        public func next () : ?(K, V) {
          switch kvs {
          case (?(kv, kvs2)) {
                 kvs := kvs2;
                 ?kv
               };
          case null {
                 if (nextTablePos < self.table.size()) {
                   kvs := self.table[nextTablePos];
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

  public func clone<K, V> (h : HashMap<K, V>) : HashMap<K, V> {
    { var table = A.tabulateVar(h.table.size(), func (i : Nat) : KVs<K, V> { h.table[i] });
      var count = h.count ;
    }
  };

  public func clone_<K, V> (h : HashMap_<K, V>) : HashMap_<K, V> {
    { keyEq = h.keyEq ;
      keyHash = h.keyHash ;
      initCapacity = h.initCapacity ;
      var hashMap = clone(h.hashMap) ;
    }
  };

  /// Clone from any iterator of key-value pairs
  public func fromIter<K, V>(
    iter : Iter.Iter<(K, V)>,
    initCapacity : Nat,
    keyEq : (K, K) -> Bool,
    keyHash : K -> Hash.Hash
  ) : HashMap_<K, V> {
    let h = empty_<K, V>(initCapacity, keyEq, keyHash);
    for ((k, v) in iter) {
      put(h, k, v);
    };
    h
  };

  public func map<K, V1, V2>(
    h : HashMap_<K, V1>,
    mapFn : (K, V1) -> V2,
  ) : HashMap_<K, V2> {
    let h2 = empty_<K, V2>(h.hashMap.table.size(), h.keyEq, h.keyHash);
    for ((k, v1) in entries(h.hashMap)) {
      let v2 = mapFn(k, v1);
      put(h2, k, v2);
    };
    h2
  };

  public func mapFilter<K, V1, V2>(
    h : HashMap_<K, V1>,
    mapFn : (K, V1) -> ?V2,
  ) : HashMap_<K, V2> {
    let h2 = empty_<K, V2>(h.hashMap.table.size(), h.keyEq, h.keyHash);
    for ((k, v1) in entries(h.hashMap)) {
      switch (mapFn(k, v1)) {
        case null { };
        case (?v2) {
          put(h2, k, v2);
        };
      }
    };
    h2
  };

}
