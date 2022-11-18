//! A module for simulating multiple memories within a single memory.
//!
//! The typical way for a canister to have multiple stable structures is by dividing the memory into
//! distinct ranges, dedicating each range to a stable structure. This approach has two problems:
//!
//! 1. The developer needs to put in advance an upper bound on the memory of each stable structure.
//! 2. It wastes the canister's memory allocation. For example, if a canister create twos two stable
//! structures A and B, and gives each one of them a 1GiB region of memory, then writing to B will
//! require growing > 1GiB of memory just to be able to write to it.
//!
//! The [`MemoryManager`] in this module solves both of these problems. It simulates having
//! multiple memories, each being able to grow without bound. That way, a developer doesn't need to
//! put an upper bound to how much stable structures can grow, and the canister's memory allocation
//! becomes less wasteful.
//!
//! Example Usage:
//!
//! ```
//! use ic_stable_structures::{DefaultMemoryImpl, Memory};
//! use ic_stable_structures::memory_manager::{MemoryManager, MemoryId};
//!
//! let mem_mgr = MemoryManager::init(DefaultMemoryImpl::default());
//!
//! // Create different memories, each with a unique ID.
//! let memory_0 = mem_mgr.get(MemoryId::new(0));
//! let memory_1 = mem_mgr.get(MemoryId::new(1));
//!
//! // Each memory can be used independently.
//! memory_0.grow(1);
//! memory_0.write(0, &[1, 2, 3]);
//!
//! memory_1.grow(1);
//! memory_1.write(0, &[4, 5, 6]);
//!
//! var bytes = vec![0; 3];
//! memory_0.read(0, &mut bytes);
//! assert_eq!(bytes, vec![1, 2, 3]);
//!
//! var bytes = vec![0; 3];
//! memory_1.read(0, &mut bytes);
//! assert_eq!(bytes, vec![4, 5, 6]);
//! ```

import Constants "constants";
import Conversion "conversion";
import Types "types";
import Memory "memory";

import RBTree "mo:base/RBTree";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Iter "mo:base/Iter";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";

