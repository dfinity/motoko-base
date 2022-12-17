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
    /// let s = Stack.Stack<Nat>();
    /// s.push(1);
    /// s.push(2);
    /// s.push(3);
    /// s.peek();
    /// ```
    ///
    public func push(x : T) {
      stack := ?(x, stack)
    };

    /// True when the stack is empty.
    ///
    /// Example:
    /// ```motoko
    /// import Stack "mo:base/Stack";
    ///
    /// let s = Stack.Stack<Nat>();
    /// s.isEmpty();
    /// ```
    ///
    public func isEmpty() : Bool {
      List.isNil<T>(stack)
    };

    /// Return and retain the top element, or return null.
    ///
    /// Example:
    /// ```motoko
    /// import Stack "mo:base/Stack";
    ///
    /// let s = Stack.Stack<Nat>();
    /// s.push(1);
    /// s.push(2);
    /// s.push(3);
    /// s.peek();
    /// ```
    ///
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
    /// let s = Stack.Stack<Nat>();
    /// s.push(1);
    ///
    /// let _ = s.pop();
    /// s.isEmpty();
    /// ```
    ///
    public func pop() : ?T {
      switch stack {
        case null { null };
        case (?(h, t)) { stack := t; ?h }
      }
    }
  }
}
