/// Mutable hash map (aka Hashtable)
///
/// This module defines an imperative hash map (hash table), with a general key and value type.
///
/// It has a minimal object-oriented interface: get, set, swap, delete, count and iter.
///
/// The class is parameterized by the key's equality and hash functions,
/// and an initial capacity.  However, as with `Buf`, no array allocation
/// happens until the first `set` (or `swap`).
///
/// Internally, table growth policy is very simple, for now:
///   Double an initial capacity when the expected
///   bucket list beyond a certain constant.

import Prim "mo:prim";
import P "Prelude";
import A "Array";
import Hash "Hash";
import Iter "Iter";
import AssocList "AssocList";

module {


// key-val list type
type KVs<K,V> = AssocList.AssocList<K,V>;

public class HashMap<K,V> (
  initCapacity: Nat,
  keyEq: (K,K) -> Bool,
  keyHash: K -> Hash.Hash) {

  var table : [var KVs<K,V>] = [var];
  var _count : Nat = 0;

  public func size() : Nat = _count;

  public func delete(k:K) = ignore remove(k);

  public func remove(k:K) : ?V {
    let h = Prim.word32ToNat(keyHash(k));
    let m = table.len();
    let pos = h % m;
    if (m > 0) {
      let (kvs2, ov) = AssocList.replace<K,V>(table[pos], k, keyEq, null);
      table[pos] := kvs2;
      switch(ov){
      case null { };
      case _ { _count -= 1; }
      };
      ov
    } else {
      null
    };
  };

  public func get(k:K) : ?V {
    let h = Prim.word32ToNat(keyHash(k));
    let m = table.len();
    let v = if (m > 0) {
      AssocList.find<K,V>(table[h % m], k, keyEq)
    } else {
      null
    };
  };

  public func put(k:K, v:V) = ignore replace(k, v);

  public func replace(k:K, v:V) : ?V {
    if (_count >= table.len()) {
      let size =
        if (_count == 0)
          if (initCapacity > 0)
            initCapacity
          else
            1
        else
          table.len() * 2;
      let table2 = A.init<KVs<K,V>>(size, null);
      for (i in table.keys()) {
        var kvs = table[i];
        label moveKeyVals : ()
        loop {
          switch kvs {
          case null { break moveKeyVals };
          case (?((k, v), kvsTail)) {
                 let h = Prim.word32ToNat(keyHash(k));
                 let pos2 = h % table2.len();
                 table2[pos2] := ?((k,v), table2[pos2]);
                 kvs := kvsTail;
               };
          }
        };
      };
      table := table2;
    };
    let h = Prim.word32ToNat(keyHash(k));
    let pos = h % table.len();
    let (kvs2, ov) = AssocList.replace<K,V>(table[pos], k, keyEq, ?v);
    table[pos] := kvs2;
    switch(ov){
    case null { _count += 1 };
    case _ {}
    };
    ov
  };

  public func entries() : Iter.Iter<(K,V)> {
    if (table.len() == 0) {
      object { public func next() : ?(K,V) { null } }
    }
    else {
      object {
        var kvs = table[0];
        var nextTablePos = 1;
        public func next () : ?(K,V) {
          switch kvs {
          case (?(kv, kvs2)) {
                 kvs := kvs2;
                 ?kv
               };
          case null {
                 if (nextTablePos < table.len()) {
                   kvs := table[nextTablePos];
                   nextTablePos += 1;
                   next()
                 } else {
                   null
                 }
               }
          }
        };
      }
    }
  };
};

/// clone cannot be an efficient object method,
/// ...but is still useful in tests, and beyond.
public func clone<K,V>
  (h:HashMap<K,V>,
   keyEq: (K,K) -> Bool,
   keyHash: K -> Hash.Hash) : HashMap<K,V> {
  let h2 = HashMap<K,V>(h.size(), keyEq, keyHash);
  for ((k,v) in h.entries()) {
    h2.put(k,v);
  };
  h2
};

/// Clone from any iterator of key-value pairs
public func fromIter<K, V>(iter:Iter.Iter<(K, V)>,
                           initCapacity: Nat,
                           keyEq: (K,K) -> Bool,
                           keyHash: K -> Hash.Hash) : HashMap<K,V> {
  let h = HashMap<K,V>(initCapacity, keyEq, keyHash);
  for ((k,v) in iter) {
    h.put(k,v);
  };
  h
};

public func transform<K, V1, V2>
  (h:HashMap<K,V1>,
   keyEq: (K,K) -> Bool,
   keyHash: K -> Hash.Hash,
   mapFn: (K, V1) -> V2,
  ) : HashMap<K,V2> {
  let h2 = HashMap<K,V2>(h.size(), keyEq, keyHash);
  for ((k, v1) in h.entries()) {
    let v2 = mapFn(k, v1);
    h2.put(k,v2);
  };
  h2
};

public func transformFilter<K, V1, V2>
  (h:HashMap<K,V1>,
   keyEq: (K,K) -> Bool,
   keyHash: K -> Hash.Hash,
   mapFn: (K, V1) -> ?V2,
  ) : HashMap<K,V2> {
  let h2 = HashMap<K,V2>(h.size(), keyEq, keyHash);
  for ((k, v1) in h.entries()) {
    switch (mapFn(k, v1)) {
      case null { };
      case (?v2) {
             h2.put(k,v2);
           };
    }
  };
  h2
};

}
