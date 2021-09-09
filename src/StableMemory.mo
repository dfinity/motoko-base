/// Byte-level access to (virtual) _stable memory_.
///
/// This is a lightweight abstraction over IC _stable memory_ and supports persisting
/// raw binary data across Motoko upgrades.
/// Use of this module is fully compatible with Motoko's use of
/// _stable variables_, whose persistence mechanism also uses (real) IC stable memory internally, but does not interfere with this API.
///
/// Each `load` operation loads from byte address `offset` in little-endian
/// format using the natural bit-width of the type in question.
/// The operation traps if attempting to read beyond the current stable memory size.
///
/// Each `store` operation stores to byte address `offset` in little-endian format using the natural bit-width of the type in question.
/// The operation traps if attempting to write beyond the current stable memory size.
///
/// Text values can be handled by using `Text.decodeUtf8` and `Text.encodeUtf8`, in conjunction with `loadBlob` and `storeBlob`.
///
/// NB: The IC's actual stable memory size (`ic0.stable_size`) may exceed the
/// page size reported by Motoko function `size()`.
/// This is to accommodate Motoko's stable variables.

import Prim "mo:⛔";

module {

  /// Current size of the stable memory, in pages.
  /// Each page is 64KiB (65536 bytes).
  /// Initially `0`.
  public let size : () -> (pages : Nat32) =
    Prim.stableMemorySize;

  /// Grow current `size` of stable memory by `pagecount` pages.
  /// Each page is 16KiB (16384 bytes).
  /// Returns previous `size` when able to grow.
  /// Returns `0xFFFF` if remaining pages insufficient.
  public let grow : (new_pages : Nat32) -> (oldpages : Nat32) =
    Prim.stableMemoryGrow;

  public let loadNat32 : (offset : Nat32) -> Nat32 =
    Prim.stableMemoryLoadNat32;
  public let storeNat32 : (offset : Nat32, value: Nat32) -> () =
    Prim.stableMemoryStoreNat32;

  public let loadNat8 : (offset : Nat32) -> Nat8 =
    Prim.stableMemoryLoadNat8;
  public let storeNat8 : (offset : Nat32, value : Nat8) -> () =
    Prim.stableMemoryStoreNat8;

  public let loadNat16 : (offset : Nat32) -> Nat16 =
    Prim.stableMemoryLoadNat16;
  public let storeNat16 : (offset : Nat32, value : Nat16) -> () =
    Prim.stableMemoryStoreNat16;

  public let loadNat64 : (offset : Nat32) -> Nat64 =
    Prim.stableMemoryLoadNat64;
  public let storeNat64 : (offset : Nat32, value : Nat64) -> () =
    Prim.stableMemoryStoreNat64;

  public let loadInt32 : (offset : Nat32) -> Int32 =
    Prim.stableMemoryLoadInt32;
  public let storeInt32 : (offset : Nat32, value : Int32) -> () =
    Prim.stableMemoryStoreInt32;

  public let loadInt8 : (offset : Nat32) -> Int8 =
    Prim.stableMemoryLoadInt8;
  public let storeInt8 : (offset : Nat32, value : Int8) -> () =
    Prim.stableMemoryStoreInt8;

  public let loadInt16 : (offset : Nat32) -> Int16 =
    Prim.stableMemoryLoadInt16;
  public let storeInt16 : (offset : Nat32, value : Int16) -> () =
    Prim.stableMemoryStoreInt16;

  public let loadInt64 : (offset : Nat32) -> Int64 =
    Prim.stableMemoryLoadInt64;
  public let storeInt64 : (offset : Nat32, value : Int64) -> () =
    Prim.stableMemoryStoreInt64;

  public let loadFloat : (offset : Nat32) -> Float =
    Prim.stableMemoryLoadFloat;
  public let storeFloat : (offset : Nat32, value : Float) -> () =
    Prim.stableMemoryStoreFloat;

  /// Load `size` bytes starting from `offset` as a `Blob`.
  /// Traps on out-of-bounds access.
  public let loadBlob : (offset : Nat32, size : Nat) -> Blob =
    Prim.stableMemoryLoadBlob;

  /// Write bytes of `blob` beginning at `offset`.
  /// Traps on out-of-bounds access.
  public let storeBlob : (offset : Nat32, value : Blob) -> () =
    Prim.stableMemoryStoreBlob;

}
