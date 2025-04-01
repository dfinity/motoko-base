/// Natural numbers with infinite precision.
/// 
/// :::note
/// Most operations on integer numbers (e.g. addition) are available as built-in operators (e.g. `1 + 1`).
/// This module provides equivalent functions and `Text` conversion.
/// :::
/// 
/// :::info [Function form for higher-order use]
/// 
/// Several arithmetic and comparison functions (e.g. `add`, `sub`, `equal`, `less`, `pow`) are defined in this module to enable their use as first-class function values, which is not possible with operators like `+`, `-`, `==`, etc., in Motoko. This allows you to pass these operations to higher-order functions such as `map`, `foldLeft`, or `sort`.
/// :::
/// 
/// Import from the base library to use this module.
/// 
/// ```motoko name=import
/// import Nat "mo:base/Nat";
/// ```

import Int "Int";
import Order "Order";
import Prim "mo:⛔";
import Char "Char";

module {

  ///  Infinite precision natural numbers.
  public type Nat = Prim.Types.Nat;

  ///  Converts a natural number to its textual representation. Textual
  ///  representation _do not_ contain underscores to represent commas.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.toText 1234 // => "1234"
  ///  ```
  public func toText(n : Nat) : Text = Int.toText n;

  ///  Creates a natural number from its textual representation. Returns `null`
  ///  if the input is not a valid natural number.
  /// 
  ///  :::note
  ///  The textual representation _must not_ contain underscores.
  /// :::
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.fromText "1234" // => ?1234
  ///  ```
  public func fromText(text : Text) : ?Nat {
    if (text == "") {
      return null
    };
    var n = 0;
    for (c in text.chars()) {
      if (Char.isDigit(c)) {
        let charAsNat = Prim.nat32ToNat(Prim.charToNat32(c) -% Prim.charToNat32('0'));
        n := n * 10 + charAsNat
      } else {
        return null
      }
    };
    ?n
  };

  ///  Returns the minimum of `x` and `y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.min(1, 2) // => 1
  ///  ```
  public func min(x : Nat, y : Nat) : Nat {
    if (x < y) { x } else { y }
  };

  ///  Returns the maximum of `x` and `y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.max(1, 2) // => 2
  ///  ```
  public func max(x : Nat, y : Nat) : Nat {
    if (x < y) { y } else { x }
  };

  ///  Equality function for Nat types.
  ///  This is equivalent to `x == y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.equal(1, 1); // => true
  ///  1 == 1 // => true
  ///  ```
  /// 

  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  import Buffer "mo:base/Buffer";
  /// 
  ///  let buffer1 = Buffer.Buffer<Nat>(3);
  ///  let buffer2 = Buffer.Buffer<Nat>(3);
  ///  Buffer.equal(buffer1, buffer2, Nat.equal) // => true
  ///  ```
  public func equal(x : Nat, y : Nat) : Bool { x == y };

  ///  Inequality function for Nat types.
  ///  This is equivalent to `x != y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.notEqual(1, 2); // => true
  ///  1 != 2 // => true
  ///  ```
  /// 

  public func notEqual(x : Nat, y : Nat) : Bool { x != y };

  ///  "Less than" function for Nat types.
  ///  This is equivalent to `x < y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.less(1, 2); // => true
  ///  1 < 2 // => true
  ///  ```
  /// 

  public func less(x : Nat, y : Nat) : Bool { x < y };

  ///  "Less than or equal" function for Nat types.
  ///  This is equivalent to `x <= y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.lessOrEqual(1, 2); // => true
  ///  1 <= 2 // => true
  ///  ```
  /// 

  public func lessOrEqual(x : Nat, y : Nat) : Bool { x <= y };

  ///  "Greater than" function for Nat types.
  ///  This is equivalent to `x > y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.greater(2, 1); // => true
  ///  2 > 1 // => true
  ///  ```
  /// 

  public func greater(x : Nat, y : Nat) : Bool { x > y };

  ///  "Greater than or equal" function for Nat types.
  ///  This is equivalent to `x >= y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.greaterOrEqual(2, 1); // => true
  ///  2 >= 1 // => true
  ///  ```
  /// 

  public func greaterOrEqual(x : Nat, y : Nat) : Bool { x >= y };

  ///  General purpose comparison function for `Nat`. Returns the `Order` (
  ///  either `#less`, `#equal`, or `#greater`) of comparing `x` with `y`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.compare(2, 3) // => #less
  ///  ```
  /// 
  ///  This function can be used as value for a high order function, such as a sort function.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  import Array "mo:base/Array";
  ///  Array.sort([2, 3, 1], Nat.compare) // => [1, 2, 3]
  ///  ```
  public func compare(x : Nat, y : Nat) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  ///  Returns the sum of `x` and `y`, `x + y`. This operator will never overflow
  ///  because `Nat` is infinite precision.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.add(1, 2); // => 3
  ///  1 + 2 // => 3
  ///  ```
  /// 

  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  import Array "mo:base/Array";
  ///  Array.foldLeft([2, 3, 1], 0, Nat.add) // => 6
  ///  ```
  public func add(x : Nat, y : Nat) : Nat { x + y };

  ///  Returns the difference of `x` and `y`, `x - y`.
  ///  Traps on underflow below `0`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.sub(2, 1); // => 1
  ///  // Add a type annotation to avoid a warning about the subtraction
  ///  2 - 1 : Nat // => 1
  ///  ```
  /// 

  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  import Array "mo:base/Array";
  ///  Array.foldLeft([2, 3, 1], 10, Nat.sub) // => 4
  ///  ```
  public func sub(x : Nat, y : Nat) : Nat { x - y };

  ///  Returns the product of `x` and `y`, `x * y`. This operator will never
  ///  overflow because `Nat` is infinite precision.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.mul(2, 3); // => 6
  ///  2 * 3 // => 6
  ///  ```
  /// 

  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  import Array "mo:base/Array";
  ///  Array.foldLeft([2, 3, 1], 1, Nat.mul) // => 6
  ///  ```
  public func mul(x : Nat, y : Nat) : Nat { x * y };

  ///  Returns the unsigned integer division of `x` by `y`,  `x / y`.
  ///  Traps when `y` is zero.
  /// 
  ///  The quotient is rounded down, which is equivalent to truncating the
  ///  decimal places of the quotient.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.div(6, 2); // => 3
  ///  6 / 2 // => 3
  ///  ```
  /// 

  public func div(x : Nat, y : Nat) : Nat { x / y };

  ///  Returns the remainder of unsigned integer division of `x` by `y`,  `x % y`.
  ///  Traps when `y` is zero.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.rem(6, 4); // => 2
  ///  6 % 4 // => 2
  ///  ```
  /// 

  public func rem(x : Nat, y : Nat) : Nat { x % y };

  ///  Returns `x` to the power of `y`, `x ** y`. Traps when `y > 2^32`. This operator
  ///  will never overflow because `Nat` is infinite precision.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  ignore Nat.pow(2, 3); // => 8
  ///  2 ** 3 // => 8
  ///  ```
  /// 

  public func pow(x : Nat, y : Nat) : Nat { x ** y };

  ///  Returns the (conceptual) bitwise shift left of `x` by `y`, `x * (2 ** y)`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.bitshiftLeft(1, 3); // => 8
  ///  ```
  /// 

  public func bitshiftLeft(x : Nat, y : Nat32) : Nat { Prim.shiftLeft(x, y) };

  ///  Returns the (conceptual) bitwise shift right of `x` by `y`, `x / (2 ** y)`.
  /// 
  ///  Example:
  ///  ```motoko include=import
  ///  Nat.bitshiftRight(8, 3); // => 1
  ///  ```
  /// 

  public func bitshiftRight(x : Nat, y : Nat32) : Nat { Prim.shiftRight(x, y) };

}
