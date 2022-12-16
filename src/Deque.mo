/// Double-ended queue (deque) of a generic element type `T`.
///
/// Purely functional design. Immutable deque values.
/// New deque values are returned by the push and pop functions.
///
/// Examples of use-cases:
/// Queue (FIFO) by using `pushBack()` and `popFront()`.
/// Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// It is internally implemented as two lists, a head access list and a tail access list,
/// that are dynamically size-balanced by splitting.
///
/// Construction: Create a new deque with the `empty<T>()` function.
///
/// Note on the costs of push and pop functions:
/// * Runtime: `O(1) amortized costs, `O(n)` worst case cost per single call.
/// * Space: `O(1) amortized costs, `O(n)` worst case cost per single call.
/// * Garbage: The implementation creates `O(n)` short-lived objects on splitting.
///
/// `n` denotes the number of elements stored in the deque.

import List "List";
import P "Prelude";

module {
  type List<T> = List.List<T>;

  /// Double-ended queue (deque) data type.
  public type Deque<T> = (List<T>, List<T>);

  /// Create a new empty deque.
  ///
  /// Example:
  /// ```
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.empty<Nat>()
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func empty<T>() : Deque<T> { (List.nil(), List.nil()) };

  /// Determine whether a deque is empty.
  /// Returns true if `deque` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.empty<Nat>();
  /// Deque.isEmpty(deque) // => true
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  public func isEmpty<T>(deque : Deque<T>) : Bool {
    switch deque {
      case (f, r) { List.isNil(f) and List.isNil(r) }
    }
  };

  func check<T>(q : Deque<T>) : Deque<T> {
    switch q {
      case (null, r) {
        let (a, b) = List.split(List.size(r) / 2, r);
        (List.reverse(b), a)
      };
      case (f, null) {
        let (a, b) = List.split(List.size(f) / 2, f);
        (a, List.reverse(b))
      };
      case q { q }
    }
  };

  /// Extend a deque by inserting a new element on the front end.
  /// Returns a new deque with `element` in the front followed by the elements of `deque`.
  ///
  /// This may involve dynamic splitting of the internally used two lists.
  ///
  /// Example:
  /// ```
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1) // deque with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func pushFront<T>(deque : Deque<T>, element : T) : Deque<T> {
    check(List.push(element, deque.0), deque.1)
  };

  /// Inspect the optional element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the front element of `deque`.
  ///
  /// Example:
  /// ```
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// Deque.peekFront(deque) // => ?1
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  ///
  public func peekFront<T>(deque : Deque<T>) : ?T {
    switch deque {
      case (?(x, f), r) { ?x };
      case (null, ?(x, r)) { ?x };
      case _ { null }
    }
  };

  /// Shorten a deque by removing the element on the front end.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of 
  /// the first element and a new deque that contains all the elements of `deque`, 
  /// however, without the front element.
  ///
  /// This may involve dynamic splitting of the internally used two lists.
  ///
  /// Example:
  /// ```motoko name=initialize
  /// import Deque "mo:base/Deque";
  ///
  /// let initial = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// let result = Deque.popFront(initial);
  /// let removedElement = result.0; // ?1
  /// let reducedDeque = result.1; // deque with element [2].
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func popFront<T>(deque : Deque<T>) : ?(T, Deque<T>) {
    switch deque {
      case (?(x, f), r) { ?(x, check(f, r)) };
      case (null, ?(x, r)) { ?(x, check(null, r)) };
      case _ { null }
    }
  };

  /// Extend a deque by inserting a new element on the back end.
  /// Returns a new deque with all the elements of `deque`, followed by `element` on the back.
  ///
  /// This may involve dynamic splitting of the internally used two lists.
  ///
  /// Example:
  /// ```
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2) // deque with elements [1, 2]
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func pushBack<T>(deque : Deque<T>, element : T) : Deque<T> {
    check(deque.0, List.push(element, deque.1))
  };

  /// Inspect the optional element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the back element of `deque`.
  ///
  /// Example:
  /// ```
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// Deque.peekBack(deque) // => ?2
  /// ```
  ///
  /// Runtime: `O(1)`.
  ///
  /// Space: `O(1)`.
  ///
  public func peekBack<T>(deque : Deque<T>) : ?T {
    switch deque {
      case (f, ?(x, r)) { ?x };
      case (?(x, r), null) { ?x };
      case _ { null }
    }
  };

  /// Shorten a deque by removing the element on the back end.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of 
  /// a new deque that contains all the elements of `deque` without the back element
  /// and as second pair item, the back element.
  ///
  /// This may involve dynamic splitting of the internally used two lists.
  ///
  /// Example:
  /// ```motoko name=initialize
  /// import Deque "mo:base/Deque";
  ///
  /// let initial = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// let result = Deque.popFront(initial);
  /// let removedElement = result.0; // ?2
  /// let reducedDeque = result.1; // deque with element [1].
  /// ```
  ///
  /// Runtime: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// Space: `O(n)` worst-case, amortized to `O(1)`.
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func popBack<T>(deque : Deque<T>) : ?(Deque<T>, T) {
    switch deque {
      case (f, ?(x, r)) { ?(check(f, r), x) };
      case (?(x, f), null) { ?(check(f, null), x) };
      case _ { null }
    }
  }
}
