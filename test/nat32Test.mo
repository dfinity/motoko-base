import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";

Debug.print("Nat32");

do {
  Debug.print("  toBytes");

  assert(Nat32.toBytes((4_123_435_857:Nat32)) == [(245:Nat8), (198:Nat8), (163:Nat8), (81:Nat8)]);
};

do {
  Debug.print("  fromBytes");

  assert(Nat32.fromBytes([(245:Nat8), (198:Nat8), (163:Nat8), (81:Nat8)]) == (4_123_435_857:Nat32))
};
