/// Byte-level access to (virtual) _stable memory_.
/// 
/// :::warning [Experimental module]
/// 
/// As the name suggests, this library is experimental, subject to change, and may be replaced by safer alternatives in later versions of Motoko.
/// Use at your own risk and discretion.
/// :::
/// 
/// :::warning [Deprecation notice]
/// 
/// Use of `ExperimentalStableMemory` may be deprecated in the future.
/// Consider using `Region.mo` for isolated memory regions.
/// Isolated regions ensure that writing to one region does not affect unrelated state elsewhere.
/// :::
/// 
/// This is a lightweight abstraction over IC _stable memory_ and supports persisting raw binary data across Motoko upgrades.
/// It is fully compatible with Motoko's _stable variables_, which also use IC stable memory internally, but do not interfere with this API.
/// 
/// Memory is allocated using `grow(pages)`, sequentially and on demand, in units of 64KiB pages, starting with 0 allocated pages.
/// New pages are zero-initialised.
/// Growth is capped by a soft page limit set with the compile-time flag `--max-stable-pages <n>` (default: 65536, or 4GiB).
/// 
/// Each `load` reads from byte address `offset` in little-endian format using the natural bit-width of the type.
/// Traps if reading beyond the allocated size.
/// 
/// Each `store` writes to byte address `offset` in little-endian format using the natural bit-width of the type.
/// Traps if writing beyond the allocated size.
/// 
/// Text can be handled using `Text.decodeUtf8` and `Text.encodeUtf8` in combination with `loadBlob` and `storeBlob`.
/// 
/// The current page allocation and contents are preserved across upgrades.
/// 
/// :::note [IC stable memory discrepancy]
/// 
/// The IC’s reported stable memory size (`ic0.stable_size`) may exceed what Motoko’s `size()` returns.
/// This and the growth cap exist to protect Motoko’s internal use of stable variables.
/// If you're not using stable variables (or using them sparingly), you may increase `--max-stable-pages` toward the IC maximum (currently 64GiB).
/// Even if not using stable variables, always reserve at least one page.
/// :::
/// 
/// Usage:
/// 
/// ```motoko no-repl
/// import StableMemory "mo:base/ExperimentalStableMemory";
/// ```

import Prim "mo:⛔";

