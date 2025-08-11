import Constants "constants";
import Utils "utils";
import Types "types";

import StableMemory "mo:base/ExperimentalStableMemory";
import Blob "mo:base/Blob";
import Int64 "mo:base/Int64";
import Buffer "mo:base/Buffer";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Result "mo:base/Result";

module {

  // For convenience: from types module
  type Memory = Types.Memory;
  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;

  type GrowFailed = {
    current_size: Nat64;
    delta: Nat64;
  };

  /// Writes the bytes at the specified address, growing the memory size if needed.
  public func safeWrite(memory: Memory, address: Nat64, bytes: [Nat8]) : Result<(), GrowFailed> {
    // Traps on overflow.
    let offset = address + Nat64.fromNat(bytes.size());
    // Compute the number of pages required.
    let pages = (offset + Constants.WASM_PAGE_SIZE - 1) / Constants.WASM_PAGE_SIZE;
    // Grow the number of pages if necessary.
    if (pages > memory.size()){
      let diff_pages = pages - memory.size();
      if (memory.grow(diff_pages) < 0){
        return #err({
          current_size = memory.size();
          delta = diff_pages;
        });  
      };
    };
    // Store the bytes in memory.
    memory.write(address, bytes);
    #ok();
  };

  /// Like [safe_write], but traps if the memory.grow fails.
  public func write(memory: Memory, address: Nat64, bytes: [Nat8]) {
    switch(safeWrite(memory, address, bytes)){
      case(#err({current_size; delta})){
        Debug.trap("Failed to grow memory from " # Nat64.toText(current_size) 
          # " pages to " # Nat64.toText(current_size + delta) 
          # " pages (delta = " # Nat64.toText(delta) # " pages).");
      };
      case(_) {};
    };
  };

  /// Reads the bytes at the specified address, traps if exceeds memory size.
  public func read(memory: Memory, address: Nat64, size: Nat) : [Nat8] {
    memory.read(address, size);
  };

  public let STABLE_MEMORY = object {
    public func size() : Nat64 { 
      StableMemory.size(); 
    };
    public func grow(pages: Nat64) : Int64 {
      let old_size = StableMemory.grow(pages);
      if (old_size == 0xFFFF_FFFF_FFFF_FFFF){
        return -1;
      };
      Int64.fromNat64(old_size);
    };
    public func write(address: Nat64, bytes: [Nat8]) {
      StableMemory.storeBlob(address, Blob.fromArray(bytes));
    };
    public func read(address: Nat64, size: Nat) : [Nat8] {
      Blob.toArray(StableMemory.loadBlob(address, size));
    };
  };

  public class VecMemory() = this {

    // 2^64 - 1 = 18446744073709551615
    let MAX_PAGES : Nat64 = 18446744073709551615 / Constants.WASM_PAGE_SIZE;

    let buffer_ = Buffer.Buffer<Nat8>(0);

    public func size() : Nat64 {
      Nat64.fromNat(buffer_.size()) / Constants.WASM_PAGE_SIZE;
    };

    public func grow(pages: Nat64) : Int64 {
      let size = this.size();
      let num_pages = size + pages;
      // Number of pages cannot exceed defined MAX_PAGES.
      if (num_pages > MAX_PAGES) {
        return -1;
      };
      // Add the pages (initialized with zeros) to the memory buffer.
      let to_add = Array.freeze(Array.init<Nat8>(Nat64.toNat(pages * Constants.WASM_PAGE_SIZE), 0));
      buffer_.append(Utils.toBuffer(to_add));
      // Return the previous size.
      return Int64.fromIntWrap(Nat64.toNat(size));
    };

    public func read(address: Nat64, size: Nat) : [Nat8] {
      // Traps on overflow.
      let offset = Nat64.toNat(address) + size;
      // Cannot read pass the memory buffer size.
      if (offset > buffer_.size()){
        Debug.trap("read: out of bounds");
      };
      // Copy the bytes from the memory buffer.
      let bytes = Buffer.Buffer<Nat8>(size);
      for (idx in Iter.range(Nat64.toNat(address), offset - 1)){
        bytes.add(buffer_.get(idx));
      };
      bytes.toArray();
    };

    public func write(address: Nat64, bytes: [Nat8]) {
      let offset = Nat64.toNat(address) + bytes.size();
      // Check that the bytes fit into the buffer.
      if (offset > buffer_.size()){
        Debug.trap("write: out of bounds");
      };
      // Copy the given bytes in the memory buffer.
      for (idx in Array.keys(bytes)){
        buffer_.put(Nat64.toNat(address) + idx, bytes[idx]);
      };
    };

    public func toText() : Text {
      let text_buffer = Buffer.Buffer<Text>(0);
      text_buffer.add("Memory : [");
      for (byte in buffer_.vals()){
        text_buffer.add(Nat8.toText(byte) # ", ");
      };
      text_buffer.add("]");
      Text.join("", text_buffer.vals());
    };

  };

};