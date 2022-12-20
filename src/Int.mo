/// Signed integer numbers with infinite precision (also called big integers).
///
/// Common integer functions.
/// Most operations on integers (e.g. addition) are also available as built-in operators (e.g. `1 + 1`).

import Prim "mo:⛔";
import Prelude "Prelude";
import Hash "Hash";

module {

  /// Infinite precision signed integers.
  public type Int = Prim.Types.Int;

  /// Returns the absolute value of `x`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.abs(-12) // => 12
  /// ```
  public let abs : (x : Int) -> Nat = Prim.abs;

  /// Conversion to Text.
  /// Formats the integer in decimal representation without underscore separators for blocks of thousands.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.toText(-1234) // => "-1234"
  /// ```
  public let toText : Int -> Text = func(x) {
    if (x == 0) {
      return "0"
    };

    let isNegative = x < 0;
    var int = if isNegative { -x } else { x };

    var text = "";
    let base = 10;

    while (int > 0) {
      let rem = int % base;
      text := (
        switch (rem) {
          case 0 { "0" };
          case 1 { "1" };
          case 2 { "2" };
          case 3 { "3" };
          case 4 { "4" };
          case 5 { "5" };
          case 6 { "6" };
          case 7 { "7" };
          case 8 { "8" };
          case 9 { "9" };
          case _ { Prelude.unreachable() }
        }
      ) # text;
      int := int / base
    };

    return if isNegative { "-" # text } else { text }
  };

  /// Returns the minimum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.min(+2, -3) // => -3
  /// ```
  public func min(x : Int, y : Int) : Int {
    if (x < y) { x } else { y }
  };

  /// Returns the maximum of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.max(+2, -3) // => 2
  /// ```
  public func max(x : Int, y : Int) : Int {
    if (x < y) { y } else { x }
  };

  // this is a local copy of deprecated Hash.hashNat8 (redefined to suppress the warning)
  private func hashNat8(key : [Nat32]) : Hash.Hash {
    var hash : Nat32 = 0;
    for (natOfKey in key.vals()) {
      hash := hash +% natOfKey;
      hash := hash +% hash << 10;
      hash := hash ^ (hash >> 6)
    };
    hash := hash +% hash << 3;
    hash := hash ^ (hash >> 11);
    hash := hash +% hash << 15;
    return hash
  };

  /// Computes a hash from the least significant 32-bits of `i`, ignoring other bits.
  /// @deprecated For large `Int` values consider using a bespoke hash function that considers all of the argument's bits.
  public func hash(i : Int) : Hash.Hash {
    // CAUTION: This removes the high bits!
    let j = Prim.int32ToNat32(Prim.intToInt32Wrap(i));
    hashNat8([
      j & (255 << 0),
      j & (255 << 8),
      j & (255 << 16),
      j & (255 << 24)
    ])
  };

  /// Computes an accumulated hash from `h1` and the least significant 32-bits of `i`, ignoring other bits in `i`.
  /// @deprecated For large `Int` values consider using a bespoke hash function that considers all of the argument's bits.
  public func hashAcc(h1 : Hash.Hash, i : Int) : Hash.Hash {
    // CAUTION: This removes the high bits!
    let j = Prim.int32ToNat32(Prim.intToInt32Wrap(i));
    hashNat8([
      h1,
      j & (255 << 0),
      j & (255 << 8),
      j & (255 << 16),
      j & (255 << 24)
    ])
  };

  /// Returns `x == y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.equal(123, 123) // => true
  /// ```
  public func equal(x : Int, y : Int) : Bool { x == y };

  /// Returns `x != y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.notEqual(123, 123) // => false
  /// ```
  public func notEqual(x : Int, y : Int) : Bool { x != y };

  /// Returns `x < y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.less(123, 1234) // => true
  /// ```
  public func less(x : Int, y : Int) : Bool { x < y };

  /// Returns `x <= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.lessOrEqual(123, 1234) // => true
  /// ```
  public func lessOrEqual(x : Int, y : Int) : Bool { x <= y };

  /// Returns `x > y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.greater(1234, 123) // => true
  /// ```
  public func greater(x : Int, y : Int) : Bool { x > y };

  /// Returns `x >= y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.greaterOrEqual(1234, 123) // => true
  /// ```
  public func greaterOrEqual(x : Int, y : Int) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.compare(123, 1234) // => #less
  /// ```
  public func compare(x : Int, y : Int) : { #less; #equal; #greater } {
    if (x < y) { #less } else if (x == y) { #equal } else { #greater }
  };

  /// Returns the negation of `x`, `-x` .
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.neq(123) // => -123
  /// ```
  public func neq(x : Int) : Int { -x }; // Typo: Should be changed to `neg`

  /// Returns the sum of `x` and `y`, `x + y`.
  ///
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.add(1234, 123) // => 1_357
  /// ```
  public func add(x : Int, y : Int) : Int { x + y };

  /// Returns the difference of `x` and `y`, `x - y`.
  ///
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.sub(1234, 123) // => 1_111
  /// ```
  public func sub(x : Int, y : Int) : Int { x - y };

  /// Returns the product of `x` and `y`, `x * y`.
  ///
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.mul(123, 100) // => 12_300
  /// ```
  public func mul(x : Int, y : Int) : Int { x * y };

  /// Returns the signed integer division of `x` by `y`,  `x / y`.
  /// Rounds the quotient towards zero, which is the same as truncating the decimal places of the quotient.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.div(123, 10) // => 12
  /// ```
  public func div(x : Int, y : Int) : Int { x / y };

  /// Returns the remainder of the signed integer division of `x` by `y`, `x % y`,
  /// which is defined as `x - x / y * y`.
  ///
  /// Traps when `y` is zero.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.rem(123, 10) // => 3
  /// ```
  public func rem(x : Int, y : Int) : Int { x % y };

  /// Returns `x` to the power of `y`, `x ** y`.
  ///
  /// Traps when `y` is negative or `y > 2 ** 32 - 1`.
  /// No overflow since `Int` has infinite precision.
  ///
  /// Example:
  /// ```motoko
  /// import Int "mo:base/Int";
  ///
  /// Int.pow(2, 10) // => 1_024
  /// ```
  public func pow(x : Int, y : Int) : Int { x ** y };

}
