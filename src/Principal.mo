/// IC principals (User and canister IDs)

import Prim "mo:prim";
import Blob "Blob";
import Hash "Hash";
module {
  public func hash(principal : Principal) : Hash.Hash =
    Blob.hash (Prim.blobOfPrincipal principal);
  public let fromActor : (actor {}) -> Principal =
    Prim.principalOfActor;  
  public func fromText(t : Text) : Principal = fromActor(actor(t))
}
