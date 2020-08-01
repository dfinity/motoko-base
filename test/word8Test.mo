import Debug "mo:base/Debug";
import Word8 "mo:base/Word8";

assert (Word8.fromInt(-128) == (128:Word8));
assert (Word8.fromInt(-256) == (0:Word8));
assert (Word8.fromInt(-1) == (255:Word8));
assert (Word8.toHex(0) == "00");
assert (Word8.toHex(255) == "ff");
