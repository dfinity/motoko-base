/// Byte-level access to (virtual) Stable Memory

/// This is a virtual abstraction over IC StableMemory and supports persisting
/// raw binary data across Motoko upgrades.
/// Use of this module does _not_ interfere with Motoko's use of
/// stable variables whose peristence also uses (real) IC stable memory.

/// Each load operation loads from byte address `offset` in little-endian format using the natural bit-width of the type in question. The operation traps if reading beyond the current virtual memory size.
/// Each store operation stored to byte address `offset` in little-endian format. A store operation traps if attempting to store beyond the current virtual memory size.

/// Text values can be handled by using `Text.decodeUtf8` and `Text.encodeUtf8`, in conjunction with `loadBlob` and `storeBlob`.

/// NB: The IC's actual stable memory size (`ic0.stable_size`) may exceed the
/// page size reported by Motoko function `size()`.
/// This is to  accommodate Motoko's stable variables.

import Prim "mo:⛔";

module {

  /// Current size of IC stable memory, in pages.
  /// Each page is 16KiB (16384 bytes).
  public let size : () -> (pages : Nat32) =
    Prim.stableMemorySize;

  /// Grow current size of stable memory by `pagecount` pages.
  /// Each page is 16KiB (16384 bytes).
  /// Returns previous `size` when able to grow.
  /// Returns -1 if remaining pages insufficient.
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

  public let loadFloat : (offset : Nat32) -> Float =
    Prim.stableMemoryLoadFloat;
  public let storeFloat : (offset : Nat32, value : Float) -> () =
    Prim.stableMemoryStoreFloat;

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

  /// Load size bytes starting from `offset` into fresh `blob`.
  /// Traps on out-of-bounds access.
  public let loadBlob : (offset : Nat32, size : Nat) -> (blob : Blob) =
    Prim.stableMemoryLoadBlob;

  /// Write bytes of `blob` beginning at `offset`.
  /// Traps on out-of-bounds access.
  public let storeBlob : (offset : Nat32, value : Blob) -> () =
    Prim.stableMemoryStoreBlob;

}
