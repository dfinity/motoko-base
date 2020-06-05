/// Hash values

import Prim "mo:prim";
import Iter "Iter";

module {
  /// Hash values represent a string of _hash bits_, packed into a `Word32`.
  public type Hash = Word32;

  /// The hash length, always 31.
  public let length : Nat = 31; // Why not 32?

  public func hashOfInt(i : Int) : Hash {
    let j = Prim.intToWord32(i);
    hashWord8s(
      [j & (255 << 0),
       j & (255 << 8),
       j & (255 << 16),
       j & (255 << 24)
      ]);
  };

  /// WARNING: This only hashes the lowest 32 bits of the `Int`
  public func hashOfIntAcc(h1 : Hash, i : Int) : Hash {
    let j = Prim.intToWord32(i);
    hashWord8s(
      [h1,
       j & (255 << 0),
       j & (255 << 8),
       j & (255 << 16),
       j & (255 << 24)
      ]);
  };

  /// WARNING: This only hashes the lowest 32 bits of the `Int`
  public func hashOfText(t : Text) : Hash {
    var x = 0 : Word32;
    for (c in t.chars()) {
      x := x ^ Prim.charToWord32(c);
    };
    return x
  };

  /// Project a given bit from the bit vector.
  public func getHashBit(h : Hash, pos : Nat) : Bool {
    assert (pos <= length);
    (h & (Prim.natToWord32(1) << Prim.natToWord32(pos))) != Prim.natToWord32(0)
  };

  /// Test if two hashes are equal
  public func hashEq(ha : Hash, hb : Hash) : Bool {
    ha == hb
  };

  public func bitsPrintRev(bits : Hash) {
    for (j in Iter.range(0, length - 1)) {
      if (getHashBit(bits, j)) {
        Prim.debugPrint "1"
      } else {
        Prim.debugPrint "0"
      }
    }
  };

  public func hashPrintRev(bits : Hash) {
    for (j in Iter.revRange(length - 1, 0)) {
      if (getHashBit(bits, Prim.abs(j))) {
        Prim.debugPrint "1"
      } else {
        Prim.debugPrint "0"
      }
    }
  };

  /// Jenkin's one at a time:
  ///
  /// https://en.wikipedia.org/wiki/Jenkins_hash_function#one_at_a_time
  ///
  /// The input type should actually be `[Word8]`.
  /// Note: Be sure to explode each `Word8` of a `Word32` into its own `Word32`, and to shift into lower 8 bits.

  // should this really be public?
  public func hashWord8s(key : [Hash]) : Hash {
    var hash = Prim.natToWord32(0);
    for (wordOfKey in key.vals()) {
      hash := hash + wordOfKey;
      hash := hash + hash << 10;
      hash := hash ^ (hash >> 6);
    };
    hash := hash + hash << 3;
    hash := hash ^ (hash >> 11);
    hash := hash + hash << 15;
    return hash;
  };

}
