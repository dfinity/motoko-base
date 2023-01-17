/// Stack collection (LIFO discipline).
///
/// Minimal LIFO (last in first out) implementation, as a class.
/// See library `Deque` for mixed LIFO/FIFO behavior.
///
import List "List";

module {

  public class Stack<T>() {

    var stack : List.List<T> = List.nil<T>();

    /// Push an element on the top of the stack.
    ///
    /// Example:
    /// ```motoko
    /// import Stack "mo:base/Stack";
    ///
    /// let stack = Stack.Stack<Nat>();
    /// stack.push(1);
    /// stack.push(2);
    /// stack.push(3);
    /// stack.peek();
    /// ```
    ///
    /// Runtime: O(1)
    /// Space: O(1)
    public func push(x : T) {
      stack := ?(x, stack)
    };

    /// True when the stack is empty.
    ///
    /// Example:
    /// ```motoko
    /// import Stack "mo:base/Stack";
    ///
    /// let stack = Stack.Stack<Nat>();
    /// stack.isEmpty();
    /// ```
    ///
    /// Runtime: O(1)
    /// Space: O(1)
    public func isEmpty() : Bool {
      List.isNil<T>(stack)
    };

    /// Return and retain the top element, or return null.
    ///
    /// Example:
    /// ```motoko
    /// import Stack "mo:base/Stack";
    ///
    /// let stack = Stack.Stack<Nat>();
    /// stack.push(1);
    /// stack.push(2);
    /// stack.push(3);
    /// stack.peek();
    /// ```
    ///
    /// Runtime: O(1)
    /// Space: O(1)
    public func peek() : ?T {
      switch stack {
        case null { null };
        case (?(h, t)) { ?h }
      }
    };

    /// Remove and return the top element, or return null.
    ///
    /// Example:
    /// ```motoko
    /// import Stack "mo:base/Stack";
    ///
    /// let stack = Stack.Stack<Nat>();
    /// stack.push(1);
    ///
    /// ignore stack.pop();
    /// stack.isEmpty();
    /// ```
    ///
    /// Runtime: O(1)
    /// Space: O(1)
    public func pop() : ?T {
      switch stack {
        case null { null };
        case (?(h, t)) { stack := t; ?h }
      }
    }
  }
}
