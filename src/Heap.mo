/// Class `Heap<X>` provides a priority queue of elements of type `X`.
///
/// The class wraps a purely-functional implementation based on a leftist heap.
///
/// Note on the constructor:
/// The constructor takes in a comparison function `compare` that defines the
/// ordering between elements of type `X`. Most primitive types have a default
/// version of this comparison function defined in their modules (e.g. `Nat.compare`).
/// The runtime analysis in this documentation assumes that the `compare` function
/// runs in `O(1)` time and space.
///
/// Example:
/// ```motoko name=initialize
/// import Heap "mo:base/Heap";
/// import Text "mo:base/Text";
///
/// let heap = Heap.Heap<Text>(Text.compare);
/// ```
///
/// Runtime: `O(1)`
///
/// Space: `O(1)`

import O "Order";
import P "Prelude";
import L "List";
import I "Iter";

module {

  public type Tree<X> = ?(Int, X, Tree<X>, Tree<X>);

  public class Heap<X>(compare : (X, X) -> O.Order) {
    var heap : Tree<X> = null;

    /// Inserts an element into the heap.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// heap.put("apple");
    /// heap.peekMin() // => ?"apple"
    /// ```
    ///
    /// Runtime: `O(log(n))`
    ///
    /// Space: `O(log(n))`
    public func put(x : X) {
      heap := merge(heap, ?(1, x, null, null), compare)
    };

    /// Return the minimal element in the heap, or `null` if the heap is empty.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// heap.put("apple");
    /// heap.put("banana");
    /// heap.put("cantaloupe");
    /// heap.peekMin() // => ?"apple"
    /// ```
    ///
    /// Runtime: `O(1)`
    ///
    /// Space: `O(1)`
    public func peekMin() : ?X {
      switch heap {
        case (null) { null };
        case (?(_, x, _, _)) { ?x }
      }
    };

    /// Delete the minimal element in the heap, if it exists.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// heap.put("apple");
    /// heap.put("banana");
    /// heap.put("cantaloupe");
    /// heap.deleteMin();
    /// heap.peekMin(); // => ?"banana"
    /// ```
    ///
    /// Runtime: `O(log(n))`
    ///
    /// Space: `O(log(n))`
    public func deleteMin() {
      switch heap {
        case null {};
        case (?(_, _, a, b)) { heap := merge(a, b, compare) }
      }
    };

    /// Delete and return the minimal element in the heap, if it exists.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// heap.put("apple");
    /// heap.put("banana");
    /// heap.put("cantaloupe");
    /// heap.removeMin(); // => ?"apple"
    /// ```
    ///
    /// Runtime: `O(log(n))`
    ///
    /// Space: `O(log(n))`
    public func removeMin() : (minElement : ?X) {
      switch heap {
        case null { null };
        case (?(_, x, a, b)) {
          heap := merge(a, b, compare);
          ?x
        }
      }
    };

    /// Return a snapshot of the internal functional tree representation as sharable data.
    /// The returned tree representation is not affected by subsequent changes of the `Heap` instance.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// heap.put("banana");
    /// heap.share();
    /// ```
    ///
    /// Useful for storing the heap as a stable variable, pretty-printing, and sharing it across async function calls,
    /// i.e. passing it in async arguments or async results.
    ///
    /// Runtime: `O(1)`
    ///
    /// Space: `O(1)`
    public func share() : Tree<X> {
      heap
    };

    /// Rewraps a snapshot of a heap (obtained by `share()`) in a `Heap` instance.
    /// The wrapping instance must be initialized with the same `compare`
    /// function that created the snapshot.
    ///
    /// Example:
    /// ```motoko include=initialize
    ///
    /// heap.put("apple");
    /// heap.put("banana");
    /// let snapshot = heap.share();
    /// let heapCopy = Heap.Heap<Text>(Text.compare);
    /// heapCopy.unsafeUnshare(snapshot);
    /// heapCopy.peekMin() // => ?"apple"
    /// ```
    ///
    /// Useful for loading a stored heap from a stable variable or accesing a heap
    /// snapshot passed from an async function call.
    ///
    /// Runtime: `O(1)`.
    ///
    /// Space: `O(1)`.
    public func unsafeUnshare(tree : Tree<X>) {
      heap := tree
    };

  };

  func rank<X>(heap : Tree<X>) : Int {
    switch heap {
      case null { 0 };
      case (?(r, _, _, _)) { r }
    }
  };

  func makeT<X>(x : X, a : Tree<X>, b : Tree<X>) : Tree<X> {
    if (rank(a) >= rank(b)) {
      ?(rank(b) + 1, x, a, b)
    } else {
      ?(rank(a) + 1, x, b, a)
    }
  };

  func merge<X>(h1 : Tree<X>, h2 : Tree<X>, compare : (X, X) -> O.Order) : Tree<X> {
    switch (h1, h2) {
      case (null, h) { h };
      case (h, null) { h };
      case (?(_, x, a, b), ?(_, y, c, d)) {
        switch (compare(x, y)) {
          case (#less) { makeT(x, a, merge(b, h2, compare)) };
          case _ { makeT(y, c, merge(d, h1, compare)) }
        }
      }
    }
  };

  /// Returns a new `Heap`, containing all entries given by the iterator `iter`.
  /// The new map is initialized with the provided `compare` function.
  ///
  /// Example:
  /// ```motoko include=initialize
  /// let entries = ["banana", "apple", "cantaloupe"];
  /// let iter = entries.vals();
  ///
  /// let newHeap = Heap.fromIter<Text>(iter, Text.compare);
  /// newHeap.peekMin() // => ?"apple"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func fromIter<X>(iter : I.Iter<X>, compare : (X, X) -> O.Order) : Heap<X> {
    let heap = Heap<X>(compare);
    func build(xs : L.List<Tree<X>>) : Tree<X> {
      func join(xs : L.List<Tree<X>>) : L.List<Tree<X>> {
        switch (xs) {
          case (null) { null };
          case (?(hd, null)) { ?(hd, null) };
          case (?(h1, ?(h2, tl))) { ?(merge(h1, h2, compare), join(tl)) }
        }
      };
      switch (xs) {
        case null { P.unreachable() };
        case (?(hd, null)) { hd };
        case _ { build(join(xs)) }
      }
    };
    let list = I.toList(I.map(iter, func(x : X) : Tree<X> { ?(1, x, null, null) }));
    if (not L.isNil(list)) {
      let t = build(list);
      heap.unsafeUnshare(t)
    };
    heap
  };

}
