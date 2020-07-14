/// Functional map
///
/// This module defines an imperative hash map, with a general key and value type.  It matches the interface and semantics of HashMap.  Unlike HashMap, its internal representation uses a functional hash trie (see `trie.mo`).
///
/// This class permits us to compare the performance of two representations of hash-based maps, where tries (as binary trees) permit more efficient, constant-time, cloning compared with ordinary tables.  This property is nice for supporting transactional workflows where map mutations may be provisional, and where we may expect some mutations to be uncommitted, or to "roll back".
///
/// For now, this class does not permit a direct `clone` operation (neither does `HashMap`), but it does permit creating iterators via `iter()`.  The effect is similar: Each iterator costs `O(1)` to create, but represents a fixed view of the mapping that does not interfere with mutations (it will _not_ view subsequent insertions or mutations, if any).

import T "Trie";
import P "Prelude";
import I "Iter";
import Hash "Hash";
import List "List";

/// An imperative hash-based map with a minimal object-oriented interface.
/// Maps keys of type `K` to values of type `V`.
///
/// See also: [`HashMap`](HashMap.html), with a matching interface.
/// Unlike HashMap, the iterators are persistent (pure), clones are cheap and the maps have an efficient persistent representation.
module {
public class TrieMap<K,V> (isEq:(K, K) -> Bool, hashOf: K -> Hash.Hash) {

  var map = T.empty<K, V>();
  var _size : Nat = 0;

  /// Returns the number of entries in the map.
  public func size() : Nat = _size;

  /// Associate a key and value, overwriting any prior association the key.
  public func put(k:K, v:V) =
    ignore replace(k, v);

  /// [`Put`](TrieMap.html#put) the key and value, _and_ return the (optional) prior value for the key.
  public func replace(k:K, v:V) : ?V {
    let keyObj = {key=k; hash=hashOf(k);};
    let (map2, ov) =
      T.put<K,V>(map, keyObj, isEq, v);
    map := map2;
    switch(ov){
    case null { _size += 1 };
    case _ {}
    };
    ov
  };

  /// Get the (optional) value associated with the given key.
  public func get(k:K) : ?V = {
    let keyObj = {key=k; hash=hashOf(k);};
    T.find<K,V>(map, keyObj, isEq)
  };

  /// Delete the (optional) value associated with the given key.
  public func delete(k:K) =
    ignore remove(k);

  /// [`Delete`](TrieMap.html#delete) and return the (optional) value associated with the given key.
  public func remove(k:K) : ?V = {
    let keyObj = {key=k; hash=hashOf(k);};
    let (t, ov) = T.remove<K, V>(map, keyObj, isEq);
    map := t;
    switch(ov){
    case null { _size -= 1 };
    case _ {}
    };
    ov
  };

  /// Returns an [`Iter`](Iter.html#type.Iter) over the entries.
  ///
  /// Each iterator gets a _persistent view_ of the mapping, independent of concurrent updates to the iterated map.
  public func entries() : I.Iter<(K,V)> = object {
    var stack = ?(map, null) : List.List<T.Trie<K,V>>;
    public func next() : ?(K,V) {
      switch stack {
      case null { null };
      case (?(trie, stack2)) {
        switch trie {
        case (#empty) {
               stack := stack2;
               next()
             };
        case (#leaf({keyvals=null})) {
               stack := stack2;
               next()
             };
        case (#leaf({size=c; keyvals=?((k,v),kvs)})) {
               stack := ?(#leaf({size=c-1; keyvals=kvs}), stack2);
               ?(k.key, v)
             };
        case (#branch(br)) {
               stack := ?(br.left, ?(br.right, stack2));
               next()
             };
          }
         }
        }
      }
    };

  };


/// Clone the map, given its key operations.
public func clone<K,V>
  (h:TrieMap<K,V>,
   keyEq: (K,K) -> Bool,
   keyHash: K -> Hash.Hash) : TrieMap<K,V> {
  let h2 = TrieMap<K,V>(keyEq, keyHash);
  for ((k,v) in h.entries()) {
    h2.put(k,v);
  };
  h2
};

/// Clone an iterator of key-value pairs.
public func fromEntries<K, V>(entries:I.Iter<(K, V)>,
                              keyEq: (K,K) -> Bool,
                              keyHash: K -> Hash.Hash) : TrieMap<K,V> {
  let h = TrieMap<K,V>(keyEq, keyHash);
  for ((k,v) in entries) {
    h.put(k,v);
  };
  h
};

/// Transform (map) the values of a map, retaining its keys.
public func map<K, V1, V2>
  (h:TrieMap<K,V1>,
   keyEq: (K,K) -> Bool,
   keyHash: K -> Hash.Hash,
   mapFn: (K, V1) -> V2,
  ) : TrieMap<K,V2> {
  let h2 = TrieMap<K,V2>(keyEq, keyHash);
  for ((k, v1) in h.entries()) {
    let v2 = mapFn(k, v1);
    h2.put(k,v2);
  };
  h2
};

/// Transform and filter the values of a map, retaining its keys.
public func mapFilter<K, V1, V2>
  (h:TrieMap<K,V1>,
   keyEq: (K,K) -> Bool,
   keyHash: K -> Hash.Hash,
   mapFn: (K, V1) -> ?V2,
  ) : TrieMap<K,V2> {
  let h2 = TrieMap<K,V2>(keyEq, keyHash);
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
