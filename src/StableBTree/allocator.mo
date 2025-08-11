import Types "types";
import Conversion "conversion";
import Constants "constants";
import Memory "memory";

import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Debug "mo:base/Debug";

module {

  // For convenience: from types module
  type Address = Types.Address;
  type Bytes = Types.Bytes;
  type Memory = Types.Memory;

  let ALLOCATOR_LAYOUT_VERSION: Nat8 = 1;
  let CHUNK_LAYOUT_VERSION: Nat8 = 1;

  let ALLOCATOR_MAGIC = "BTA";
  let CHUNK_MAGIC = "CHK";

  /// Initialize an allocator and store it in address `addr`.
  ///
  /// The allocator assumes that all memory from `addr` onwards is free.
  ///
  /// When initialized, the allocator has the following memory layout:
  ///
  /// [   AllocatorHeader       | ChunkHeader ]
  ///      ..   free_list_head  ↑      next
  ///                |__________|       |____ NULL
  ///
  public func initAllocator(memory: Memory, addr: Address, allocation_size: Bytes) : Allocator {
    let free_list_head = addr + SIZE_ALLOCATOR_HEADER;

    // Create the initial memory chunk and save it directly after the allocator's header.
    let chunk_header = initChunkHeader();
    saveChunkHeader(chunk_header, free_list_head, memory);

    let allocator = Allocator({
      header_addr = addr;
      allocation_size;
      num_allocated_chunks: Nat64 = 0;
      free_list_head;
      memory = memory;
    });

    allocator.saveAllocator();

    allocator;
  };

  /// Load an allocator from memory at the given `addr`.
  public func loadAllocator(memory: Memory, addr: Address) : Allocator {
    
    let header = {
      magic                =                         Memory.read(memory, addr,                         3);
      version              =                         Memory.read(memory, addr + 3,                     1)[0];
      _alignment           =                         Memory.read(memory, addr + 3 + 1,                 4);
      allocation_size      = Conversion.bytesToNat64(Memory.read(memory, addr + 3 + 1 + 4,             8));
      num_allocated_chunks = Conversion.bytesToNat64(Memory.read(memory, addr + 3 + 1 + 4 + 8,         8));
      free_list_head       = Conversion.bytesToNat64(Memory.read(memory, addr + 3 + 1 + 4 + 8 + 8,     8));
      _buffer              =                         Memory.read(memory, addr + 3 + 1 + 4 + 8 + 8 + 8, 16);
    };

    if (header.magic != Blob.toArray(Text.encodeUtf8(ALLOCATOR_MAGIC))) { Debug.trap("Bad magic."); };
    if (header.version != ALLOCATOR_LAYOUT_VERSION)                     { Debug.trap("Unsupported version."); };
    
    Allocator({
      header_addr = addr;
      allocation_size = header.allocation_size;
      num_allocated_chunks = header.num_allocated_chunks;
      free_list_head = header.free_list_head;
      memory = memory;
    });
  };

  type AllocatorVariables = {
    header_addr: Address;
    allocation_size: Bytes;
    num_allocated_chunks: Nat64;
    free_list_head: Address;
    memory: Memory;
  };

  /// A free list constant-size chunk allocator.
  ///
  /// The allocator allocates chunks of size `allocation_size` from the given `memory`.
  ///
  /// # Properties
  ///
  /// * The allocator tries to minimize its memory footprint, growing the memory in
  ///   size only when all the available memory is allocated.
  ///
  /// * The allocator makes no assumptions on the size of the memory and will
  ///   continue growing so long as the provided `memory` allows it.
  ///
  /// The allocator divides the memory into "chunks" of equal size. Each chunk contains:
  ///     a) A `ChunkHeader` with metadata about the chunk.
  ///     b) A blob of length `allocation_size` that can be used freely by the user.
  ///
  /// # Assumptions:
  ///
  /// * The given memory is not being used by any other data structure.
  public class Allocator(variables: AllocatorVariables) {

    /// Members
    // The address in memory where the `AllocatorHeader` is stored.
    let header_addr_ : Address = variables.header_addr;
    // The size of the chunk to allocate in bytes.
    let allocation_size_ : Bytes = variables.allocation_size;
    // The number of chunks currently allocated.
    var num_allocated_chunks_ : Nat64 = variables.num_allocated_chunks;
    // A linked list of unallocated chunks.
    var free_list_head_ : Address = variables.free_list_head;
    /// The memory to save and load the data.
    let memory_ : Memory = variables.memory;

    /// Getters
    public func getHeaderAddr() : Address { header_addr_; };
    public func getAllocationSize() : Bytes { allocation_size_; };
    public func getNumAllocatedChunks() : Nat64 { num_allocated_chunks_; };
    public func getFreeListHead() : Address { free_list_head_; };
    public func getMemory() : Memory { memory_; };

    /// Allocates a new chunk from memory with size `allocation_size`.
    ///
    /// Internally, there are two cases:
    ///
    /// 1) The list of free chunks (`free_list_head`) has only one element.
    ///    This case happens when we initialize a new allocator, or when
    ///    all of the previously allocated chunks are still in use.
    ///
    ///    Example memory layout:
    ///
    ///    [   AllocatorHeader       | ChunkHeader ]
    ///         ..   free_list_head  ↑      next
    ///                   |__________↑       |____ NULL
    ///
    ///    In this case, the chunk in the free list is allocated to the user
    ///    and a new `ChunkHeader` is appended to the allocator's memory,
    ///    growing the memory if necessary.
    ///
    ///    [   AllocatorHeader       | ChunkHeader | ... | ChunkHeader2 ]
    ///         ..   free_list_head      (allocated)     ↑      next
    ///                   |______________________________↑       |____ NULL
    ///
    /// 2) The list of free chunks (`free_list_head`) has more than one element.
    ///
    ///    Example memory layout:
    ///
    ///    [   AllocatorHeader       | ChunkHeader1 | ... | ChunkHeader2 ]
    ///         ..   free_list_head  ↑       next         ↑       next
    ///                   |__________↑        |___________↑         |____ NULL
    ///
    ///    In this case, the first chunk in the free list is allocated to the
    ///    user, and the head of the list is updated to point to the next free
    ///    block.
    ///
    ///    [   AllocatorHeader       | ChunkHeader1 | ... | ChunkHeader2 ]
    ///         ..   free_list_head      (allocated)      ↑       next
    ///                   |_______________________________↑         |____ NULL
    ///
    public func allocate() :  Address {
      // Get the next available chunk.
      let chunk_addr = free_list_head_;
      let chunk = loadChunkHeader(chunk_addr, memory_);

      // The available chunk must not be allocated.
      if (chunk.allocated) { Debug.trap("Attempting to allocate an already allocated chunk."); };

      // Allocate the chunk.
      let updated_chunk = {
        magic = chunk.magic;
        version = chunk.version;
        allocated = true;
        _alignment = chunk._alignment;
        next = chunk.next;
      };
      saveChunkHeader(updated_chunk, chunk_addr, memory_);

      // Update the head of the free list.
      if (chunk.next != Constants.NULL) {
        // The next chunk becomes the new head of the list.
        free_list_head_ := chunk.next;
      } else {
        // There is no next chunk. Shift everything by chunk size.
        free_list_head_ += chunkSize();
        // Write new chunk to that location.
        saveChunkHeader(initChunkHeader(), free_list_head_, memory_);
      };

      num_allocated_chunks_ += 1;
      saveAllocator();

      // Return the chunk's address offset by the chunk's header.
      chunk_addr + SIZE_CHUNK_HEADER;
    };

    /// Deallocates a previously allocated chunk.
    public func deallocate(address: Address) {
      let chunk_addr = address - SIZE_CHUNK_HEADER;
      let chunk = loadChunkHeader(chunk_addr, memory_);

      // The available chunk must be allocated.
      if (not chunk.allocated) { Debug.trap("Attempting to deallocate a chunk that is not allocated."); };

      // Deallocate the chunk.
      let updated_chunk = {
        magic = chunk.magic;
        version = chunk.version;
        allocated = false;
        _alignment = chunk._alignment;
        next = free_list_head_;
      };
      saveChunkHeader(updated_chunk, chunk_addr, memory_);

      free_list_head_ := chunk_addr;
      num_allocated_chunks_ -= 1;
      
      saveAllocator();
    };

    /// Saves the allocator to memory.
    public func saveAllocator() {
      let header = getHeader();
      let addr = header_addr_;

      Memory.write(memory_, addr,                                                                 header.magic);
      Memory.write(memory_, addr + 3,                                                         [header.version]);
      Memory.write(memory_, addr + 3 + 1,                                                    header._alignment);
      Memory.write(memory_, addr + 3 + 1 + 4,                  Conversion.nat64ToBytes(header.allocation_size));
      Memory.write(memory_, addr + 3 + 1 + 4 + 8,         Conversion.nat64ToBytes(header.num_allocated_chunks));
      Memory.write(memory_, addr + 3 + 1 + 4 + 8 + 8,           Conversion.nat64ToBytes(header.free_list_head));
      Memory.write(memory_, addr + 3 + 1 + 4 + 8 + 8 + 8,                                       header._buffer);
    };

    // The full size of a chunk, which is the size of the header + the `allocation_size` that's
    // available to the user.
    public func chunkSize() : Bytes {
      allocation_size_ + SIZE_CHUNK_HEADER;
    };

    func getHeader() : AllocatorHeader{
      {
        magic = Blob.toArray(Text.encodeUtf8(ALLOCATOR_MAGIC));
        version = ALLOCATOR_LAYOUT_VERSION;
        _alignment = [0, 0, 0, 0];
        allocation_size = allocation_size_;
        num_allocated_chunks = num_allocated_chunks_;
        free_list_head = free_list_head_;
        _buffer = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
      };
    };

  };

  type AllocatorHeader = {
    magic: [Nat8]; // 3 bytes
    version: Nat8;
    // Empty space to memory-align the following fields.
    _alignment: [Nat8]; // 4 bytes
    allocation_size: Bytes;
    num_allocated_chunks: Nat64;
    free_list_head: Address;
    // Additional space reserved to add new fields without breaking backward-compatibility.
    _buffer: [Nat8]; // 16 bytes
  };

  public let SIZE_ALLOCATOR_HEADER : Nat64 = 48;

  type ChunkHeader = {
    magic: [Nat8]; // 3 bytes
    version: Nat8;
    allocated: Bool;
    // Empty space to memory-align the following fields.
    _alignment: [Nat8]; // 3 bytes
    next: Address;
  };

  public let SIZE_CHUNK_HEADER : Nat64 = 16;

  // Initializes an unallocated chunk that doesn't point to another chunk.
  func initChunkHeader() : ChunkHeader {
    {
      magic = Blob.toArray(Text.encodeUtf8(CHUNK_MAGIC));
      version = CHUNK_LAYOUT_VERSION;
      allocated = false;
      _alignment = [0, 0, 0];
      next = Constants.NULL;
    };
  };

  func saveChunkHeader(header: ChunkHeader, addr: Address, memory: Memory) {
    Memory.write(memory, addr,                                              header.magic);
    Memory.write(memory, addr + 3,                                      [header.version]);
    Memory.write(memory, addr + 3 + 1,          Conversion.boolToBytes(header.allocated));
    Memory.write(memory, addr + 3 + 1 + 1,                             header._alignment);
    Memory.write(memory, addr + 3 + 1 + 1 + 3,      Conversion.nat64ToBytes(header.next));
  };

  public func loadChunkHeader(addr: Address, memory: Memory) : ChunkHeader {
    let header = {
      magic =                            Memory.read(memory, addr,                 3);
      version =                          Memory.read(memory, addr + 3,             1)[0];
      allocated = Conversion.bytesToBool(Memory.read(memory, addr + 3 + 1,         1));
      _alignment =                       Memory.read(memory, addr + 3 + 1 + 1,     3);
      next =     Conversion.bytesToNat64(Memory.read(memory, addr + 3 + 1 + 1 + 3, 8));
    };
    if (header.magic != Blob.toArray(Text.encodeUtf8(CHUNK_MAGIC))) { Debug.trap("Bad magic."); };
    if (header.version != CHUNK_LAYOUT_VERSION)                     { Debug.trap("Unsupported version."); };
    
    header;
  };

};