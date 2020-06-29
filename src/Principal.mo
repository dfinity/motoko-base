/// IC principals (User and canister IDs)

import Prim "mo:prim";
import Blob "Blob";
import Hash "Hash";
module {

  /// Conversion.
  public let fromActor : (a : actor {}) -> Principal = Prim.principalOfActor;

  /// Conversion.
  public let toBlob : (p : Principal) -> Blob = Prim.blobOfPrincipal;

  /// Conversion.
  public func toText(p : Principal) : Text = debug_show(p);

  public func hash(principal : Principal) : Hash.Hash =
    Blob.hash (Prim.blobOfPrincipal principal);

  /// Returns `x == y`.
  public func equal(x : Principal, y : Principal) : Bool { x == y };

  /// Returns `x != y`.
  public func notEqual(x : Principal, y : Principal) : Bool { x != y };

  /// Returns `x < y`.
  public func less(x : Principal, y : Principal) : Bool { x < y };

  /// Returns `x <= y`.
  public func lessOrEqual(x : Principal, y : Principal) : Bool { x <= y };

  /// Returns `x > y`.
  public func greater(x : Principal, y : Principal) : Bool { x > y };

  /// Returns `x >= y`.
  public func greaterOrEqual(x : Principal, y : Principal) : Bool { x >= y };

  /// Returns the order of `x` and `y`.
  public func compare(x : Principal, y : Principal) : { #less; #equal; #greater} {
    if (x < y) #less
    else if (x == y) #equal
    else #greater
  };

}
