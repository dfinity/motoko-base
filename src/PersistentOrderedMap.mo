/// Key-value map implemented as a red-black tree (RBTree) with nodes storing key-value pairs.
///
/// A red-black tree is a balanced binary search tree ordered by the keys.
///
/// The tree data structure internally colors each of its nodes either red or black,
/// and uses this information to balance the tree during the modifying operations.
///
/// Performance:
/// * Runtime: `O(log(n))` worst case cost per insertion, removal, and retrieval operation.
/// * Space: `O(n)` for storing the entire tree.
/// `n` denotes the number of key-value entries (i.e. nodes) stored in the tree.
///
/// Note:
/// * Map operations, such as retrieval, insertion, and removal create `O(log(n))` temporary objects that become garbage.
///
/// Credits:
///
/// The core of this implementation is derived from:
///
/// * Ken Friis Larsen's [RedBlackMap.sml](https://github.com/kfl/mosml/blob/master/src/mosmllib/Redblackmap.sml), which itself is based on:
/// * Stefan Kahrs, "Red-black trees with types", Journal of Functional Programming, 11(4): 425-432 (2001), [version 1 in web appendix](http://www.cs.ukc.ac.uk/people/staff/smk/redblack/rb.html).


import Debug "Debug";
import I "Iter";
import List "List";
import Nat "Nat";
import O "Order";

// TODO: a faster, more compact and less indirect representation would be:
// type Map<K, V> = {
//  #red : (Map<K, V>, K, V, Map<K, V>);
//  #black : (Map<K, V>, K, V, Map<K, V>);
//  #leaf
//};
// (this inlines the colors into the variant, flattens a tuple, and removes a (now) redundant optin, for considerable heap savings.)
// It would also make sense to maintain the size in a separate root for 0(1) access.

