/// Imperative sequences as B-Trees.

import A "Array";
import I "Iter";
import List "List";
import Text "Text";
import Option "Option";
import Order "Order";
import P "Prelude";
import Debug "Debug";
import Prim "mo:⛔";

module {

  /// Constants we use to shape the tree.
  /// See https://en.wikipedia.org/wiki/B-tree#Definition
  module Constants {
    let MAX_CHILDREN = 4;
  };

  public type Compare<K> = {
    show : K -> Text;
    compare : (K, K) -> Order.Order
  };

  public type Data<K, V> = [(K, V)];

  public type Internal<K, V> = {
    data : Data<K, V>;
    trees : [Tree<K, V>];
  };

  public type Tree<K, V> = {
    #internal : Internal<K, V>;
    #leaf : Data<K, V>;
  };

  func find_data<K, V>(data : Data<K, V>, find_k : K, c : (K, K) -> Order.Order) : ?V {
    for ((k, v) in data.vals()) {
      if (c(k, find_k) == #equal) { return ?v };
    };
    return null
  };

  public func find<K, V>(t : Tree<K, V>, k : K, c : (K, K) -> Order.Order) : ?V {
   switch t {
      case (#leaf(d)) { return find_data<K, V>(d, k, c) };
      case (#internal(i)) {
        for (j in I.range(0, i.data.size() - 1)) {
          switch (c(k, i.data[j].0)) {
            case (#equal) { return ?i.data[j].1 };
            case (#less) { return find<K, V>(i.trees[j], k, c) };
            case _ { }
          }
        };
        find<K, V>(i.trees[i.data.size()], k, c)
      };
    };
  };

  public module Insert {



  };

  // Assert that the given B-Tree instance observes all relevant invariants.
  // Used for unit tests.  Show function helps debug failing tests.
  //
  // Note: These checks-as-assertions can be refactored into value-producing checks,
  // if that seems useful.  Then, they can be individual matchers tests.  Again, if useful.
  public func assertIsValid<K, V>(
    t : Tree<K, V>,
    compare : (K, K) -> Order.Order,
    show : K -> Text)
  {
    Check.root<K, V>({compare; show}, t)
  };

  public func assertIsValidTextKeys<V>(t : Tree<Text, V>){
    Check.root<Text, V>({compare=Text.compare; show=func (t:Text) : Text { t }}, t)
  };
 
  /// Check that a B-Tree instance observes invariants of B-Trees.
  /// Invariants ensure performance is what we expect.
  /// For testing and debugging.
  ///
  /// Future refactoring --- Eventually, we can return Result or
  /// Option so that both valid and invalid inputs can be inspected in
  /// test cases.  Doing assertions directly here is easier, for now.
  module Check {

    type Inf<K> = {#infmax; #infmin; #finite : K};

    type InfCompare<K> = {
      compare : (Inf<K>, Inf<K>) -> Order.Order;
      show : Inf<K> -> Text
    };

    func infCompare<K>(c : Compare<K>) : InfCompare<K> = {
      show = func (k : Inf<K>) : Text {
        switch k {
          case (#infmax) "#infmax";
          case (#infmin) "#infmin";
          case (#finite k) "#finite(" # c.show k # ")";
        }
      };
      compare = func (k1 : Inf<K>, k2 : Inf<K>) : Order.Order {
        switch (k1, k2) {
        case (#infmin, _) #less;
        case (_, #infmin) { /* nonsense case. */ assert false; loop { } };
        case (_, #infmax) #less;
        case (#infmax, _) { /* nonsense case. */ assert false; loop { } };
        case (#finite(k1), #finite(k2)) c.compare(k1, k2);
        }
      }
    };

    public func root<K, V>(compare : Compare<K>, t : Tree<K, V>) {
      switch t {
        case (#leaf _) { rec(#infmin, infCompare(compare), t, #infmax) };
        case (#internal i) {
          if (i.data.size() == 0) { assert i.trees.size() == 0; return };
          if (i.trees.size() < 2) { assert false };
          rec(#infmin, infCompare(compare), t, #infmax)
        };
      }
    };

    func rec<K, V>(lower : Inf<K>, c : InfCompare<K>, t : Tree<K, V>, upper : Inf<K>) {
      switch t {
        case (#leaf(d)) { data(lower, c, d, upper) };
        case (#internal(i)) { internal(lower, c, i, upper) };
      }
    };

    func data<K, V>(lower : Inf<K>, c : InfCompare<K>, d : Data<K, V>, upper : Inf<K>) {
      var prev_k : Inf<K> = #infmin;
      for ((k, _) in d.vals()) {
        if false {
          Debug.print (c.show (#finite k));
        };
        assert (c.compare(prev_k, #finite k) == #less);
        assert (c.compare(lower, #finite k) == #less);
        assert (c.compare(#finite k, upper) == #less);
        prev_k := #finite k;
      };
    };

    func internal<K, V>(lower : Inf<K>, c : InfCompare<K>, i : Internal<K, V>, upper : Inf<K>) {
      // counts make sense when there is one tree between each pair of
      // consecutive key-value pairs; no key-value pairs on the end.
      assert (i.trees.size() == i.data.size() + 1);
      for (j in I.range(0, i.trees.size() - 1)) {
        let lower_ = if (j == 0) { lower } else { #finite(i.data[j - 1].0) };
        let upper_ = if (j + 1 == i.trees.size()) { upper } else { #finite((i.data[j]).0)
        };
        rec<K, V>(lower_, c, i.trees[j], upper_)
      }
    };
  };

}