module {

  // For convenience: from types module
  type Address = Types.Address;
  type Memory = Types.Memory;
  type Bytes = Types.Bytes;
  // For convenience: from base module
  type RBTree<X, Y> = RBTree.RBTree<X, Y>;
  type Buffer<T> = Buffer.Buffer<T>;

  let MAGIC = "MGR";
  let LAYOUT_VERSION: Nat8 = 1;

  // The maximum number of memories that can be created.
  public let MAX_NUM_MEMORIES: Nat8 = 255;

  // The maximum number of buckets the memory manager can handle.
  // With a bucket size of 1024 pages this can support up to 2TiB of memory.
  public let MAX_NUM_BUCKETS: Nat64 = 32768;

  public let BUCKET_SIZE_IN_PAGES: Nat64 = 1024;

  // A value used internally to indicate that a bucket is unallocated.
  public let UNALLOCATED_BUCKET_MARKER: Nat8 = MAX_NUM_MEMORIES;

  // The offset where buckets are in memory.
  let BUCKETS_OFFSET_IN_PAGES: Nat64 = 1;

  // Reserved bytes in the header for future extensions.
  let HEADER_RESERVED_BYTES: Nat = 32;

  /// A memory manager simulates multiple memories within a single memory.
  ///
  /// The memory manager can return up to 255 unique instances of [`VirtualMemory`], and each can be
  /// used independently and can grow up to the bounds of the underlying memory.
  ///
  /// The memory manager divides the memory into "buckets" of 1024 pages. Each [`VirtualMemory`] is
  /// internally represented as a list of buckets. Buckets of different memories can be interleaved,
  /// but the [`VirtualMemory`] interface gives the illusion of a continuous address space.
  ///
  /// Because a [`VirtualMemory`] is a list of buckets, this implies that internally it grows one
  /// bucket at time (1024 pages). This implication makes the memory manager ideal for a small number
  /// of memories storing large amounts of data, as opposed to a large number of memories storing
  /// small amounts of data.
  ///
  /// The first page of the memory is reserved for the memory manager's own state. The layout for
  /// this state is as follows:
  ///
  /// # V1 layout
  ///
  /// ```text
  /// -------------------------------------------------- <- Address 0
  /// Magic "MGR"               ↕ 3 bytes
  /// --------------------------------------------------
  /// Layout version            ↕ 1 byte
  /// --------------------------------------------------
  /// Number of allocated buckets       ↕ 2 bytes
  /// --------------------------------------------------
  /// Max number of buckets = N       ↕ 2 bytes
  /// --------------------------------------------------
  /// Reserved space            ↕ 32 bytes
  /// --------------------------------------------------
  /// Size of memory 0 (in pages)       ↕ 8 bytes
  /// --------------------------------------------------
  /// Size of memory 1 (in pages)       ↕ 8 bytes
  /// --------------------------------------------------
  /// ...
  /// --------------------------------------------------
  /// Size of memory 254 (in pages)     ↕ 8 bytes
  /// -------------------------------------------------- <- Bucket allocations
  /// Bucket 1                ↕ 1 byte    (1 byte indicating which memory owns it)
  /// --------------------------------------------------
  /// Bucket 2                ↕ 1 byte
  /// --------------------------------------------------
  /// ...
  /// --------------------------------------------------
  /// Bucket `MAX_NUM_BUCKETS`        ↕ 1 byte
  /// --------------------------------------------------
  /// Unallocated space
  /// -------------------------------------------------- <- Buckets (Page 1)
  /// Bucket 1                ↕ 1024 pages
  /// -------------------------------------------------- <- Page 1025
  /// Bucket 2                ↕ 1024 pages
  /// --------------------------------------------------
  /// ...
  /// -------------------------------------------------- <- Page ((N - 1) * 1024 + 1)
  /// Bucket N                ↕ 1024 pages
  /// ```

  /// Initializes a `MemoryManager` with the given memory.
  public func init(memory: Memory) : MemoryManager {
    initWithBuckets(memory, Nat16.fromNat(Nat64.toNat(BUCKET_SIZE_IN_PAGES)));
  };

  public func initWithBuckets(memory: Memory, bucket_size_in_pages: Nat16) : MemoryManager {
    MemoryManager(initInner(memory, bucket_size_in_pages));
  };

  public class MemoryManager(inner : MemoryManagerInner) {
    
    public let inner_ : MemoryManagerInner = inner;

    /// Returns the memory associated with the given ID.
    public func get(id: MemoryId) : VirtualMemory {
      VirtualMemory(id, inner_);
    };

  };

  type Header = {
    magic: [Nat8]; // 3 bytes
    version: Nat8;
    // The number of buckets allocated by the memory manager.
    num_allocated_buckets: Nat16;
    // The size of a bucket in Wasm pages.
    bucket_size_in_pages: Nat16;
    // Reserved bytes for future extensions
    _reserved: [Nat8]; // HEADER_RESERVED_BYTES bytes = 32 bytes
    // The size of each individual memory that can be created by the memory manager.
    memory_sizes_in_pages: [Nat64]; // (MAX_NUM_MEMORIES * 8) bytes = (255 * 8) bytes = 2040 bytes
  };

  let SIZE_HEADER : Nat64 = 2080;

  public func saveManagerHeader(header: Header, addr: Address, memory: Memory) {
    Memory.write(memory, addr                     ,                                               header.magic);
    Memory.write(memory, addr + 3                 ,                                           [header.version]);
    Memory.write(memory, addr + 3 + 1             ,      Conversion.nat16ToBytes(header.num_allocated_buckets));
    Memory.write(memory, addr + 3 + 1 + 2         ,       Conversion.nat16ToBytes(header.bucket_size_in_pages));
    Memory.write(memory, addr + 3 + 1 + 2 + 2     ,                                           header._reserved);
    Memory.write(memory, addr + 3 + 1 + 2 + 2 + 32, Conversion.nat64ArrayToBytes(header.memory_sizes_in_pages));
  };

  public func loadManagerHeader(addr: Address, memory: Memory) : Header {
    {
      magic =                                              Memory.read(memory, addr,                         3);
      version =                                            Memory.read(memory, addr + 3,                     1)[0];
      num_allocated_buckets =      Conversion.bytesToNat16(Memory.read(memory, addr + 3 + 1,                 2));
      bucket_size_in_pages =       Conversion.bytesToNat16(Memory.read(memory, addr + 3 + 1 + 2,             2));
      _reserved =                                          Memory.read(memory, addr + 3 + 1 + 2 + 2,        32);
      memory_sizes_in_pages = Conversion.bytesToNat64Array(Memory.read(memory, addr + 3 + 1 + 2 + 2 + 32, 2040));
    };
  };

  public class VirtualMemory(id: MemoryId, memory_manager: MemoryManagerInner) {

    // Assert the id is correct
    verifyId(id);
    
    public let id_ : MemoryId = id;
    public let memory_manager_ : MemoryManagerInner = memory_manager;

    public func size() : Nat64 {
      memory_manager_.memorySize(id_);
    };

    public func grow(pages: Nat64) : Int64 {
      memory_manager_.grow(id_, pages);
    };

    public func read(offset: Nat64, size: Nat) : [Nat8] {
      memory_manager_.read(id_, offset, size);
    };

    public func write(offset: Nat64, src: [Nat8]) {
      memory_manager_.write(id_, offset, src);
    };
  
  };

  public func initInner(memory: Memory, bucket_size_in_pages: Nat16) : MemoryManagerInner {
    if (memory.size() == 0) {
      // Memory is empty. Create a new map.
      return newInner(memory, bucket_size_in_pages);
    };

    // Check if the magic in the memory corresponds to this object.
    let dst = Memory.read(memory, 0, 3);
    if (dst != Blob.toArray(Text.encodeUtf8(MAGIC))) {
      // No memory manager found. Create a new instance.
      return newInner(memory, bucket_size_in_pages);
    } else {
      // The memory already contains a memory manager. Load it.
      let mem_mgr = loadInner(memory);

      // Assert that the bucket size passed is the same as the one previously stored.
      if (mem_mgr.getBucketSizeInPages() != bucket_size_in_pages){
        Debug.trap("The bucket size of the loaded memory manager is different than the given one.");
      };

      mem_mgr;
    };
  };

  public func newInner(memory: Memory, bucket_size_in_pages: Nat16) : MemoryManagerInner {
    let mem_mgr = MemoryManagerInner(
      memory,
      0,
      bucket_size_in_pages,
      Array.init<Nat64>(Nat8.toNat(MAX_NUM_MEMORIES), 0),
      RBTree.RBTree<MemoryId, Buffer<BucketId>>(Nat8.compare)
    );

    mem_mgr.saveHeader();

    // Mark all the buckets as unallocated.
    Memory.write(
      memory, 
      bucketAllocationsAddress(0),
      Array.tabulate<Nat8>(Nat8.toNat(MAX_NUM_MEMORIES), func(index: Nat) : Nat8 { UNALLOCATED_BUCKET_MARKER; })
    );

    mem_mgr;
  };

  public func loadInner(memory: Memory) : MemoryManagerInner {
    // Read the header from memory.
    let header = loadManagerHeader(Constants.ADDRESS_0, memory);
    if (header.magic != Blob.toArray(Text.encodeUtf8(MAGIC))) { Debug.trap("Bad magic."); };
    if (header.version != LAYOUT_VERSION)                     { Debug.trap("Unsupported version."); };

    let buckets = Memory.read(memory, bucketAllocationsAddress(0), Nat64.toNat(MAX_NUM_BUCKETS));

    let memory_buckets = RBTree.RBTree<MemoryId, Buffer<BucketId>>(Nat8.compare);

    for (bucket_idx in Array.keys(buckets)){
      let memory = buckets[bucket_idx];
      if (memory != UNALLOCATED_BUCKET_MARKER){
        let buckets = Option.get(memory_buckets.get(memory), Buffer.Buffer<BucketId>(1));
        buckets.add(Nat16.fromNat(bucket_idx));
        memory_buckets.put(memory, buckets);
      };
    };

    MemoryManagerInner(
      memory,
      header.num_allocated_buckets,
      header.bucket_size_in_pages,
      Array.thaw(header.memory_sizes_in_pages),
      memory_buckets
    );
  };

  public class MemoryManagerInner(
    memory: Memory,
    allocated_buckets: Nat16,
    bucket_size_in_pages: Nat16,
    memory_sizes_in_pages: [var Nat64],
    memory_buckets: RBTree<MemoryId, Buffer<BucketId>>
  ){
    // Make sure the array of memory sizes has the correct size.
    assert(memory_sizes_in_pages.size() == Nat8.toNat(MAX_NUM_MEMORIES));
    
    public let memory_ : Memory = memory;
    // The number of buckets that have been allocated.
    var allocated_buckets_ : Nat16 = allocated_buckets;
    let bucket_size_in_pages_ : Nat16 = bucket_size_in_pages;
    // An array storing the size (in pages) of each of the managed memories.
    let memory_sizes_in_pages_ : [var Nat64] = memory_sizes_in_pages;
    // A map mapping each managed memory to the bucket ids that are allocated to it.
    public let memory_buckets_ : RBTree<MemoryId, Buffer<BucketId>> = memory_buckets;

    public func getBucketSizeInPages() : Nat16 {
      bucket_size_in_pages_;
    };

    public func saveHeader() {
      let header = {
        magic = Blob.toArray(Text.encodeUtf8(MAGIC));
        version = LAYOUT_VERSION;
        num_allocated_buckets = allocated_buckets_;
        bucket_size_in_pages = bucket_size_in_pages_;
        _reserved = Array.tabulate<Nat8>(HEADER_RESERVED_BYTES, func(index: Nat) : Nat8 { 0; });
        memory_sizes_in_pages = Array.freeze(memory_sizes_in_pages_);
      };

      saveManagerHeader(header, Constants.ADDRESS_0, memory_);
    };

    // Returns the size of a memory (in pages).
    public func memorySize(id: MemoryId) : Nat64 {
      verifyId(id);

      memory_sizes_in_pages_[Nat8.toNat(id)];
    };

    // Grows the memory with the given id by the given number of pages.
    public func grow(id: MemoryId, pages: Nat64) : Int64 {
      verifyId(id);

      // Compute how many additional buckets are needed.
      let old_size = memorySize(id);
      let new_size = old_size + pages;
      let current_buckets = numBucketsNeeded(old_size);
      let required_buckets = numBucketsNeeded(new_size);
      let new_buckets_needed = required_buckets - current_buckets;

      if (new_buckets_needed + Nat64.fromNat(Nat16.toNat(allocated_buckets_)) > MAX_NUM_BUCKETS) {
        // Exceeded the memory that can be managed.
        return -1;
      };

      // Allocate new buckets as needed.
      for (_ in Iter.range(0, Nat64.toNat(new_buckets_needed) - 1)) {
        let new_bucket_id = allocated_buckets_;

        let buckets = Option.get(memory_buckets_.get(id), Buffer.Buffer<BucketId>(1));
        buckets.add(new_bucket_id);
        memory_buckets_.put(id, buckets);

        // Write in stable store that this bucket belongs to the memory with the provided `id`.
        Memory.write(memory_, bucketAllocationsAddress(new_bucket_id), [id]);

        allocated_buckets_ += 1;
      };

      // Grow the underlying memory if necessary.
      let pages_needed = BUCKETS_OFFSET_IN_PAGES
        + Nat64.fromNat(Nat16.toNat(bucket_size_in_pages_)) * Nat64.fromNat(Nat16.toNat(allocated_buckets_));
      if (pages_needed > memory_.size()) {
        let additional_pages_needed = pages_needed - memory_.size();
        if (memory_.grow(additional_pages_needed) == -1){
          Debug.trap(Nat8.toText(id) # ": grow failed");
        };
      };

      // Update the memory with the new size.
      memory_sizes_in_pages_[Nat8.toNat(id)] := new_size;

      // Update the header and return the old size.
      saveHeader();
      Int64.fromNat64(old_size);
    };

    public func write(id: MemoryId, offset: Nat64, src: [Nat8]) {
      verifyId(id);

      if ((offset + Nat64.fromNat(src.size())) > memorySize(id) * Constants.WASM_PAGE_SIZE) {
        Debug.trap(Nat8.toText(id) # ": write out of bounds");
      };

      var bytes_written : Nat = 0;
      for ({address; length;} in bucketIter(id, offset, src.size())) {
        Memory.write(
          memory_,
          address,
          Array.tabulate<Nat8>(Nat64.toNat(length), func(idx: Nat) : Nat8 { src[bytes_written + idx]; })
        );

        bytes_written += Nat64.toNat(length);
      };
    };

    public func read(id: MemoryId, offset: Nat64, size: Nat) : [Nat8] {
      verifyId(id);
      if ((offset + Nat64.fromNat(size)) > memorySize(id) * Constants.WASM_PAGE_SIZE) {
        Debug.trap(Nat8.toText(id) # ": read out of bounds");
      };
      let buffer = Buffer.Buffer<[Nat8]>(0);
      for ({address; length;} in bucketIter(id, offset, size)) {
        buffer.add(Memory.read(
          memory_,
          address,
          Nat64.toNat(length),
        ));
      };
      Array.flatten(buffer.toArray());
    };

    // Initializes a [`BucketIterator`].
    public func bucketIter(id: MemoryId, offset: Nat64, length: Nat) : BucketIterator {
      verifyId(id);

      // Get the buckets allocated to the given memory id.
      let buckets = Option.get(memory_buckets_.get(id), Buffer.Buffer<BucketId>(0));

      BucketIterator(
        {
          address = offset;
          length = Nat64.fromNat(length);
        },
        buckets.toArray(),
        bucketSizeInBytes()
      );
    };

    public func bucketSizeInBytes() : Bytes {
      Nat64.fromNat(Nat16.toNat(bucket_size_in_pages_)) * Constants.WASM_PAGE_SIZE;
    };

    // Returns the number of buckets needed to accommodate the given number of pages.
    public func numBucketsNeeded(num_pages: Nat64) : Nat64 {
      // Ceiling division.
      let bucket_size_in_pages = Nat64.fromNat(Nat16.toNat(bucket_size_in_pages_));
      (num_pages + bucket_size_in_pages - 1) / bucket_size_in_pages;
    };

  };

  public type Segment = {
    address: Address;
    length: Bytes;
  };

  // An iterator that maps a segment of virtual memory to segments of real memory.
  //
  // A segment in virtual memory can map to multiple segments of real memory. Here's an example:
  //
  // Virtual Memory
  // --------------------------------------------------------
  //      (A) ---------- SEGMENT ---------- (B)
  // --------------------------------------------------------
  // ↑         ↑         ↑         ↑
  // Bucket 0    Bucket 1    Bucket 2    Bucket 3
  //
  // The [`VirtualMemory`] is internally divided into fixed-size buckets. In the memory's virtual
  // address space, all these buckets are consecutive, but in real memory this may not be the case.
  //
  // A virtual segment would first be split at the bucket boundaries. The example virtual segment
  // above would be split into the following segments:
  //
  //  (A, end of bucket 0)
  //  (start of bucket 1, end of bucket 1)
  //  (start of bucket 2, B)
  //
  // Each of the segments above can then be translated into the real address space by looking up
  // the underlying buckets' addresses in real memory.
  public class BucketIterator (
    virtual_segment : Segment,
    buckets : [BucketId],
    bucket_size_in_bytes : Bytes
  ) {

    type Item = Segment;
    
    var virtual_segment_: Segment = virtual_segment;
    public let buckets_: [BucketId] = buckets;
    public let bucket_size_in_bytes_: Bytes = bucket_size_in_bytes;
  
    public func next() : ?Item {
      if (virtual_segment_.length == 0) {
        return null;
      };

      // Map the virtual segment's address to a real address.
      let bucket_idx = Nat64.toNat(virtual_segment_.address / bucket_size_in_bytes_);
      if (bucket_idx >= buckets_.size()){
        Debug.trap("bucket idx out of bounds");
      };

      let bucket_address = bucketAddress(buckets_[bucket_idx]);

      let real_address = bucket_address
        + virtual_segment_.address % bucket_size_in_bytes_;

      // Compute how many bytes are in this real segment.
      let bytes_in_segment = do {
        let next_bucket_address = bucket_address + bucket_size_in_bytes_;

        // Write up to either the end of the bucket, or the end of the segment.
        Nat64.min(
          next_bucket_address - real_address,
          virtual_segment_.length
        );
      };

      // Update the virtual segment to exclude the portion we're about to return.
      virtual_segment_ := {
        length = virtual_segment_.length - bytes_in_segment;
        address = virtual_segment_.address + bytes_in_segment;
      };
      
      ?{
        address = real_address;
        length = bytes_in_segment;
      };
    };

    // Returns the address of a given bucket.
    public func bucketAddress(id: BucketId) : Address {
      let bucket_offset_in_bytes = BUCKETS_OFFSET_IN_PAGES * Constants.WASM_PAGE_SIZE;
      bucket_offset_in_bytes + bucket_size_in_bytes_ * Nat64.fromNat(Nat16.toNat(id));
    };

  };

  public type MemoryId = Nat8;

  public func verifyId(id: MemoryId) {
    // Any ID can be used except the special value that's used internally to
    // mark a bucket as unallocated.
    if(id == UNALLOCATED_BUCKET_MARKER){
      Debug.trap("Memory ID cannot be equal to " # Nat8.toText(UNALLOCATED_BUCKET_MARKER));
    };
  };

  public type BucketId = Nat16;

  public func bucketAllocationsAddress(id: BucketId) : Address {
    Constants.ADDRESS_0 + SIZE_HEADER + Nat64.fromNat(Nat16.toNat(id));
  };

};
