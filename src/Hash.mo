/// Hash values

import Prim "mo:prim";
import Iter "Iter";
import HT "HashType";

module {
  /// Hash values represent a string of _hash bits_, packed into a `Word32`.
  public type Hash = HT.Hash;

  /// Project a given bit from the bit vector.
  public func bit(h : Hash, pos : Nat) : Bool {
    assert (pos <= HT.length);
    (h & (Prim.natToWord32(1) << Prim.natToWord32(pos))) != Prim.natToWord32(0)
  };

  /// Test if two hashes are equal
  public func equal(ha : Hash, hb : Hash) : Bool {
    ha == hb
  };

  public func debugPrintBits(bits : Hash) {
    for (j in Iter.range(0, HT.length - 1)) {
      if (bit(bits, j)) {
        Prim.debugPrint "1"
      } else {
        Prim.debugPrint "0"
      }
    }
  };

  public func debugPrintBitsRev(bits : Hash) {
    for (j in Iter.revRange(HT.length - 1, 0)) {
      if (bit(bits, Prim.abs(j))) {
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
  public func hashWord8(key : [Hash]) : Hash {
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
