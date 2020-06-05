/// IC principals (User and canister IDs)

import Prim "mo:prim";
import Blob "Blob";
module {
  public func hash(principal : Principal) =
    Blob.hash (Prim.blobOfPrincipal principal);
}
