import Debug "mo:base/Debug";
import Word64 "mo:base/Word64";

assert (Word64.toHex(0) == "0000000000000000");
assert (Word64.toHex(2**64-1) == "ffffffffffffffff");
