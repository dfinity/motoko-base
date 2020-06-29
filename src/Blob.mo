/// Binary blobs

import Prim "mo:prim";
module {

  public let hash : Blob -> Word32 = Prim.hashBlob;

  /// Returns `x == y`.
  public func equal(x : Blob, y : Blob) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Blob, y : Blob) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Blob, y : Blob) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Blob, y : Blob) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Blob, y : Blob) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Blob, y : Blob) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Blob, y : Blob) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

}
