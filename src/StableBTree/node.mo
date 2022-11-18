import Types "types";
import Conversion "conversion";
import Constants "constants";
import Utils "utils";
import Memory "memory";

import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Result "mo:base/Result";
import Order "mo:base/Order";

module {

  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  type Buffer<T> = Buffer.Buffer<T>;
  type Order = Order.Order;
  // For convenience: from types module
  type Address = Types.Address;
  type Bytes = Types.Bytes;
  type Memory = Types.Memory;
  type Entry = Types.Entry;
  type NodeType = Types.NodeType;

  let LAYOUT_VERSION: Nat8 = 1;
  let MAGIC = "BTN";
  let LEAF_NODE_TYPE: Nat8 = 0;
  let INTERNAL_NODE_TYPE: Nat8 = 1;
  // The size of Nat32 in bytes.
  let U32_SIZE: Nat = 4;
  // The size of an address in bytes.
  let ADDRESS_SIZE: Nat = 8;

  /// Loads a node from memory at the given address.
  public func load(
    address: Address,
    memory: Memory,
    max_key_size: Nat32,
    max_value_size: Nat32
  ) : Node {
    
    // Load the header.
    let header = loadNodeHeader(address, memory);
    if (header.magic != Blob.toArray(Text.encodeUtf8(MAGIC))) { Debug.trap("Bad magic."); };
    if (header.version != LAYOUT_VERSION)                     { Debug.trap("Unsupported version."); };

    // Load the entries.
    var entries = Buffer.Buffer<Entry>(0);
    var offset = SIZE_NODE_HEADER;
    for (_ in Iter.range(0, Nat16.toNat(header.num_entries - 1))){
      // Read the key's size.
      let key_size = Conversion.bytesToNat32(Memory.read(memory, address + offset, U32_SIZE));
      offset += Nat64.fromNat(U32_SIZE);

      // Read the key.
      let key = Memory.read(memory, address + offset, Nat32.toNat(key_size));
      offset += Nat64.fromNat(Nat32.toNat(max_key_size));

      // Read the value's size.
      let value_size = Conversion.bytesToNat32(Memory.read(memory, address + offset, U32_SIZE));
      offset += Nat64.fromNat(U32_SIZE);

      // Read the value.
      let value = Memory.read(memory, address + offset, Nat32.toNat(value_size));
      offset += Nat64.fromNat(Nat32.toNat(max_value_size));

      entries.add((key, value));
    };

    // Load children if this is an internal 
    var children = Buffer.Buffer<Address>(0);
    if (header.node_type == INTERNAL_NODE_TYPE) {
      // The number of children is equal to the number of entries + 1.
      for (_ in Iter.range(0, Nat16.toNat(header.num_entries))){
        let child = Conversion.bytesToNat64(Memory.read(memory, address + offset, ADDRESS_SIZE));
        offset += Nat64.fromNat(ADDRESS_SIZE);
        children.add(child);
      };
      assert(children.size() == entries.size() + 1);
    };

    Node({
      address;
      entries = entries.toArray();
      children = children.toArray();
      node_type = getNodeType(header);
      max_key_size;
      max_value_size;
    });
  };

  /// Returns the size of a node in bytes.
  ///
  /// See the documentation of [`Node`] for the memory layout.
  public func size(max_key_size: Nat32, max_value_size: Nat32) : Bytes {
    let max_key_size_n64 = Nat64.fromNat(Nat32.toNat(max_key_size));
    let max_value_size_n64 = Nat64.fromNat(Nat32.toNat(max_value_size));

    let node_header_size = SIZE_NODE_HEADER;
    let entry_size = Nat64.fromNat(U32_SIZE) + max_key_size_n64 + max_value_size_n64 + Nat64.fromNat(U32_SIZE);
    let child_size = Nat64.fromNat(ADDRESS_SIZE);

    node_header_size
      + getCapacity() * entry_size
      + (getCapacity() + 1) * child_size;
  };

  type NodeVariables = {
    address: Address;
    entries: [Entry];
    children: [Address];
    node_type: NodeType;
    max_key_size: Nat32;
    max_value_size: Nat32;
  };

  /// A node of a B-Tree.
  ///
  /// The node is stored in stable memory with the following layout:
  ///
  ///    |  NodeHeader  |  Entries (keys and values) |  Children  |
  ///
  /// Each node contains up to `CAPACITY` entries, each entry contains:
  ///     - size of key (4 bytes)
  ///     - key (`max_key_size` bytes)
  ///     - size of value (4 bytes)
  ///     - value (`max_value_size` bytes)
  ///
  /// Each node can contain up to `CAPACITY + 1` children, each child is 8 bytes.
  public class Node(variables : NodeVariables) {
    
    /// Members
    var address_ : Address = variables.address;
    var entries_ : Buffer<Entry> = Utils.toBuffer(variables.entries);
    var children_ : Buffer<Address> = Utils.toBuffer(variables.children);
    let node_type_ : NodeType = variables.node_type;
    let max_key_size_ : Nat32 = variables.max_key_size;
    let max_value_size_ : Nat32 = variables.max_value_size;

    /// Getters
    public func getAddress() : Address { address_; };
    public func getEntries() : Buffer<Entry> { entries_; };
    public func getChildren() : Buffer<Address> { children_; };
    public func getNodeType() : NodeType  { node_type_; };
    public func getMaxKeySize() : Nat32  { max_key_size_; };
    public func getMaxValueSize() : Nat32  { max_value_size_; };

    /// Saves the node to memory.
    public func save(memory: Memory) {
      switch(node_type_) {
        case(#Leaf){
          if (children_.size() != 0){
            Debug.trap("A leaf node cannot have children.");
          };
        };
        case(#Internal){
          if (children_.size() != entries_.size() + 1){
            Debug.trap("An internal node shall have its number of children equal to its number of entries + 1.");
          };
        };
      };

      // We should never be saving an empty node.
      if ((entries_.size() == 0) and (children_.size() == 0)){
        Debug.trap("An empty node cannot be saved.");
      };

      // Assert entries are sorted in strictly increasing order.
      if (not Utils.isSortedInIncreasingOrder(getKeys(), compareEntryKeys)) {
        Debug.trap("The node entries are not sorted in increasing order.");
      };

      let header = {
        magic = Blob.toArray(Text.encodeUtf8(MAGIC));
        version = LAYOUT_VERSION;
        node_type = switch(node_type_){
          case(#Leaf) { LEAF_NODE_TYPE; };
          case(#Internal) { INTERNAL_NODE_TYPE; };
        };
        num_entries = Nat16.fromNat(entries_.size());
      };

      saveNodeHeader(header, address_, memory);
      
      var offset = SIZE_NODE_HEADER;

      // Write the entries.
      for ((key, value) in entries_.vals()) {
        // Write the size of the key.
        Memory.write(memory, address_ + offset, Conversion.nat32ToBytes(Nat32.fromNat(key.size())));
        offset += Nat64.fromNat(U32_SIZE);

        // Write the key.
        Memory.write(memory, address_ + offset, key);
        offset += Nat64.fromNat(Nat32.toNat(max_key_size_));

        // Write the size of the value.
        Memory.write(memory, address_ + offset, Conversion.nat32ToBytes(Nat32.fromNat(value.size())));
        offset += Nat64.fromNat(U32_SIZE);

        // Write the value.
        Memory.write(memory, address_ + offset, value);
        offset += Nat64.fromNat(Nat32.toNat(max_value_size_));
      };

      // Write the children
      for (child in children_.vals()){
        Memory.write(memory, address_ + offset, Conversion.nat64ToBytes(child));
        offset += Nat64.fromNat(ADDRESS_SIZE); // Address size
      };
    };

    /// Returns the entry with the max key in the subtree.
    public func getMax(memory: Memory) : Entry {
      switch(node_type_){
        case(#Leaf) {
          // NOTE: a node can never be empty, so this access is safe.
          if (entries_.size() == 0) { Debug.trap("A node can never be empty."); };
          entries_.get(entries_.size() - 1);
        };
        case(#Internal) { 
          // NOTE: an internal node must have children, so this access is safe.
          if (children_.size() == 0) { Debug.trap("An internal node must have children."); };
          let last_child = load(children_.get(children_.size() - 1), memory, max_key_size_, max_value_size_);
          last_child.getMax(memory);
        };
      };
    };

    /// Returns the entry with min key in the subtree.
    public func getMin(memory: Memory) : Entry {
      switch(node_type_){
        case(#Leaf) {
          // NOTE: a node can never be empty, so this access is safe.
          if (entries_.size() == 0) { Debug.trap("A node can never be empty."); };
          entries_.get(0);
        };
        case(#Internal) { 
          // NOTE: an internal node must have children, so this access is safe.
          if (children_.size() == 0) { Debug.trap("An internal node must have children."); };
          let first_child = load(children_.get(0), memory, max_key_size_, max_value_size_);
          first_child.getMin(memory);
        };
      };
    };

    /// Returns true if the node cannot store anymore entries, false otherwise.
    public func isFull() : Bool {
      entries_.size() >= Nat64.toNat(getCapacity());
    };

    /// Swaps the entry at index `idx` with the given entry, returning the old entry.
    public func swapEntry(idx: Nat, entry: Entry) : Entry {
      let old_entry = entries_.get(idx);
      entries_.put(idx, entry);
      old_entry;
    };

    /// Searches for the key in the node's entries.
    ///
    /// If the key is found then `Result::Ok` is returned, containing the index
    /// of the matching key. If the value is not found then `Result::Err` is
    /// returned, containing the index where a matching key could be inserted
    /// while maintaining sorted order.
    public func getKeyIdx(key: [Nat8]) : Result<Nat, Nat> {
      Utils.binarySearch(getKeys(), compareEntryKeys, key);
    };

    /// Get the child at the given index. Traps if the index is superior than the number of children.
    public func getChild(idx: Nat) : Address {
      children_.get(idx);
    };

    /// Get the entry at the given index. Traps if the index is superior than the number of entries.
    public func getEntry(idx: Nat) : Entry {
      entries_.get(idx);
    };

    /// Set the node's children
    public func setChildren(children: Buffer<Address>) {
      children_ := children;
    };

    /// Set the node's entries
    public func setEntries(entries: Buffer<Entry>) {
      entries_ := entries;
    };

    /// Set the node's address
    public func setAddress(address: Address) {
      address_ := address;
    };

    /// Add a child at the end of the node's children.
    public func addChild(child: Address) {
      children_.add(child);
    };

    /// Add an entry at the end of the node's entries.
    public func addEntry(entry: Entry) {
      entries_.add(entry);
    };

    /// Remove the child at the end of the node's children.
    public func popChild() : ?Address {
      children_.removeLast();
    };

    /// Remove the entry at the end of the node's entries.
    public func popEntry() : ?Entry {
      entries_.removeLast();
    };

    /// Insert a child into the node's children at the given index.
    public func insertChild(idx: Nat, child: Address) {
      Utils.insert(children_, idx, child);
    };

    /// Insert an entry into the node's entries at the given index.
    public func insertEntry(idx: Nat, entry: Entry) {
      Utils.insert(entries_, idx, entry);
    };

    /// Remove the child from the node's children at the given index.
    public func removeChild(idx: Nat) : Address {
      Utils.remove(children_, idx);
    };

    /// Remove the entry from the node's entries at the given index.
    public func removeEntry(idx: Nat) : Entry {
      Utils.remove(entries_, idx);
    };

    /// Append the given children to the node's children
    public func appendChildren(children: Buffer<Address>) {
      children_.append(children);
    };

    /// Append the given entries to the node's entries
    public func appendEntries(entries: Buffer<Entry>) {
      entries_.append(entries);
    };

    func getKeys() : [[Nat8]] {
      Array.map(entries_.toArray(), func(entry: Entry) : [Nat8] { entry.0; });
    };

    public func entriesToText() : Text {
      let text_buffer = Buffer.Buffer<Text>(0);
      text_buffer.add("Entries = [");
      for ((key, val) in entries_.vals()){
        text_buffer.add("e([");
        for (byte in Array.vals(key)){
          text_buffer.add(Nat8.toText(byte) # " ");
        };
        text_buffer.add("], [");
        for (byte in Array.vals(val)){
          text_buffer.add(Nat8.toText(byte) # " ");
        };
        text_buffer.add("]), ");
      };
      text_buffer.add("]");
      Text.join("", text_buffer.vals());
    };

  };

  public func makeEntry(key: [Nat8], value: [Nat8]) : Entry {
    (key, value);
  };

  /// Compare the two entries using their keys
  public func compareEntryKeys(key_a: [Nat8], key_b: [Nat8]) : Order {
    Utils.lexicographicallyCompare(key_a, key_b, Nat8.compare);
  };

  /// Deduce the node type based on the node header
  func getNodeType(header: NodeHeader) : NodeType {
    if (header.node_type == LEAF_NODE_TYPE) { return #Leaf; };
    if (header.node_type == INTERNAL_NODE_TYPE) { return #Internal; };
    Debug.trap("Unknown node type " # Nat8.toText(header.node_type));
  };

  /// The maximum number of entries per node.
  public func getCapacity() : Nat64 {
    2 * Nat64.fromNat(Constants.B) - 1;
  };

  // A transient data structure for reading/writing metadata into/from stable memory.
  type NodeHeader = {
    magic: [Nat8]; // 3 bytes
    version: Nat8;
    node_type: Nat8;
    num_entries: Nat16;
  };

  let SIZE_NODE_HEADER : Nat64 = 7;

  func saveNodeHeader(header: NodeHeader, addr: Address, memory: Memory) {
    Memory.write(memory, addr,                                            header.magic);
    Memory.write(memory, addr + 3,                                    [header.version]);
    Memory.write(memory, addr + 3 + 1,                              [header.node_type]);
    Memory.write(memory, addr + 3 + 1 + 1, Conversion.nat16ToBytes(header.num_entries));
  };

  func loadNodeHeader(addr: Address, memory: Memory) : NodeHeader {
    let header = {
      magic =                               Memory.read(memory, addr,             3);
      version =                             Memory.read(memory, addr + 3,         1)[0];
      node_type =                           Memory.read(memory, addr + 3 + 1,     1)[0];
      num_entries = Conversion.bytesToNat16(Memory.read(memory, addr + 3 + 1 + 1, 2));
    };
    header;
  };

};