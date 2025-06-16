/// Class `Stack<X>` provides a minimal LIFO stack of elements of type `X`.
///
/// See library `Deque` for mixed LIFO/FIFO behavior.
///
/// Example:
/// ```motoko name=initialize
/// import Stack "mo:base/Stack";
///
/// let stack = Stack.Stack<Nat>(); // create a stack
/// ```
/// | Runtime   | Space     |
/// |-----------|-----------|
/// | `O(1)` | `O(1)` |

import List "List";

module {

  public class Stack<T>() {

    var stack : List.List<T> = List.nil<T>();

    /// Push an element on the top of the stack.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// stack.push(1);
    /// stack.push(2);
    /// stack.push(3);
    /// stack.peek(); // examine the top most element
    /// ```
    /// | Runtime   | Space     |
    /// |-----------|-----------|
    /// | `O(1)` | `O(1)` |
    public func push(x : T) {
      stack := ?(x, stack)
    };

    /// True when the stack is empty and false otherwise.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// stack.isEmpty();
    /// ```
    ///
    /// | Runtime   | Space     |
    /// |-----------|-----------|
    /// | `O(1)` | `O(1)` |
    public func isEmpty() : Bool {
      List.isNil<T>(stack)
    };

    /// Return (without removing) the top element, or return null if the stack is empty.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// stack.push(1);
    /// stack.push(2);
    /// stack.push(3);
    /// stack.peek();
    /// ```
    ///
    /// | Runtime   | Space     |
    /// |-----------|-----------|
    /// | `O(1)` | `O(1)` |
    public func peek() : ?T {
      switch stack {
        case null { null };
        case (?(h, _)) { ?h }
      }
    };

    /// Remove and return the top element, or return null if the stack is empty.
    ///
    /// Example:
    /// ```motoko include=initialize
    /// stack.push(1);
    /// ignore stack.pop();
    /// stack.isEmpty();
    /// ```
    ///
    /// | Runtime   | Space     |
    /// |-----------|-----------|
    /// | `O(1)` | `O(1)` |
    public func pop() : ?T {
      switch stack {
        case null { null };
        case (?(h, t)) { stack := t; ?h }
      }
    }
  }
}
