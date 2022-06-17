/// Byte-level access to (virtual) _stable memory_.
///
/// **WARNING**: As its name suggests, this library is **experimental**, subject to change
/// and may be replaced by safer alternatives in later versions of Motoko.
/// Use at your own risk and discretion.
///
/// This is a lightweight abstraction over IC _stable memory_ and supports persisting
/// raw binary data across Motoko upgrades.
/// Use of this module is fully compatible with Motoko's use of
/// _stable variables_, whose persistence mechanism also uses (real) IC stable memory internally, but does not interfere with this API.
///
/// Memory is allocated, using `grow(pages)`, sequentially and on demand, in units of 64KiB pages, starting with 0 allocated pages.
/// New pages are zero initialized.
/// Growth is capped by a soft limit on page count controlled by compile-time flag
/// `--max-stable-pages <n>` (the default is 65536, or 4GiB).
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
/// The current page allocation and page contents is preserved across upgrades.
///
/// NB: The IC's actual stable memory size (`ic0.stable_size`) may exceed the
/// page size reported by Motoko function `size()`.
/// This (and the cap on growth) are to accommodate Motoko's stable variables.
/// Applications that plan to use Motoko stable variables sparingly or not at all can
/// increase `--max-stable-pages` as desired, approaching the IC maximum (currently 8GiB).
/// All applications should reserve at least one page for stable variable data, even when no stable variables are used.

import Prim "mo:⛔";

module {

  /// Current size of the stable memory, in pages.
  /// Each page is 64KiB (65536 bytes).
  /// Initially `0`.
  /// Preserved across upgrades, together with contents of allocated
  /// stable memory.
  public let size : () -> (pages : Nat64) =
    Prim.stableMemorySize;

  /// Grow current `size` of stable memory by `pagecount` pages.
  /// Each page is 64KiB (65536 bytes).
  /// Returns previous `size` when able to grow.
  /// Returns `0xFFFF_FFFF_FFFF_FFFF` if remaining pages insufficient.
  /// Every new page is zero-initialized, containing byte 0 at every offset.
  /// Function `grow` is capped by a soft limit on `size` controlled by compile-time flag
  ///  `--max-stable-pages <n>` (the default is 65536, or 4GiB).
  public let grow : (new_pages : Nat64) -> (oldpages : Nat64) =
    Prim.stableMemoryGrow;

  /// Returns a query that, when called, returns the number of bytes of (real) IC stable memory that would be
  /// occupied by persisting its current stable variables before an upgrade.
  /// This function may be used to monitor or limit real stable memory usage.
  /// The query computes the estimate by running the first half of an upgrade, including any `preupgrade` system method.
  /// Like any other query, its state changes are discarded so no actual upgrade (or other state change) takes place.
  /// The query can only be called by the enclosing actor and will trap for other callers.
  public let stableVarQuery : () -> (shared query () -> async {size : Nat64}) =
    Prim.stableVarQuery;

  public let loadNat32 : (offset : Nat64) -> Nat32 =
    Prim.stableMemoryLoadNat32;
  public let storeNat32 : (offset : Nat64, value: Nat32) -> () =
    Prim.stableMemoryStoreNat32;

  public let loadNat8 : (offset : Nat64) -> Nat8 =
    Prim.stableMemoryLoadNat8;
  public let storeNat8 : (offset : Nat64, value : Nat8) -> () =
    Prim.stableMemoryStoreNat8;

  public let loadNat16 : (offset : Nat64) -> Nat16 =
    Prim.stableMemoryLoadNat16;
  public let storeNat16 : (offset : Nat64, value : Nat16) -> () =
    Prim.stableMemoryStoreNat16;

  public let loadNat64 : (offset : Nat64) -> Nat64 =
    Prim.stableMemoryLoadNat64;
  public let storeNat64 : (offset : Nat64, value : Nat64) -> () =
    Prim.stableMemoryStoreNat64;

  public let loadInt32 : (offset : Nat64) -> Int32 =
    Prim.stableMemoryLoadInt32;
  public let storeInt32 : (offset : Nat64, value : Int32) -> () =
    Prim.stableMemoryStoreInt32;

  public let loadInt8 : (offset : Nat64) -> Int8 =
    Prim.stableMemoryLoadInt8;
  public let storeInt8 : (offset : Nat64, value : Int8) -> () =
    Prim.stableMemoryStoreInt8;

  public let loadInt16 : (offset : Nat64) -> Int16 =
    Prim.stableMemoryLoadInt16;
  public let storeInt16 : (offset : Nat64, value : Int16) -> () =
    Prim.stableMemoryStoreInt16;

  public let loadInt64 : (offset : Nat64) -> Int64 =
    Prim.stableMemoryLoadInt64;
  public let storeInt64 : (offset : Nat64, value : Int64) -> () =
    Prim.stableMemoryStoreInt64;

  public let loadFloat : (offset : Nat64) -> Float =
    Prim.stableMemoryLoadFloat;
  public let storeFloat : (offset : Nat64, value : Float) -> () =
    Prim.stableMemoryStoreFloat;

  /// Load `size` bytes starting from `offset` as a `Blob`.
  /// Traps on out-of-bounds access.
  public let loadBlob : (offset : Nat64, size : Nat) -> Blob =
    Prim.stableMemoryLoadBlob;

  /// Write bytes of `blob` beginning at `offset`.
  /// Traps on out-of-bounds access.
  public let storeBlob : (offset : Nat64, value : Blob) -> () =
    Prim.stableMemoryStoreBlob;

}
