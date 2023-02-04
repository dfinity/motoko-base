/// Byte-level access to multiple, independent stable memory _regions_.
///
/// This is a lightweight abstraction over IC _stable memory_ and supports persisting
/// raw binary data across Motoko upgrades.
/// Use of this module is fully compatible with Motoko's use of
/// _stable variables_, whose persistence mechanism also uses (real) IC stable memory internally, but does not interfere with this API.
///
/// ## Multple regions
///
/// This module provides a generalization over its predecessor (`ExperimentalStableMemory`),
/// in that it offers a new _region_ primitive type (`Region`),
/// and the ability to have _multiple, dynamically-created instances_, rather than a
/// module with a single
/// _monolitic_ (_shared, global_) instance, as before.
///
/// The API for the memory instance primitive provides
/// the same low-level API as before, but where each instance
/// can be used independently of the others.
///
/// Reclaiming space from one to use in another is
/// unlocked by this new generalized API, but is not yet implemented.
/// By creating a more sophisticated backing allocator, future implementations
/// (more complex than the present one lifted from the Rust library)
/// could support freeing memories transparently via the existing GC infrastructure,
/// avoid growing the underlying canister stable memory when a new instance is required,
/// or when an existing instance must grow.
///
/// ## Per-instance API
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
/// increase `--max-stable-pages` as desired, approaching the IC maximum (initially 8GiB, then 32Gib, currently 48Gib).
/// All applications should reserve at least one page for stable variable data, even when no stable variables are used.
///
/// Usage:
/// ```motoko no-repl
/// import Region "mo:base/Region";
/// let r = Region.new();
/// ```

import Prim "mo:⛔";

