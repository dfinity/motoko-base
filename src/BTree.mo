/// Imperative sequences as B-Trees.

import A "Array";
import I "Iter";
import List "List";
import Option "Option";
import Order "Order";
import P "Prelude";
import Prim "mo:⛔";

module {

  /// Constants we use to shape the tree.
  /// See https://en.wikipedia.org/wiki/B-tree#Definition
  module Constants {
    let MAX_CHILDREN = 4;
  };

  public type Compare<K> = {
    compare : (K, K) -> Order.Order
  };

  public type Data<K, V> = [(K, V)];

  public type Index<K, V> = {
    data : Data<K, V>;
    trees : [Tree<K, V>];
  };

  public type Tree<K, V> = {
    #index : Index<K, V>;
    #data : Data<K, V>;
  };

  func find_data<K, V>(data : Data<K, V>, find_k : K, c : Compare<K>) : ?V {
    for ((k, v) in data.vals()) {
      if (c.compare(k, find_k) == #equal) { return ?v };
    };
    return null
  };

  func find<K, V>(t : Tree<K, V>, k : K, c : Compare<K>) : ?V {
    switch t {
      case (#data(d)) { return find_data<K, V>(d, k, c) };
      case (#index(i)) {
        for (j in I.range(0, i.data.size())) {
          switch (c.compare(k, i.data[j].0)) {
            case (#equal) { return ?i.data[j].1 };
            case (#less) { return find<K, V>(i.trees[j], k, c) };
            case _ { }
          }
        };
        find<K, V>(i.trees[i.data.size()], k, c)
      };
    };
  };

  /// Check that a B-Tree instance observes invariants of B-Trees.
  /// Invariants ensure performance is what we expect.
  /// For testing and debugging.
  public module Check {

    type CompareOp<K> = {
      compare : (?K, ?K) -> Order.Order
    };

    func compareOp<K>(c : Compare<K>) : CompareOp<K> = {
      compare = func (k1 : ?K, k2 : ?K) : Order.Order {
        switch (k1, k2) {
        case (null, null) { assert false; loop {} };
        case (null, _) #less;
        case (_, null) #greater;
        case (?k1, ?k2) c.compare(k1, k2)
        }
      }
    };

    public func check<K, V>(c : Compare<K>, t : Tree<K, V>) {
      rec(null, compareOp(c), t, null)
    };

    func rec<K, V>(lower : ?K, c : CompareOp<K>, t : Tree<K, V>, upper : ?K) {
      switch t {
        case (#data(d)) { data(lower, c, d, upper) };
        case (#index(i)) { index(lower, c, i, upper) };
      }
    };

    func data<K, V>(lower : ?K, c : CompareOp<K>, d : Data<K, V>, upper : ?K) {
      var prev_k : ?K = null;
      for ((k, _) in d.vals()) {
        assert (c.compare(prev_k, ?k) != #greater);
        assert (c.compare(lower, ?k) != #greater);
        assert (c.compare(?k, upper) != #greater);
        prev_k := ?k;
      }
    };

    func index<K, V>(lower : ?K, c : CompareOp<K>, i : Index<K, V>, upper : ?K) {
      assert (i.data.size() + 1 == i.trees.size());
      data(lower, c, i.data, upper);
      for (j in I.range(0, i.trees.size())) {
        let lower_ = if (j == 0) { lower } else { ?(i.data[j - 1].0) };
        let upper_ = if (j == i.data.size()) { upper } else { ?(i.data[j]).0 };
        rec<K, V>(lower_, c, i.trees[j], upper_)
      }
    };
  };

}
