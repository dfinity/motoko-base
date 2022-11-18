import Types "types";
import Conversion "conversion";
import Constants "constants";
import Utils "utils";

import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Result "mo:base/Result";
import Order "mo:base/Order";

module {

  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  type Buffer<T> = Buffer.Buffer<T>;
  type Order = Order.Order;
  // For convenience: from types module
  type Entry = Types.Entry;
  type NodeType = Types.NodeType;

  /// A node of a B-Tree.
  ///
  /// Each node can contain up to `CAPACITY + 1` children, each child is 8 bytes.
  public class Node(node_type: NodeType, node_identifier: Nat64) {
    
    /// Members
    var entries_ = Buffer.Buffer<Entry>(0);
    var children_ = Buffer.Buffer<Node>(0);
    let node_type_ = node_type;
    let node_identifier_ = node_identifier;

    /// Getters
    public func getEntries() : Buffer<Entry> { entries_; };
    public func getChildren() : Buffer<Node> { children_; };
    public func getNodeType() : NodeType  { node_type_; };
    public func getIdentifier() : Nat64  { node_identifier_; };

    /// Returns the entry with the max key in the subtree.
    public func getMax() : Entry {
      switch(node_type_){
        case(#Leaf) {
          // NOTE: a node can never be empty, so this access is safe.
          if (entries_.size() == 0) { Debug.trap("A node can never be empty."); };
          entries_.get(entries_.size() - 1);
        };
        case(#Internal) { 
          // NOTE: an internal node must have children, so this access is safe.
          if (children_.size() == 0) { Debug.trap("An internal node must have children."); };
          let last_child = children_.get(children_.size() - 1);
          last_child.getMax();
        };
      };
    };

    /// Returns the entry with min key in the subtree.
    public func getMin() : Entry {
      switch(node_type_){
        case(#Leaf) {
          // NOTE: a node can never be empty, so this access is safe.
          if (entries_.size() == 0) { Debug.trap("A node can never be empty."); };
          entries_.get(0);
        };
        case(#Internal) { 
          // NOTE: an internal node must have children, so this access is safe.
          if (children_.size() == 0) { Debug.trap("An internal node must have children."); };
          let first_child = children_.get(0);
          first_child.getMin();
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
    public func getChild(idx: Nat) : Node {
      children_.get(idx);
    };

    /// Get the entry at the given index. Traps if the index is superior than the number of entries.
    public func getEntry(idx: Nat) : Entry {
      entries_.get(idx);
    };

    public func getChildrenIdentifiers() : [Nat64] {
      let identifiers = Buffer.Buffer<Nat64>(children_.size());
      for (child in children_.vals()){
        identifiers.add(child.getIdentifier());
      };
      identifiers.toArray();
    };

    /// Set the node's children
    public func setChildren(children: Buffer<Node>) {
      children_ := children;
    };

    /// Set the node's entries
    public func setEntries(entries: Buffer<Entry>) {
      entries_ := entries;
    };

    /// Add a child at the end of the node's children.
    public func addChild(child: Node) {
      children_.add(child);
    };

    /// Add an entry at the end of the node's entries.
    public func addEntry(entry: Entry) {
      entries_.add(entry);
    };

    /// Set the child at given index
    public func setChild(idx: Nat, child: Node) {
      children_.put(idx, child);
    };

    /// Remove the child at the end of the node's children.
    public func popChild() : ?Node {
      children_.removeLast();
    };

    /// Remove the entry at the end of the node's entries.
    public func popEntry() : ?Entry {
      entries_.removeLast();
    };

    /// Insert a child into the node's children at the given index.
    public func insertChild(idx: Nat, child: Node) {
      Utils.insert(children_, idx, child);
    };

    /// Insert an entry into the node's entries at the given index.
    public func insertEntry(idx: Nat, entry: Entry) {
      Utils.insert(entries_, idx, entry);
    };

    /// Remove the child from the node's children at the given index.
    public func removeChild(idx: Nat) : Node {
      Utils.remove(children_, idx);
    };

    /// Remove the entry from the node's entries at the given index.
    public func removeEntry(idx: Nat) : Entry {
      Utils.remove(entries_, idx);
    };

    /// Append the given children to the node's children
    public func appendChildren(children: Buffer<Node>) {
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

  /// The maximum number of entries per node.
  public func getCapacity() : Nat64 {
    2 * Nat64.fromNat(Constants.B) - 1;
  };

};