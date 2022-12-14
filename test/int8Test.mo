import Debug "mo:base/Debug";
import Int8 "mo:base/Int8";

assert (Int8.fromIntWrap(256) == (0 : Int8));
assert (Int8.fromIntWrap(-256) == (0 : Int8));
assert (Int8.fromIntWrap(128) == (-128 : Int8));
assert (Int8.fromIntWrap(255) == (-1 : Int8))
