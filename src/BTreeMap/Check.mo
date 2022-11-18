/// Module that can be used to test whether or not a BTree is valid

import Iter "mo:base/Iter";
import O "mo:base/Order";
import Option "mo:base/Option";
import Result "mo:base/Result";

import Types "./Types";


module {
  /// Checks a BTree for validity, checking for both key ordering and node height/depth equivalence
  public func check<K, V>(t: Types.BTree<K, V>, compare: (K, K) -> O.Order): Bool {
    switch(checkTreeDepthIsValid(t)) {
      case (#err) { return false };
      case _ {}
    };

    switch(checkDataOrderIsValid(t, compare)) {
      case (#err) { false };
      case _ { true }
    }
  };

  public type CheckDepthResult = {
    #ok: Nat; // depth up to that point
    #err;
  };

  // Ensures that the Btree is balanced and all sibling/cousin nodes (at same level) have the same height
  public func checkTreeDepthIsValid<K, V>(t: Types.BTree<K, V>): CheckDepthResult {
    depthCheckerHelper(t.root)
  };

  func depthCheckerHelper<K, V>(node: Types.Node<K, V>): CheckDepthResult {
    switch(node) {
      case (#leaf(_)) { #ok(1) };
      case (#internal(internalNode)) {
        var depth = 1; 

        var i = 0;
        while (i < internalNode.children.size()) {
          if (i == 0) {
            switch(internalNode.children[i]) {
              case null {};
              case (?n) { switch(depthCheckerHelper(n)) {
                case (#err) { return #err };
                case (#ok(d)) { depth += d; };
              }}
            }
          } else {
            switch(internalNode.children[i]) {
              case null {};
              case (?n) { switch(depthCheckerHelper(n)) {
                case (#err) { return #err };
                case (#ok(d)) { 
                  if (d + 1 != depth) { return #err }
                };
              }}
            }
          };

          i += 1;
        };

        #ok(depth)
      }
    }
  };
  

  public type CheckOrderResult = {
    #ok;
    #err;
  };

  /// Ensures the ordering of all elements in the BTree is valid
  public func checkDataOrderIsValid<K, V>(t : Types.BTree<K, V>, compare: (K, K) -> O.Order): CheckOrderResult {
    // allow for empty root (valid)
    switch(t.root) {
      case (#leaf(leafNode)) {
        if (Option.isNull(leafNode.data.kvs[0])) {
          assert leafNode.data.count == 0
        }
      };
      case _ {}
    };

    rec(t.root, t.order, infCompare(compare), #infmin, #infmax)
  };

  func rec<K, V>(node : Types.Node<K, V>, order: Nat, compare : InfCompare<K>, lower : Inf<K>, upper : Inf<K>): CheckOrderResult {
    switch (node) {
      case (#leaf(leafNode)) { checkData(leafNode.data, order, compare, lower, upper) };
      case (#internal(internalNode)) { checkInternal(internalNode, order, compare, lower, upper) };
    }
  };

  func checkData<K, V>(data : Types.Data<K, V>, order: Nat, compare : InfCompare<K>, lower : Inf<K>, upper : Inf<K>): CheckOrderResult {
    let expectedMaxKeys: Nat = order - 1;
    if (data.kvs.size() != expectedMaxKeys) { return #err };

    var prevKey : ?Inf<K> = ?#infmin;
    for (el in data.kvs.vals()) {
      switch(el, prevKey) {
        case (null, _) { 
          prevKey := null 
        };
        case (?(k, _), null) { 
          return #err;
        };
        case (?(k, _), ?(pk)) {
          if (
            compare.compare(pk, #finite k) == #less
            and
            compare.compare(lower, #finite k) == #less
            and
            compare.compare(#finite k, upper) == #less
          ) {
            prevKey := ?#finite k;
          } else { return #err };
        }
      };
    };

    #ok
  };

  func checkInternal<K, V>(internal : Types.Internal<K, V>, order: Nat, compare: InfCompare<K>, lower : Inf<K>, upper : Inf<K>): CheckOrderResult {
    if (
      internal.children.size() != order
      or
      internal.children.size() != internal.data.kvs.size() + 1
    ) { return #err };

    switch(checkData(internal.data, order, compare, lower, upper)) {
      case (#err) { return #err };
      case _ {}
    };

    for (j in Iter.range(0, internal.data.kvs.size())) {
      // determine lower bound for internal.children[j]
      let lower_ =
        // if first element, take parent context lower bound
        if (j == 0) { lower }
        // otherwise compare against the previous element
        else {
          switch(internal.data.kvs[j-1]) {
            case null { return #err }; //assert false; loop {} }; // trap if the previous element is null
            case (?(prevKey, _)) { #finite prevKey };
          }
        };

      // determine upper bound for internal.children[j]
      let upper_ = 
        // if last element, take the parent context upper bound
        if (j == internal.data.kvs.size()) { upper } 
        else {
          switch(internal.data.kvs[j]) {
            // if null, take the parent context upper bound. will then short circuit return at end of this function
            case null { upper };
            case (?(key, _)) { #finite key }
          }
        };
      
      switch(internal.children[j]) {
        case null { return #err }; //assert false };
        case (?child) {
          // recurse on the child
          switch(rec<K, V>(child, order, compare, lower_, upper)) {
            case (#err) { return #err };
            case _ {};
          }
        }
      };

      if (j + 1 >= internal.children.size() or Option.isNull(internal.children[j+1])) { return #ok };
    };

    #ok;
  };


  type Inf<K> = {#infmax; #infmin; #finite : K };

  type InfCompare<K> = {
    compare : (Inf<K>, Inf<K>) -> O.Order;
  };

  func infCompare<K>(compare: (K, K) -> O.Order) : InfCompare<K> = {
    compare = func (k1 : Inf<K>, k2 : Inf<K>) : O.Order {
      switch (k1, k2) {
      case (#infmin, _) #less;
      case (_, #infmin) { /* nonsense case. */ assert false; loop { } };
      case (_, #infmax) #less;
      case (#infmax, _) { /* nonsense case. */ assert false; loop { } };
      case (#finite(k1), #finite(k2)) compare(k1, k2);
      }
    }
  };

}