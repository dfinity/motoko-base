/// IC principals (User and canister IDs)

import Prim "mo:prim";
import Blob "Blob";
module {
  public func hash(principal : Principal) : Word32 =
    Blob.hash (Prim.blobOfPrincipal principal);
  public let fromActor : (actor {}) -> Principal =
    Prim.principalOfActor;  
  public func fromText(t : Text) = fromActor(actor(t))
}
