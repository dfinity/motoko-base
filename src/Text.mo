/// Text values
///
/// This type describes a valid, human-readable text. It does not contain arbitrary
/// binary data.

import Iter "Iter";
import HT "HashType";
import Prim "mo:prim";

module {

  // remove?
  public func append(x : Text, y : Text) : Text =
    x # y;

  /// Creates an [iterator](Iter.html#type.Iter) that traverses the characters of the text.
  public func toIter(text : Text) : Iter.Iter<Char> =
    text.chars();

  public func equal(x : Text, y : Text) : Bool { x == y };

  /// WARNING: This only hashes the lowest 32 bits of the `Int`
  public func hash(t : Text) : HT.Hash {
    var x = 0 : Word32;
    for (c in t.chars()) {
      x := x ^ Prim.charToWord32(c);
    };
    return x
  };

}
