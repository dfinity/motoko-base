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
    let MAX_CHILDREN = 32;

    let MIN_CHILDREN = 16;
  };

  public type Index<K, V> = {
    keys : [K];
    trees : [Tree<K, V>];
    // well-formedness invariants (see Check sub-module):
    // 1. keys.size() + 1 = subtrees.size()
    // 2. for all k in keysOf(subrees[i]),
    //    keys[i] <= k <= keys[i + 1]
  };

  public type Data<K, V> = {
    key : K;
    val : V;
  };

  public type Tree<K, V> = {
    #index : Index<K, V>;
    #data : Data<K, V>;
  };

  /// Check that a B-Tree instance observes invariants of B-Trees.
  /// Invariants ensure performance is what we expect.
  /// For testing and debugging.
  public module Check {

    public type Compare<K> = {
      compare : (K, K) -> Order.Order
    };

    type CompareOp<K> = {
      compare : (?K, ?K) -> Order.Order
    };

    func compareOp<K>(c : Compare<K>) : CompareOp<K> = {
      compare = func (k1 : ?K, k2 : ?K) : Order.Order {
        switch (k1, k2) {
        case (null, null) { assert false; loop { } };
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
        case (#data(d)) {
          assert (c.compare(lower, ?d.key) != #greater);
          assert (c.compare(?d.key, upper) != #greater);
        };
        case (#index(i)) { index(lower, c, i, upper) };
      }
    };

    func index<K, V>(lower : ?K, c : CompareOp<K>, i : Index<K, V>, upper : ?K) {
      assert (i.keys.size() + 1 == i.trees.size());
      for (j in I.range(0, i.keys.size() + 1)) {
        let lower = if (j == 0) { null } else { ?(i.keys[j - 1]) };
        let upper = if (j == i.keys.size()) { null } else { ?(i.keys[j - 1]) };
        rec(lower, c, i.trees[j], upper)
      }
    };
  };
}
