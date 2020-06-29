/// Text values
///
/// This type describes a valid, human-readable text. It does not contain arbitrary
/// binary data.

import Iter "Iter";
import Hash "Hash";
import Prim "mo:prim";

module {

  // remove?
  public func append(x : Text, y : Text) : Text =
    x # y;

  /// Creates an [iterator](Iter.html#type.Iter) that traverses the characters of the text.
  public func toIter(text : Text) : Iter.Iter<Char> =
    text.chars();

  /// WARNING: This only hashes the lowest 32 bits of the `Int`
  public func hash(t : Text) : Hash.Hash {
    var x = 0 : Word32;
    for (c in t.chars()) {
      x := x ^ Prim.charToWord32(c);
    };
    return x
  };

  /// Returns `x == y`.
  public func equal(x : Text, y : Text) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Text, y : Text) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Text, y : Text) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Text, y : Text) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Text, y : Text) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Text, y : Text) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Text, y : Text) : { #less; #equal; #greater } {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };


}
