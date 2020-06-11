/// Binary blobs

import Prim "mo:prim";
module {
  public let hash : Blob -> Word32 = Prim.hashBlob;
}
