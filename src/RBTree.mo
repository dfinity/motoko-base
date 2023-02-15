/// Key-value map implemented as a red-black tree (RBTree) with nodes storing key-value pairs.
///
/// A red-black tree is a balanced binary search tree ordered by the keys.
///
/// The tree data structure internally colors each of its nodes either red or black,
/// and uses this information to balance the tree during the modifying operations.
///
/// Creation:
/// Instantiate class `RBTree<K, V>` that provides a map from keys of type `K` to values of type `V`.
///
/// Example:
/// ```motoko
/// import RBTree "mo:base/RBTree";
/// import Nat "mo:base/Nat";
/// import Debug "mo:base/Debug";
///
/// let tree = RBTree.RBTree<Nat, Text>(Nat.compare); // Create a new red-black tree mapping Nat to Text
/// tree.put(1, "one");
/// tree.put(2, "two");
/// tree.put(3, "tree");
/// for (entry in tree.entries()) {
///   Debug.print("Entry key=" # debug_show(entry.0) # " value=\"" # entry.1 #"\"");
/// }
/// ```
///
/// Performance:
/// * Runtime: `O(log(n))` worst case cost per insertion, removal, and retrieval operation.
/// * Space: `O(n)` for storing the entire tree.
/// `n` denotes the number of key-value entries (i.e. nodes) stored in the tree.
///
/// Note:
/// * Tree operations, such as retrieval, insertion, and removal create `O(log(n))` temporary objects that become garbage.

import Debug "Debug";
import I "Iter";
import List "List";
import Nat "Nat";
import O "Order";