module {

  /// Node color: Either red (`#R`) or black (`#B`).
  public type Color = { #R; #B };

  /// Red-black tree of nodes with key-value entries, ordered by the keys.
  /// The keys have the generic type `K` and the values the generic type `V`.
  /// Leaves are considered implicitly black.
  public type Map<K, V> = {
    #node : (Color, Map<K, V>, (K, ?V), Map<K, V>);
    #leaf
  };

  type IterRep<X, Y> = List.List<{ #tr : Map<X, Y>; #xy : (X, ?Y) }>;

  /// Get an iterator for the entries of the `tree`, in ascending (`#fwd`) or descending (`#bwd`) order as specified by `direction`.
  /// The iterator takes a snapshot view of the tree and is not affected by concurrent modifications.
  ///
  /// Example:
  /// ```motoko
  /// // Write new examples
  /// ```
  ///
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the tree.
  ///
  /// Note: Full tree iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func iter<X, Y>(tree : Map<X, Y>, direction : { #fwd; #bwd }) : I.Iter<(X, Y)> {
    object {
      var trees : IterRep<X, Y> = ?(#tr(tree), null);
      public func next() : ?(X, Y) {
        switch (direction, trees) {
          case (_, null) { null };
          case (_, ?(#tr(#leaf), ts)) {
            trees := ts;
            next()
          };
          case (_, ?(#xy(xy), ts)) {
            trees := ts;
            switch (xy.1) {
              case null { next() };
              case (?y) { ?(xy.0, y) }
            }
          }; // TODO: Let's try to float-out case on direction
          case (#fwd, ?(#tr(#node(_, l, xy, r)), ts)) {
            trees := ?(#tr(l), ?(#xy(xy), ?(#tr(r), ts)));
            next()
          };
          case (#bwd, ?(#tr(#node(_, l, xy, r)), ts)) {
            trees := ?(#tr(r), ?(#xy(xy), ?(#tr(l), ts)));
            next()
          }
        }
      }
    }
  };

  /// Remove the value associated with a given key.
  public func removeRec<X, Y>(x : X, compare : (X, X) -> O.Order, t : Map<X, Y>) : (?Y, Map<X, Y>) {
    let (t1, r) = remove(t, compare, x);
    (r, t1);
  };

  public func getRec<X, Y>(x : X, compare : (X, X) -> O.Order, t : Map<X, Y>) : ?Y {
    switch t {
      case (#leaf) { null };
      case (#node(_c, l, xy, r)) {
        switch (compare(x, xy.0)) {
          case (#less) { getRec(x, compare, l) };
          case (#equal) { xy.1 };
          case (#greater) { getRec(x, compare, r) }
        }
      }
    }
  };

  /// Determine the size of the tree as the number of key-value entries.
  ///
  /// Example:
  /// ```motoko
  /// // Write new examples
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(1)` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the tree.
  ///
  /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
  public func size<X, Y>(t : Map<X, Y>) : Nat {
    switch t {
      case (#leaf) { 0 };
      case (#node(_, l, xy, r)) {
        size(l) + size(r) + (switch (xy.1) { case null 0; case _ 1 })
      }
    }
  };

  func redden<X, Y>(t : Map<X, Y>) : Map<X, Y> {
    switch t {
      case (#node (#B, l, xy, r)) {
        (#node (#R, l, xy, r))
      };
      case _ {
        Debug.trap "RBTree.red"
      }
    }
  };

  func lbalance<X,Y>(left : Map<X, Y>, xy : (X,?Y), right : Map<X, Y>) : Map<X,Y> {
    switch (left, right) {
      case (#node(#R, #node(#R, l1, xy1, r1), xy2, r2), r) {
        #node(
          #R,
          #node(#B, l1, xy1, r1),
          xy2,
          #node(#B, r2, xy, r))
      };
      case (#node(#R, l1, xy1, #node(#R, l2, xy2, r2)), r) {
        #node(
          #R,
          #node(#B, l1, xy1, l2),
          xy2,
          #node(#B, r2, xy, r))
      };
      case _ {
         #node(#B, left, xy, right)
      }
    }
  };

  func rbalance<X,Y>(left : Map<X, Y>, xy : (X,?Y), right : Map<X, Y>) : Map<X,Y> {
    switch (left, right) {
      case (l, #node(#R, l1, xy1, #node(#R, l2, xy2, r2))) {
        #node(
          #R,
          #node(#B, l, xy, l1),
          xy1,
          #node(#B, l2, xy2, r2))
      };
      case (l, #node(#R, #node(#R, l1, xy1, r1), xy2, r2)) {
        #node(
          #R,
          #node(#B, l, xy, l1),
          xy1,
          #node(#B, r1, xy2, r2))
      };
      case _ {
        #node(#B, left, xy, right)
      };
    }
  };

  public func insert<X, Y>(
    tree : Map<X, Y>,
    compare : (X, X) -> O.Order,
    x : X,
    y : Y
  )
  : (Map<X,Y>, ?Y) {
    var y0 : ?Y = null;
    func ins(tree : Map<X,Y>) : Map<X,Y> {
      switch tree {
        case (#leaf) {
          #node(#R, #leaf, (x,?y), #leaf)
        };
        case (#node(#B, left, xy, right)) {
          switch (compare (x, xy.0)) {
            case (#less) {
              lbalance(ins left, xy, right)
            };
            case (#greater) {
              rbalance(left, xy, ins right)
            };
            case (#equal) {
              y0 := xy.1;
              #node(#B, left, (x,?y), right)
            }
          }
        };
        case (#node(#R, left, xy, right)) {
          switch (compare (x, xy.0)) {
            case (#less) {
              #node(#R, ins left, xy, right)
            };
            case (#greater) {
              #node(#R, left, xy, ins right)
            };
            case (#equal) {
              y0 := xy.1;
              #node(#R, left, (x,?y), right)
            }
          }
        }
      };
    };
    switch (ins tree) {
      case (#node(#R, left, xy, right)) {
        (#node(#B, left, xy, right), y0);
      };
      case other { (other, y0) };
    };
  };


  func balLeft<X,Y>(left : Map<X, Y>, xy : (X,?Y), right : Map<X, Y>) : Map<X,Y> {
    switch (left, right) {
      case (#node(#R, l1, xy1, r1), r) {
        #node(
          #R,
          #node(#B, l1, xy1, r1),
          xy,
          r)
      };
      case (_, #node(#B, l2, xy2, r2)) {
        rbalance(left, xy, #node(#R, l2, xy2, r2))
      };
      case (_, #node(#R, #node(#B, l2, xy2, r2), xy3, r3)) {
        #node(#R,
          #node(#B, left, xy, l2),
          xy2,
          rbalance(r2, xy3, redden r3))
      };
      case _ { Debug.trap "balLeft" };
    }
  };

  func balRight<X,Y>(left : Map<X, Y>, xy : (X,?Y), right : Map<X, Y>) : Map<X,Y> {
    switch (left, right) {
      case (l, #node(#R, l1, xy1, r1)) {
        #node(#R,
          l,
          xy,
          #node(#B, l1, xy1, r1))
      };
      case (#node(#B, l1, xy1, r1), r) {
        lbalance(#node(#R, l1, xy1, r1), xy, r);
      };
      case (#node(#R, l1, xy1, #node(#B, l2, xy2, r2)), r3) {
        #node(#R,
          lbalance(redden l1, xy1, l2),
          xy2,
          #node(#B, r2, xy, r3))
      };
      case _ { Debug.trap "balRight" };
    }
  };

  func append<X,Y>(left : Map<X, Y>, right: Map<X, Y>) : Map<X, Y> {
    switch (left, right) {
      case (#leaf,  _) { right };
      case (_,  #leaf) { left };
      case (#node (#R, l1, xy1, r1),
            #node (#R, l2, xy2, r2)) {
        switch (append (r1, l2)) {
          case (#node (#R, l3, xy3, r3)) {
            #node(
              #R,
              #node(#R, l1, xy1, l3),
              xy3,
              #node(#R, r3, xy2, r2))
          };
          case r1l2 {
            #node(#R, l1, xy1, #node(#R, r1l2, xy2, r2))
          }
        }
      };
      case (t1, #node(#R, l2, xy2, r2)) {
        #node(#R, append(t1, l2), xy2, r2)
      };
      case (#node(#R, l1, xy1, r1), t2) {
        #node(#R, l1, xy1, append(r1, t2))
      };
      case (#node(#B, l1, xy1, r1), #node (#B, l2, xy2, r2)) {
        switch (append (r1, l2)) {
          case (#node (#R, l3, xy3, r3)) {
            #node(#R,
              #node(#B, l1, xy1, l3),
              xy3,
              #node(#B, r3, xy2, r2))
          };
          case r1l2 {
            balLeft (
              l1,
              xy1,
              #node(#B, r1l2, xy2, r2)
            )
          }
        }
      }
    }
  };

  func remove<X, Y>(tree : Map<X, Y>, compare : (X, X) -> O.Order, x : X) : (Map<X,Y>, ?Y) {
    var y0 : ?Y = null;
    func delNode(left : Map<X,Y>, xy : (X, ?Y), right : Map<X,Y>) : Map<X,Y> {
      switch (compare (x, xy.0)) {
        case (#less) {
          let newLeft = del left;
          switch left {
            case (#node(#B, _, _, _)) {
              balLeft(newLeft, xy, right)
            };
            case _ {
              #node(#R, newLeft, xy, right)
            }
          }
        };
        case (#greater) {
          let newRight = del right;
          switch right {
            case (#node(#B, _, _, _)) {
              balRight(left, xy, newRight)
            };
            case _ {
              #node(#R, left, xy, newRight)
            }
          }
        };
        case (#equal) {
          y0 := xy.1;
          append(left, right)
        };
      }
    };
    func del(tree : Map<X,Y>) : Map<X,Y> {
      switch tree {
        case (#leaf) {
          tree
        };
        case (#node(_, left, xy, right)) {
          delNode(left, xy, right)
        }
      };
    };
    switch (del(tree)) {
      case (#node(#R, left, xy, right)) {
        (#node(#B, left, xy, right), y0);
      };
      case other { (other, y0) };
    };
  }

}