module {



  /// Current size of the stable memory, in pages.
  /// Each page is 64KiB (65536 bytes).
  /// Initially `0`.
  /// Preserved across upgrades, together with contents of allocated
  /// stable memory.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let beforeSize = Region.size(r);
  /// ignore Region.grow(r, 10);
  /// let afterSize = Region.size(r);
  /// afterSize - beforeSize // => 10
  /// ```
  public let new : () -> Region = Prim.regionNew;

  /// Current size of the stable memory, in pages.
  /// Each page is 64KiB (65536 bytes).
  /// Initially `0`.
  /// Preserved across upgrades, together with contents of allocated
  /// stable memory.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let beforeSize = Region.size(r);
  /// ignore Region.grow(10);
  /// let afterSize = Region.size(r);
  /// afterSize - beforeSize // => 10
  /// ```
  public let size : (r : Region) -> (pages : Nat64) = Prim.regionSize;

  /// Grow current `size` of stable memory by the given number of pages.
  /// Each page is 64KiB (65536 bytes).
  /// Returns the previous `size` when able to grow.
  /// Returns `0xFFFF_FFFF_FFFF_FFFF` if remaining pages insufficient.
  /// Every new page is zero-initialized, containing byte 0x00 at every offset.
  /// Function `grow` is capped by a soft limit on `size` controlled by compile-time flag
  ///  `--max-stable-pages <n>` (the default is 65536, or 4GiB).
  ///
  /// Example:
  /// ```motoko no-repl
  /// import Error "mo:base/Error";
  ///
  /// let beforeSize = Region.grow(r, 10);
  /// if (beforeSize == 0xFFFF_FFFF_FFFF_FFFF) {
  ///   throw Error.reject("Out of memory");
  /// };
  /// let afterSize = Region.size(r);
  /// afterSize - beforeSize // => 10
  /// ```
  public let grow : (r : Region, newPages : Nat64) -> (oldPages : Nat64) = Prim.regionGrow;

  /// Returns a query that, when called, returns the number of bytes of (real) IC stable memory that would be
  /// occupied by persisting its current stable variables before an upgrade.
  /// This function may be used to monitor or limit real stable memory usage.
  /// The query computes the estimate by running the first half of an upgrade, including any `preupgrade` system method.
  /// Like any other query, its state changes are discarded so no actual upgrade (or other state change) takes place.
  /// The query can only be called by the enclosing actor and will trap for other callers.
  ///
  /// Example:
  /// ```motoko no-repl
  /// actor {
  ///   stable var state = "";
  ///   public func example() : async Text {
  ///     let memoryUsage = Region.stableVarQuery();
  ///     let beforeSize = (await memoryUsage()).size;
  ///     state #= "abcdefghijklmnopqrstuvwxyz";
  ///     let afterSize = (await memoryUsage()).size;
  ///     debug_show (afterSize - beforeSize)
  ///   };
  /// };
  /// ```
  public let stableVarQuery : () -> (shared query () -> async { size : Nat64 }) = Prim.stableVarQuery;

  /// Loads a `Nat32` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat32(r, offset, value);
  /// Region.loadNat32(r, offset) // => 123
  /// ```
  public let loadNat32 : (r : Region, offset : Nat64) -> Nat32 = Prim.regionLoadNat32;

  /// Stores a `Nat32` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat32(r, offset, value);
  /// Region.loadNat32(r, offset) // => 123
  /// ```
  public let storeNat32 : (r : Region, offset : Nat64, value : Nat32) -> () = Prim.regionStoreNat32;

  /// Loads a `Nat8` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat8(r, offset, value);
  /// Region.loadNat8(r, offset) // => 123
  /// ```
  public let loadNat8 : (r : Region, offset : Nat64) -> Nat8 = Prim.regionLoadNat8;

  /// Stores a `Nat8` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat8(r, offset, value);
  /// Region.loadNat8(r, offset) // => 123
  /// ```
  public let storeNat8 : (r : Region, offset : Nat64, value : Nat8) -> () = Prim.regionStoreNat8;

  /// Loads a `Nat16` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat16(r, offset, value);
  /// Region.loadNat16(r, offset) // => 123
  /// ```
  public let loadNat16 : (r : Region, offset : Nat64) -> Nat16 = Prim.regionLoadNat16;

  /// Stores a `Nat16` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat16(r, offset, value);
  /// Region.loadNat16(r, offset) // => 123
  /// ```
  public let storeNat16 : (r : Region, offset : Nat64, value : Nat16) -> () = Prim.regionStoreNat16;

  /// Loads a `Nat64` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat64(r, offset, value);
  /// Region.loadNat64(r, offset) // => 123
  /// ```
  public let loadNat64 : (r : Region, offset : Nat64) -> Nat64 = Prim.regionLoadNat64;

  /// Stores a `Nat64` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeNat64(r, offset, value);
  /// Region.loadNat64(r, offset) // => 123
  /// ```
  public let storeNat64 : (r : Region, offset : Nat64, value : Nat64) -> () = Prim.regionStoreNat64;

  /// Loads an `Int32` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt32(r, offset, value);
  /// Region.loadInt32(r, offset) // => 123
  /// ```
  public let loadInt32 : (r : Region, offset : Nat64) -> Int32 = Prim.regionLoadInt32;

  /// Stores an `Int32` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt32(r, offset, value);
  /// Region.loadInt32(r, offset) // => 123
  /// ```
  public let storeInt32 : (r : Region, offset : Nat64, value : Int32) -> () = Prim.regionStoreInt32;

  /// Loads an `Int8` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt8(r, offset, value);
  /// Region.loadInt8(r, offset) // => 123
  /// ```
  public let loadInt8 : (r : Region, offset : Nat64) -> Int8 = Prim.regionLoadInt8;

  /// Stores an `Int8` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt8(r, offset, value);
  /// Region.loadInt8(r, offset) // => 123
  /// ```
  public let storeInt8 : (r : Region, offset : Nat64, value : Int8) -> () = Prim.regionStoreInt8;

  /// Loads an `Int16` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt16(r, offset, value);
  /// Region.loadInt16(r, offset) // => 123
  /// ```
  public let loadInt16 : (r : Region, offset : Nat64) -> Int16 = Prim.regionLoadInt16;

  /// Stores an `Int16` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt16(r, offset, value);
  /// Region.loadInt16(r, offset) // => 123
  /// ```
  public let storeInt16 : (r : Region, offset : Nat64, value : Int16) -> () = Prim.regionStoreInt16;

  /// Loads an `Int64` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt64(r, offset, value);
  /// Region.loadInt64(r, offset) // => 123
  /// ```
  public let loadInt64 : (r : Region, offset : Nat64) -> Int64 = Prim.regionLoadInt64;

  /// Stores an `Int64` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 123;
  /// Region.storeInt64(r, offset, value);
  /// Region.loadInt64(r, offset) // => 123
  /// ```
  public let storeInt64 : (r : Region, offset : Nat64, value : Int64) -> () = Prim.regionStoreInt64;

  /// Loads a `Float` value from stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 1.25;
  /// Region.storeFloat(r, offset, value);
  /// Region.loadFloat(r, offset) // => 1.25
  /// ```
  public let loadFloat : (r : Region, offset : Nat64) -> Float = Prim.regionLoadFloat;

  /// Stores a `Float` value in stable memory at the given `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// let offset = 0;
  /// let value = 1.25;
  /// Region.storeFloat(r, offset, value);
  /// Region.loadFloat(r, offset) // => 1.25
  /// ```
  public let storeFloat : (r : Region, offset : Nat64, value : Float) -> () = Prim.regionStoreFloat;

  /// Load `size` bytes starting from `offset` as a `Blob`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// import Blob "mo:base/Blob";
  ///
  /// let offset = 0;
  /// let value = Blob.fromArray([1, 2, 3]);
  /// let size = value.size();
  /// Region.storeBlob(r, offset, value);
  /// Blob.toArray(Region.loadBlob(r, offset, size)) // => [1, 2, 3]
  /// ```
  public let loadBlob : (r : Region, offset : Nat64, size : Nat) -> Blob = Prim.regionLoadBlob;

  /// Write bytes of `blob` beginning at `offset`.
  /// Traps on an out-of-bounds access.
  ///
  /// Example:
  /// ```motoko no-repl
  /// import Blob "mo:base/Blob";
  ///
  /// let offset = 0;
  /// let value = Blob.fromArray([1, 2, 3]);
  /// let size = value.size();
  /// Region.storeBlob(r, offset, value);
  /// Blob.toArray(Region.loadBlob(r, offset, size)) // => [1, 2, 3]
  /// ```
  public let storeBlob : (r : Region, offset : Nat64, value : Blob) -> () = Prim.regionStoreBlob;

}
