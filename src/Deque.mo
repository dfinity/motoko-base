/// Double-ended queue (deque) of a generic element type `T`.
///
/// The interface of deques is purely functional, not imperative, and deques are immutable values.
/// In particular, deque operations such as push and pop do not update their input deque but instead return the value of the modified deque, alongside any other data.
/// The input deque is left unchanged.
///
/// Examples of use-cases:
/// Queue (FIFO) by using `pushBack()` and `popFront()`.
/// Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// A deque is internally implemented as two lists, a head access list and a (reversed) tail access list, that are dynamically size-balanced by splitting.
///
/// Construction: Create a new deque with the `empty<T>()` function.
///
/// :::note Performance characteristics
///
/// Push and pop operations have `O(1)` amortized cost and `O(n)` worst-case cost per call.
/// Space usage follows the same pattern.
/// `n` denotes the number of elements stored in the deque.
/// :::

import List "List";
import P "Prelude";

module {
  type List<T> = List.List<T>;

  /// Double-ended queue (deque) data type.
  public type Deque<T> = (List<T>, List<T>);

  /// Create a new empty deque.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.empty<Nat>()
  /// ```
  ///
  /// | Runtime | Space |
  /// |---------|--------|
  /// | `O(1)`  | `O(1)` |

  public func empty<T>() : Deque<T> { (List.nil(), List.nil()) };

  /// Determine whether a deque is empty.
  /// Returns true if `deque` is empty, otherwise `false`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.empty<Nat>();
  /// Deque.isEmpty(deque) // => true
  /// ```
  ///
  /// | Runtime | Space |
  /// |---------|--------|
  /// | `O(1)`  | `O(1)` |
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

  /// Insert a new element on the front end of a deque.
  /// Returns the new deque with `element` in the front followed by the elements of `deque`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1) // deque with elements [1, 2]
  /// ```
  ///
  /// | Runtime (worst) | Runtime (amortized) | Space (worst) | Space (amortized) |
  /// |------------------|----------------------|----------------|---------------------|
  /// | `O(n)`           | `O(1)`               | `O(n)`         | `O(1)`              |
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func pushFront<T>(deque : Deque<T>, element : T) : Deque<T> {
    check(List.push(element, deque.0), deque.1)
  };

  /// Inspect the optional element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the front element of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// Deque.peekFront(deque) // => ?1
  /// ```
  ///
  /// | Runtime | Space |
  /// |---------|--------|
  /// | `O(1)`  | `O(1)` |
  ///
  public func peekFront<T>(deque : Deque<T>) : ?T {
    switch deque {
      case (?(x, _f), _r) { ?x };
      case (null, ?(x, _r)) { ?x };
      case _ { null }
    }
  };

  /// Remove the element on the front end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of
  /// the first element and a new deque that contains all the remaining elements of `deque`.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  /// import Debug "mo:base/Debug";
  /// let initial = Deque.pushFront(Deque.pushFront(Deque.empty<Nat>(), 2), 1);
  /// // initial deque with elements [1, 2]
  /// let reduced = Deque.popFront(initial);
  /// switch reduced {
  ///   case null {
  ///     Debug.trap "Empty queue impossible"
  ///   };
  ///   case (?result) {
  ///     let removedElement = result.0; // 1
  ///     let reducedDeque = result.1; // deque with element [2].
  ///   }
  /// }
  /// ```
  ///
  /// | Runtime (worst) | Runtime (amortized) | Space (worst) | Space (amortized) |
  /// |------------------|----------------------|----------------|---------------------|
  /// | `O(n)`           | `O(1)`               | `O(n)`         | `O(1)`              |
  public func popFront<T>(deque : Deque<T>) : ?(T, Deque<T>) {
    switch deque {
      case (?(x, f), r) { ?(x, check(f, r)) };
      case (null, ?(x, r)) { ?(x, check(null, r)) };
      case _ { null }
    }
  };

  /// Insert a new element on the back end of a deque.
  /// Returns the new deque with all the elements of `deque`, followed by `element` on the back.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2) // deque with elements [1, 2]
  /// ```
  ///
  /// | Runtime (worst) | Runtime (amortized) | Space (worst) | Space (amortized) |
  /// |------------------|----------------------|----------------|---------------------|
  /// | `O(n)`           | `O(1)`               | `O(n)`         | `O(1)`              |
  ///
  /// `n` denotes the number of elements stored in the deque.
  public func pushBack<T>(deque : Deque<T>, element : T) : Deque<T> {
    check(deque.0, List.push(element, deque.1))
  };

  /// Inspect the optional element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, the back element of `deque`.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  ///
  /// let deque = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// Deque.peekBack(deque) // => ?2
  /// ```
  ///
  /// | Runtime | Space |
  /// |---------|--------|
  /// | `O(1)`  | `O(1)` |
  ///
  ///
  public func peekBack<T>(deque : Deque<T>) : ?T {
    switch deque {
      case (_f, ?(x, _r)) { ?x };
      case (?(x, _r), null) { ?x };
      case _ { null }
    }
  };

  /// Remove the element on the back end of a deque.
  /// Returns `null` if `deque` is empty. Otherwise, it returns a pair of
  /// a new deque that contains the remaining elements of `deque`
  /// and, as the second pair item, the removed back element.
  ///
  /// This may involve dynamic rebalancing of the two, internally used lists.
  ///
  /// Example:
  /// ```motoko
  /// import Deque "mo:base/Deque";
  /// import Debug "mo:base/Debug";
  ///
  /// let initial = Deque.pushBack(Deque.pushBack(Deque.empty<Nat>(), 1), 2);
  /// // initial deque with elements [1, 2]
  /// let reduced = Deque.popBack(initial);
  /// switch reduced {
  ///   case null {
  ///     Debug.trap "Empty queue impossible"
  ///   };
  ///   case (?result) {
  ///     let reducedDeque = result.0; // deque with element [1].
  ///     let removedElement = result.1; // 2
  ///   }
  /// }
  /// ```
  ///
  /// | Runtime (worst) | Runtime (amortized) | Space (worst) | Space (amortized) |
  /// |------------------|----------------------|----------------|---------------------|
  /// | `O(n)`           | `O(1)`               | `O(n)`         | `O(1)`              |
  public func popBack<T>(deque : Deque<T>) : ?(Deque<T>, T) {
    switch deque {
      case (f, ?(x, r)) { ?(check(f, r), x) };
      case (?(x, f), null) { ?(check(f, null), x) };
      case _ { null }
    }
  }
}