module {

  ///  Current size of the stable memory, in pages.
  ///  Each page is 64KiB (65536 bytes).
  ///  Initially `0`.
  ///  Preserved across upgrades, together with contents of allocated
  ///  stable memory.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let beforeSize = StableMemory.size();
  ///  ignore StableMemory.grow(10);
  ///  let afterSize = StableMemory.size();
  ///  afterSize - beforeSize // => 10
  ///  ```
  public let size : () -> (pages : Nat64) = Prim.stableMemorySize;

  ///  Grow current `size` of stable memory by the given number of pages.
  ///  Each page is 64KiB (65536 bytes).
  ///  Returns the previous `size` when able to grow.
  ///  Returns `0xFFFF_FFFF_FFFF_FFFF` if remaining pages insufficient.
  ///  Every new page is zero-initialized, containing byte 0x00 at every offset.
  ///  Function `grow` is capped by a soft limit on `size` controlled by compile-time flag
  ///   `--max-stable-pages <n>` (the default is 65536, or 4GiB).
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  import Error "mo:base/Error";
  /// 
  ///  let beforeSize = StableMemory.grow(10);
  ///  if (beforeSize == 0xFFFF_FFFF_FFFF_FFFF) {
  ///    throw Error.reject("Out of memory");
  ///  };
  ///  let afterSize = StableMemory.size();
  ///  afterSize - beforeSize // => 10
  ///  ```
  public let grow : (newPages : Nat64) -> (oldPages : Nat64) = Prim.stableMemoryGrow;

  ///  Returns a query that, when called, returns the number of bytes of (real) IC stable memory that would be
  ///  occupied by persisting its current stable variables before an upgrade.
  ///  This function may be used to monitor or limit real stable memory usage.
  ///  The query computes the estimate by running the first half of an upgrade, including any `preupgrade` system method.
  ///  Like any other query, its state changes are discarded so no actual upgrade (or other state change) takes place.
  ///  The query can only be called by the enclosing actor and will trap for other callers.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  actor {
  ///    stable var state = "";
  ///    public func example() : async Text {
  ///      let memoryUsage = StableMemory.stableVarQuery();
  ///      let beforeSize = (await memoryUsage()).size;
  ///      state #= "abcdefghijklmnopqrstuvwxyz";
  ///      let afterSize = (await memoryUsage()).size;
  ///      debug_show (afterSize - beforeSize)
  ///    };
  ///  };
  ///  ```
  public let stableVarQuery : () -> (shared query () -> async { size : Nat64 }) = Prim.stableVarQuery;

  ///  Loads a `Nat32` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat32(offset, value);
  ///  StableMemory.loadNat32(offset) // => 123
  ///  ```
  public let loadNat32 : (offset : Nat64) -> Nat32 = Prim.stableMemoryLoadNat32;

  ///  Stores a `Nat32` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat32(offset, value);
  ///  StableMemory.loadNat32(offset) // => 123
  ///  ```
  public let storeNat32 : (offset : Nat64, value : Nat32) -> () = Prim.stableMemoryStoreNat32;

  ///  Loads a `Nat8` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat8(offset, value);
  ///  StableMemory.loadNat8(offset) // => 123
  ///  ```
  public let loadNat8 : (offset : Nat64) -> Nat8 = Prim.stableMemoryLoadNat8;

  ///  Stores a `Nat8` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat8(offset, value);
  ///  StableMemory.loadNat8(offset) // => 123
  ///  ```
  public let storeNat8 : (offset : Nat64, value : Nat8) -> () = Prim.stableMemoryStoreNat8;

  ///  Loads a `Nat16` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat16(offset, value);
  ///  StableMemory.loadNat16(offset) // => 123
  ///  ```
  public let loadNat16 : (offset : Nat64) -> Nat16 = Prim.stableMemoryLoadNat16;

  ///  Stores a `Nat16` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat16(offset, value);
  ///  StableMemory.loadNat16(offset) // => 123
  ///  ```
  public let storeNat16 : (offset : Nat64, value : Nat16) -> () = Prim.stableMemoryStoreNat16;

  ///  Loads a `Nat64` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat64(offset, value);
  ///  StableMemory.loadNat64(offset) // => 123
  ///  ```
  public let loadNat64 : (offset : Nat64) -> Nat64 = Prim.stableMemoryLoadNat64;

  ///  Stores a `Nat64` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeNat64(offset, value);
  ///  StableMemory.loadNat64(offset) // => 123
  ///  ```
  public let storeNat64 : (offset : Nat64, value : Nat64) -> () = Prim.stableMemoryStoreNat64;

  ///  Loads an `Int32` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt32(offset, value);
  ///  StableMemory.loadInt32(offset) // => 123
  ///  ```
  public let loadInt32 : (offset : Nat64) -> Int32 = Prim.stableMemoryLoadInt32;

  ///  Stores an `Int32` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt32(offset, value);
  ///  StableMemory.loadInt32(offset) // => 123
  ///  ```
  public let storeInt32 : (offset : Nat64, value : Int32) -> () = Prim.stableMemoryStoreInt32;

  ///  Loads an `Int8` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt8(offset, value);
  ///  StableMemory.loadInt8(offset) // => 123
  ///  ```
  public let loadInt8 : (offset : Nat64) -> Int8 = Prim.stableMemoryLoadInt8;

  ///  Stores an `Int8` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt8(offset, value);
  ///  StableMemory.loadInt8(offset) // => 123
  ///  ```
  public let storeInt8 : (offset : Nat64, value : Int8) -> () = Prim.stableMemoryStoreInt8;

  ///  Loads an `Int16` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt16(offset, value);
  ///  StableMemory.loadInt16(offset) // => 123
  ///  ```
  public let loadInt16 : (offset : Nat64) -> Int16 = Prim.stableMemoryLoadInt16;

  ///  Stores an `Int16` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt16(offset, value);
  ///  StableMemory.loadInt16(offset) // => 123
  ///  ```
  public let storeInt16 : (offset : Nat64, value : Int16) -> () = Prim.stableMemoryStoreInt16;

  ///  Loads an `Int64` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt64(offset, value);
  ///  StableMemory.loadInt64(offset) // => 123
  ///  ```
  public let loadInt64 : (offset : Nat64) -> Int64 = Prim.stableMemoryLoadInt64;

  ///  Stores an `Int64` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 123;
  ///  StableMemory.storeInt64(offset, value);
  ///  StableMemory.loadInt64(offset) // => 123
  ///  ```
  public let storeInt64 : (offset : Nat64, value : Int64) -> () = Prim.stableMemoryStoreInt64;

  ///  Loads a `Float` value from stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 1.25;
  ///  StableMemory.storeFloat(offset, value);
  ///  StableMemory.loadFloat(offset) // => 1.25
  ///  ```
  public let loadFloat : (offset : Nat64) -> Float = Prim.stableMemoryLoadFloat;

  ///  Stores a `Float` value in stable memory at the given `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  let offset = 0;
  ///  let value = 1.25;
  ///  StableMemory.storeFloat(offset, value);
  ///  StableMemory.loadFloat(offset) // => 1.25
  ///  ```
  public let storeFloat : (offset : Nat64, value : Float) -> () = Prim.stableMemoryStoreFloat;

  ///  Load `size` bytes starting from `offset` as a `Blob`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  import Blob "mo:base/Blob";
  /// 
  ///  let offset = 0;
  ///  let value = Blob.fromArray([1, 2, 3]);
  ///  let size = value.size();
  ///  StableMemory.storeBlob(offset, value);
  ///  Blob.toArray(StableMemory.loadBlob(offset, size)) // => [1, 2, 3]
  ///  ```
  public let loadBlob : (offset : Nat64, size : Nat) -> Blob = Prim.stableMemoryLoadBlob;

  ///  Write bytes of `blob` beginning at `offset`.
  ///  Traps on an out-of-bounds access.
  /// 
  ///  Example:
  ///  ```motoko no-repl
  ///  import Blob "mo:base/Blob";
  /// 
  ///  let offset = 0;
  ///  let value = Blob.fromArray([1, 2, 3]);
  ///  let size = value.size();
  ///  StableMemory.storeBlob(offset, value);
  ///  Blob.toArray(StableMemory.loadBlob(offset, size)) // => [1, 2, 3]
  ///  ```
  public let storeBlob : (offset : Nat64, value : Blob) -> () = Prim.stableMemoryStoreBlob;

}