module {

  /// Node color: Either red (`#R`) or black (`#B`).
  public type Color = { #R; #B };

  /// Red-black tree of nodes with key-value entries, ordered by the keys.
  /// The keys have the generic type `K` and the values the generic type `V`.
  /// Leaves are considered implicitly black.
  public type Tree<K, V> = {
    #node : (Color, Tree<K, V>, (K, ?V), Tree<K, V>);
    #leaf
  };

  /// A map from keys of type `K` to values of type `V` implemented as a red-black tree.
  /// The entries of key-value pairs are ordered by `compare` function applied to the keys.
  ///
  /// The class enables imperative usage in object-oriented-style.
  /// However, internally, the class uses a functional implementation.
  ///
  /// The `compare` function should implement a consistent total order among all possible values of `K` and
  /// for efficiency, only involves `O(1)` runtime costs without space allocation.
  ///
  /// Example:
  /// ```motoko name=initialize
  /// import RBTree "mo:base/RBTree";
  /// import Nat "mo:base/Nat";
  ///
  /// let tree = RBTree.RBTree<Nat, Text>(Nat.compare); // Create a map of `Nat` to `Text` using the `Nat.compare` order
  /// ```
  ///
  /// Costs of instantiation (only empty tree):
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public class RBTree<K, V>(compare : (K, K) -> O.Order) {

    var tree : Tree<K, V> = (#leaf : Tree<K, V>);

    /// Return a snapshot of the internal functional tree representation as sharable data.
    /// The returned tree representation is not affected by subsequent changes of the `RBTree` instance.
    ///
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// tree.put(1, "one");
    /// let treeSnapshot = tree.share();
    /// tree.put(2, "second");
    /// RBTree.size(treeSnapshot) // => 1 (Only the first insertion is part of the snapshot.)
    /// ```
    ///
    /// Useful for storing the tree as a stable variable, determining its size, pretty-printing, and sharing it across async function calls,
    /// i.e. passing it in async arguments or async results.
    ///
    /// Runtime: `O(1)`.
    /// Space: `O(1)`.
    public func share() : Tree<K, V> {
      tree
    };

    /// Retrieve the value associated with a given key, if present. Returns `null`, if the key is absent.
    /// The key is searched according to the `compare` function defined on the class instantiation.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// tree.put(1, "one");
    /// tree.put(2, "two");
    ///
    /// tree.get(1) // => ?"one"
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func get(key : K) : ?V {
      getRec(key, compare, tree)
    };

    /// Replace the value associated with a given key, if the key is present.
    /// Otherwise, if the key does not yet exist, insert the key-value entry.
    ///
    /// Returns the previous value of the key, if the key already existed.
    /// Otherwise, `null`, if the key did not yet exist before.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Iter "mo:base/Iter";
    ///
    /// tree.put(1, "old one");
    /// tree.put(2, "two");
    ///
    /// ignore tree.replace(1, "new one");
    /// Iter.toArray(tree.entries()) // => [(1, "new one"), (2, "two")]
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func replace(key : K, value : V) : ?V {
      let (t, res) = insert(tree, compare, key, value);
      tree := t;
      res
    };

    /// Insert a key-value entry in the tree. If the key already exists, it overwrites the associated value.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Iter "mo:base/Iter";
    ///
    /// tree.put(1, "one");
    /// tree.put(2, "two");
    /// tree.put(3, "three");
    /// Iter.toArray(tree.entries()) // now contains three entries
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func put(key : K, value : V) {
      let (t, res) = insert(tree, compare, key, value);
      tree := t
    };

    /// Delete the entry associated with a given key, if the key exists.
    /// No effect if the key is absent. Same as `remove(key)` except that it
    /// does not have a return value.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Iter "mo:base/Iter";
    ///
    /// tree.put(1, "one");
    /// tree.put(2, "two");
    ///
    /// tree.delete(1);
    /// Iter.toArray(tree.entries()) // => [(2, "two")].
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func delete(key : K) {
      let (res, t) = removeRec(key, compare, tree);
      tree := t
    };

    /// Remove the entry associated with a given key, if the key exists, and return the associated value.
    /// Returns `null` without any other effect if the key is absent.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Iter "mo:base/Iter";
    ///
    /// tree.put(1, "one");
    /// tree.put(2, "two");
    ///
    /// ignore tree.remove(1);
    /// Iter.toArray(tree.entries()) // => [(2, "two")].
    /// ```
    ///
    /// Runtime: `O(log(n))`.
    /// Space: `O(1)` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree and
    /// assuming that the `compare` function implements an `O(1)` comparison.
    ///
    /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
    public func remove(key : K) : ?V {
      let (res, t) = removeRec(key, compare, tree);
      tree := t;
      res
    };

    /// An iterator for the key-value entries of the map, in ascending key order.
    /// The iterator takes a snapshot view of the tree and is not affected by concurrent modifications.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Debug "mo:base/Debug";
    ///
    /// tree.put(1, "one");
    /// tree.put(2, "two");
    /// tree.put(3, "two");
    ///
    /// for (entry in tree.entries()) {
    ///   Debug.print("Entry key=" # debug_show(entry.0) # " value=\"" # entry.1 #"\"");
    /// }
    ///
    /// // Entry key=1 value="one"
    /// // Entry key=2 value="two"
    /// // Entry key=3 value="three"
    /// ```
    ///
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: `O(log(n))` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree.
    ///
    /// Note: Full tree iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func entries() : I.Iter<(K, V)> { iter(tree, #fwd) };

    /// An iterator for the key-value entries of the map, in descending key order.
    /// The iterator takes a snapshot view of the tree and is not affected by concurrent modifications.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// import Debug "mo:base/Debug";
    ///
    /// let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
    /// tree.put(1, "one");
    /// tree.put(2, "two");
    /// tree.put(3, "two");
    ///
    /// for (entry in tree.entriesRev()) {
    ///   Debug.print("Entry key=" # debug_show(entry.0) # " value=\"" # entry.1 #"\"");
    /// }
    ///
    /// // Entry key=3 value="three"
    /// // Entry key=2 value="two"
    /// // Entry key=1 value="one"
    /// ```
    ///
    /// Cost of iteration over all elements:
    /// Runtime: `O(n)`.
    /// Space: `O(log(n))` retained memory plus garbage, see the note below.
    /// where `n` denotes the number of key-value entries stored in the tree.
    ///
    /// Note: Full tree iteration creates `O(n)` temporary objects that will be collected as garbage.
    public func entriesRev() : I.Iter<(K, V)> { iter(tree, #bwd) };

  }; // end class

  type IterRep<X, Y> = List.List<{ #tr : Tree<X, Y>; #xy : (X, ?Y) }>;

  /// Get an iterator for the entries of the `tree`, in ascending (`#fwd`) or descending (`#bwd`) order as specified by `direction`.
  /// The iterator takes a snapshot view of the tree and is not affected by concurrent modifications.
  ///
  /// Example:
  /// ```motoko
  /// import RBTree "mo:base/RBTree";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  /// tree.put(1, "one");
  /// tree.put(2, "two");
  /// tree.put(3, "two");
  ///
  /// for (entry in RBTree.iter(tree.share(), #bwd)) { // backward iteration
  ///   Debug.print("Entry key=" # debug_show(entry.0) # " value=\"" # entry.1 #"\"");
  /// }
  ///
  /// // Entry key=3 value="three"
  /// // Entry key=2 value="two"
  /// // Entry key=1 value="one"
  /// ```
  ///
  /// Cost of iteration over all elements:
  /// Runtime: `O(n)`.
  /// Space: `O(log(n))` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the tree.
  ///
  /// Note: Full tree iteration creates `O(n)` temporary objects that will be collected as garbage.
  public func iter<X, Y>(tree : Tree<X, Y>, direction : { #fwd; #bwd }) : I.Iter<(X, Y)> {
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
          };
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
  func removeRec<X, Y>(x : X, compare : (X, X) -> O.Order, t : Tree<X, Y>) : (?Y, Tree<X, Y>) {
    let (t1, r) = remove(t, compare, x);
    (r, t1);
  };

  func getRec<X, Y>(x : X, compare : (X, X) -> O.Order, t : Tree<X, Y>) : ?Y {
    switch t {
      case (#leaf) { null };
      case (#node(c, l, xy, r)) {
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
  /// import RBTree "mo:base/RBTree";
  /// import Nat "mo:base/Nat";
  ///
  /// let tree = RBTree.RBTree<Nat, Text>(Nat.compare);
  /// tree.put(1, "one");
  /// tree.put(2, "two");
  /// tree.put(3, "three");
  ///
  /// RBTree.size(tree.share()) // 3 entries
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(1)` retained memory plus garbage, see the note below.
  /// where `n` denotes the number of key-value entries stored in the tree.
  ///
  /// Note: Creates `O(log(n))` temporary objects that will be collected as garbage.
  public func size<X, Y>(t : Tree<X, Y>) : Nat {
    switch t {
      case (#leaf) { 0 };
      case (#node(_, l, xy, r)) {
        size(l) + size(r) + (switch (xy.1) { case null 0; case _ 1 })
      }
    }
  };

  func redden<X, Y>(t : Tree<X, Y>) : Tree<X, Y> {
    switch t {
      case (#node (#B, l, xy, r)) {
        (#node (#R, l, xy, r))
      };
      case _ {
        Debug.trap "RBTree.red"
      }
    }
  };

  func lbalance<X,Y>(left : Tree<X, Y>, xy : (X,?Y), right : Tree<X, Y>) : Tree<X,Y> {
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

  func rbalance<X,Y>(left : Tree<X, Y>, xy : (X,?Y), right : Tree<X, Y>) : Tree<X,Y> {
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

  func insert<X, Y>(
    tree : Tree<X, Y>,
    compare : (X, X) -> O.Order,
    x : X,
    y : Y
  )
  : (Tree<X,Y>, ?Y) {
    var old : ?Y = null;
    func ins(tree : Tree<X,Y>) : Tree<X,Y> {
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
              old := xy.1;
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
              old := xy.1;
              #node(#R, left, (x,?y), right)
            }
          }
        }
      };
    };
    switch (ins tree) {
      case (#node(#R, left, xy, right)) {
        (#node(#B, left, xy, right), old);
      };
      case other { (other, old) };
    };
  };


  func balLeft<X,Y>(left : Tree<X, Y>, xy : (X,?Y), right : Tree<X, Y>) : Tree<X,Y> {
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

  func balRight<X,Y>(left : Tree<X, Y>, xy : (X,?Y), right : Tree<X, Y>) : Tree<X,Y> {
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

  func append<X,Y>(left : Tree<X, Y>, right: Tree<X, Y>) : Tree<X, Y> {
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

  func remove<X, Y>(tree : Tree<X, Y>, compare : (X, X) -> O.Order, x : X) : (Tree<X,Y>, ?Y) {
    // TODO optimize using var old,like insert
    func delNode(left : Tree<X,Y>, xy : (X, ?Y), right : Tree<X,Y>) : (Tree<X,Y>, ?Y) {
      switch (compare (x, xy.0)) {
        case (#equal) {
          (append(left, right), xy.1)
        };
        case (#less) {
          let (newLeft, r) = del left;
          (switch left {
            case (#node(#B, _, _, _)) {
              balLeft(newLeft, xy, right)
            };
            case _ {
              #node(#R, newLeft, xy, right)
            }
           },
          r)
        };
        case (#greater) {
          let (newRight, r) = del right;
          (switch right {
            case (#node(#B, _, _, _)) {
              balRight(left, xy, newRight)
            };
            case _ {
              #node(#R, left, xy, newRight)
            }
          },
          r)
        }
      }
    };
    func del(tree : Tree<X,Y>) : (Tree<X,Y>, ?Y) {
      switch tree {
        case (#leaf) {
          (tree, null)
        };
        case (#node(_, left, xy, right)) {
          delNode(left, xy, right)
        }
      };
    };
    switch (del(tree)) {
      case (#node(#R, left, xy, right), r) {
        (#node(#B, left, xy, right), r);
      };
      case other { other };
    };
  }

}
