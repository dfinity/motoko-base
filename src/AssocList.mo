/// Map implemented as a linked-list of key-value pairs ("Associations").
///
/// NOTE: This map implementation is mainly used as underlying buckets for other map
/// structures. Thus, other map implementations are easier to use in most cases.

import List "List";

module {
  /// Import from the base library to use this module.
  ///
  /// ```motoko name=import
  /// import AssocList "mo:base/AssocList";
  /// import List "mo:base/List";
  /// import Nat "mo:base/Nat";
  ///
  /// type AssocList<K, V> = AssocList.AssocList<K, V>;
  /// ```
  ///
  /// Initialize an empty map using an empty list.
  /// ```motoko name=initialize include=import
  /// var map : AssocList<Nat, Nat> = List.nil(); // Empty list as an empty map
  /// map := null; // Alternative: null as empty list.
  /// map
  /// ```
  public type AssocList<K, V> = List.List<(K, V)>;

  /// Find the first value associated with key `key`, or null if no such key exists.
  /// Compares keys using the provided function `equal`.
  ///
  /// Example:
  /// ```motoko include=import,initialize
  /// // Add three entries to the map
  /// map := AssocList.replace(map, 0, Nat.equal, ?10).0;
  /// map := AssocList.replace(map, 1, Nat.equal, ?11).0;
  /// map := AssocList.replace(map, 2, Nat.equal, ?12).0;
  ///
  /// // Find value associated with key 1
  /// AssocList.find(map, 1, Nat.equal)
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func find<K, V>(
    map : AssocList<K, V>,
    key : K,
    equal : (K, K) -> Bool,
  ) : ?V {
    func rec(al : AssocList<K, V>) : ?V {
      label profile_assocList_find_rec : (?V) switch (al) {
        case (null) { label profile_assocList_find_end_fail : (?V) { null } };
        case (?((hd_k, hd_v), tl)) {
          if (equal(key, hd_k)) {
            label profile_assocList_find_end_success : (?V) {
              ?hd_v;
            };
          } else {
            rec(tl);
          };
        };
      };
    };
    label profile_assocList_find_begin : (?V) {
      rec(map);
    };
  };

  /// Maps `key` to `value` in `map`, and overwrites the old entry if the key
  /// was already present. Returns the old value if it existed, and null
  /// otherwise. Compares keys using the provided function `equal`.
  ///
  /// Example:
  /// ```motoko include=import,initialize
  /// // Add three entries to the map
  /// map := AssocList.replace(map, 0, Nat.equal, ?10).0;
  /// map := AssocList.replace(map, 1, Nat.equal, ?11).0;
  /// map := AssocList.replace(map, 2, Nat.equal, ?12).0;
  ///
  /// List.toArray(map)
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func replace<K, V>(
    map : AssocList<K, V>,
    key : K,
    equal : (K, K) -> Bool,
    value : ?V,
  ) : (AssocList<K, V>, ?V) {
    func rec(al : AssocList<K, V>) : (AssocList<K, V>, ?V) {
      switch (al) {
        case (null) {
          switch value {
            case (null) { (null, null) };
            case (?value) { (?((key, value), null), null) };
          };
        };
        case (?((hd_k, hd_v), tl)) {
          if (equal(key, hd_k)) {
            // if value is null, remove the key; otherwise, replace key's old value
            // return old value
            switch value {
              case (null) { (tl, ?hd_v) };
              case (?value) { (?((hd_k, value), tl), ?hd_v) };
            };
          } else {
            let (tl2, old_v) = rec(tl);
            (?((hd_k, hd_v), tl2), old_v);
          };
        };
      };
    };
    rec(map);
  };

  /// Produces a new map containing all entires from `map1` whose keys are not
  /// contained in `map2`. The "extra" entries in `map2` are ignored. Compares
  /// keys using the provided function `equal`.
  ///
  /// Example:
  /// ```motoko include=import,initialize
  /// // Create map1
  /// var map1 : AssocList<Nat, Nat> = null;
  /// map1 := AssocList.replace(map1, 0, Nat.equal, ?10).0;
  /// map1 := AssocList.replace(map1, 1, Nat.equal, ?11).0;
  /// map1 := AssocList.replace(map1, 2, Nat.equal, ?12).0;
  ///
  /// // Create map2
  /// var map2 : AssocList<Nat, Nat> = null;
  /// map2 := AssocList.replace(map2, 2, Nat.equal, ?12).0;
  /// map2 := AssocList.replace(map2, 3, Nat.equal, ?13).0;
  ///
  /// // Take the difference
  /// let newMap = AssocList.diff(map1, map2, Nat.equal);
  /// List.toArray(newMap)
  /// ```
  /// Runtime: O(size1 * size2)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func diff<K, V, W>(
    map1 : AssocList<K, V>,
    map2 : AssocList<K, W>,
    equal : (K, K) -> Bool,
  ) : AssocList<K, V> {
    func rec(al1 : AssocList<K, V>) : AssocList<K, V> {
      switch al1 {
        case (null) { null };
        case (?((k, v1), tl)) {
          switch (find<K, W>(map2, k, equal)) {
            case (null) { ?((k, v1), rec(tl)) };
            case (?v2) { rec(tl) };
          };
        };
      };
    };
    rec(map1);
  };

  /// Transform and combine the entries of two association lists.
  public func mapAppend<K, V, W, X>(
    al1 : AssocList<K, V>,
    al2 : AssocList<K, W>,
    vbin : (?V, ?W) -> X,
  ) : AssocList<K, X> = label profile_assocList_mapAppend : AssocList<K, X> {
    func rec(al1 : AssocList<K, V>, al2 : AssocList<K, W>) : AssocList<K, X> = label profile_assocList_mapAppend_rec : AssocList<K, X> {
      switch (al1, al2) {
        case (null, null) { null };
        case (?((k, v), al1_), _) { ?((k, vbin(?v, null)), rec(al1_, al2)) };
        case (null, ?((k, v), al2_)) { ?((k, vbin(null, ?v)), rec(null, al2_)) };
      };
    };
    rec(al1, al2);
  };

  /// Specialized version of `disj`, optimized for disjoint sub-spaces of keyspace (no matching keys).
  public func disjDisjoint<K, V, W, X>(
    al1 : AssocList<K, V>,
    al2 : AssocList<K, W>,
    vbin : (?V, ?W) -> X,
  ) : AssocList<K, X> = label profile_assocList_disjDisjoint : AssocList<K, X> {
    mapAppend<K, V, W, X>(al1, al2, vbin);
  };

  /// This operation generalizes the notion of "set union" to finite maps.
  /// Produces a "disjunctive image" of the two lists, where the values of
  /// matching keys are combined with the given binary operator.
  ///
  /// For unmatched entries, the operator is still applied to
  /// create the value in the image.  To accomodate these various
  /// situations, the operator accepts optional values, but is never
  /// applied to (null, null).
  public func disj<K, V, W, X>(
    al1 : AssocList<K, V>,
    al2 : AssocList<K, W>,
    keq : (K, K) -> Bool,
    vbin : (?V, ?W) -> X,
  ) : AssocList<K, X> {
    func rec1(al1Rec : AssocList<K, V>) : AssocList<K, X> {
      switch al1Rec {
        case (null) {
          func rec2(al2 : AssocList<K, W>) : AssocList<K, X> {
            switch al2 {
              case (null) { null };
              case (?((k, v2), tl)) {
                switch (find<K, V>(al1, k, keq)) {
                  case (null) { ?((k, vbin(null, ?v2)), rec2(tl)) };
                  case (?v1) { ?((k, vbin(?v1, ?v2)), rec2(tl)) };
                };
              };
            };
          };
          rec2(al2);
        };
        case (?((k, v1), tl)) {
          switch (find<K, W>(al2, k, keq)) {
            case (null) { ?((k, vbin(?v1, null)), rec1(tl)) };
            case (?v2) { /* handled above */ rec1(tl) };
          };
        };
      };
    };
    rec1(al1);
  };

  /// This operation generalizes the notion of "set intersection" to
  /// finite maps.  Produces a "conjuctive image" of the two lists, where
  /// the values of matching keys are combined with the given binary
  /// operator, and unmatched entries are not present in the output.
  public func join<K, V, W, X>(
    al1 : AssocList<K, V>,
    al2 : AssocList<K, W>,
    keq : (K, K) -> Bool,
    vbin : (V, W) -> X,
  ) : AssocList<K, X> {
    func rec(al1 : AssocList<K, V>) : AssocList<K, X> {
      switch al1 {
        case (null) { null };
        case (?((k, v1), tl)) {
          switch (find<K, W>(al2, k, keq)) {
            case (null) { rec(tl) };
            case (?v2) { ?((k, vbin(v1, v2)), rec(tl)) };
          };
        };
      };
    };
    rec(al1);
  };

  /// Fold the entries based on the recursive list structure.
  public func fold<K, V, X>(
    al : AssocList<K, V>,
    nil : X,
    cons : (K, V, X) -> X,
  ) : X {
    func rec(al : AssocList<K, V>) : X {
      switch al {
        case null { nil };
        case (?((k, v), t)) { cons(k, v, rec(t)) };
      };
    };
    rec(al);
  };

};
