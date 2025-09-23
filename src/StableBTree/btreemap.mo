import Types "types";
import Allocator "allocator";
import Conversion "conversion";
import Node "node";
import Constants "constants";
import Iter "iter";
import Utils "utils";
import Memory "memory";

import Result "mo:base/Result";
import Option "mo:base/Option";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Order "mo:base/Order";
import Buffer "mo:base/Buffer";
import Nat8 "mo:base/Nat8";

module {

  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  // For convenience: from types module
  type Address = Types.Address;
  type Memory = Types.Memory;
  type BytesConverter<T> = Types.BytesConverter<T>;
  type InsertError = Types.InsertError;
  type NodeType = Types.NodeType;
  type Entry = Types.Entry;
  type Cursor = Types.Cursor;
  // For convenience: from node module
  type Node = Node.Node;
  // For convenience: from iter module
  type Iter<K, V> = Iter.Iter<K, V>;
  // For convenience: from allocator module
  type Allocator = Allocator.Allocator;

  let LAYOUT_VERSION : Nat8 = 1;
  let MAGIC = "BTR";

  /// Initializes a `BTreeMap`.
  ///
  /// If the memory provided already contains a `BTreeMap`, then that
  /// map is loaded. Otherwise, a new `BTreeMap` instance is created.
  public func init<K, V>(
    memory : Memory,
    max_key_size : Nat32,
    max_value_size : Nat32,
    key_converter: BytesConverter<K>,
    value_converter: BytesConverter<V>
  ) : BTreeMap<K, V> {
    if (memory.size() == 0) {
      // Memory is empty. Create a new map.
      return new(memory, max_key_size, max_value_size, key_converter, value_converter);
    };

    // Check if the magic in the memory corresponds to a BTreeMap.
    let dst = Memory.read(memory, 0, 3);
    if (dst != Blob.toArray(Text.encodeUtf8(MAGIC))) {
      // No BTreeMap found. Create a new instance.
      return new(memory, max_key_size, max_value_size, key_converter, value_converter);
    };
    
    // The memory already contains a BTreeMap. Load it.
    return load(memory, key_converter, value_converter);
  };

  /// Creates a new instance a `BTreeMap`.
  ///
  /// The given `memory` is assumed to be exclusively reserved for this data
  /// structure and that it starts at address zero. Typically `memory` will
  /// be an instance of `RestrictedMemory`.
  ///
  /// When initialized, the data structure has the following memory layout:
  ///
  ///    |  BTreeHeader  |  Allocator | ... free memory for nodes |
  ///
  /// See `Allocator` for more details on its own memory layout.
  public func new<K, V>(    
    memory : Memory,
    max_key_size : Nat32,
    max_value_size : Nat32,
    key_converter: BytesConverter<K>,
    value_converter: BytesConverter<V>
  ) : BTreeMap<K, V> {
    // Because we assume that we have exclusive access to the memory,
    // we can store the `BTreeHeader` at address zero, and the allocator is
    // stored directly after the `BTreeHeader`.
    let allocator_addr = Constants.ADDRESS_0 + B_TREE_HEADER_SIZE;
    let btree = BTreeMap({
      root_addr = Constants.NULL;
      max_key_size = max_key_size;
      max_value_size = max_value_size;
      key_converter = key_converter;
      value_converter = value_converter;
      allocator = Allocator.initAllocator(memory, allocator_addr, Node.size(max_key_size, max_value_size));
      length : Nat64 = 0;
      memory = memory;
    });

    btree.save();

    btree;
  };

  /// Loads the map from memory.
  public func load<K, V>(
    memory : Memory,
    key_converter: BytesConverter<K>,
    value_converter: BytesConverter<V>
  ) : BTreeMap<K, V> {
    // Read the header from memory.
    let header = loadBTreeHeader(Constants.NULL, memory);
    let allocator_addr = Constants.ADDRESS_0 + B_TREE_HEADER_SIZE;

    BTreeMap({
      root_addr = header.root_addr;
      max_key_size = header.max_key_size;
      max_value_size = header.max_value_size;
      key_converter = key_converter;
      value_converter = value_converter;
      allocator = Allocator.loadAllocator(memory, allocator_addr);
      length = header.length;
      memory = memory;
    });
  };

  let B_TREE_HEADER_SIZE : Nat64 = 52;

  type BTreeHeader = {
    magic: [Nat8]; // 3 bytes
    version: Nat8;
    max_key_size: Nat32;
    max_value_size: Nat32;
    root_addr: Address;
    length: Nat64;
    // Additional space reserved to add new fields without breaking backward-compatibility.
    _buffer: [Nat8]; // 24 bytes
  };

  func saveBTreeHeader(header: BTreeHeader, addr: Address, memory: Memory) {
    Memory.write(memory, addr                        ,                                   header.magic);
    Memory.write(memory, addr + 3                    ,                               [header.version]);
    Memory.write(memory, addr + 3 + 1                ,   Conversion.nat32ToBytes(header.max_key_size));
    Memory.write(memory, addr + 3 + 1 + 4            , Conversion.nat32ToBytes(header.max_value_size));
    Memory.write(memory, addr + 3 + 1 + 4 + 4        ,      Conversion.nat64ToBytes(header.root_addr));
    Memory.write(memory, addr + 3 + 1 + 4 + 4 + 8    ,         Conversion.nat64ToBytes(header.length));
    Memory.write(memory, addr + 3 + 1 + 4 + 4 + 8 + 8,                                 header._buffer);
  };

  func loadBTreeHeader(addr: Address, memory: Memory) : BTreeHeader {
    let header = {
      magic =                                  Memory.read(memory, addr                        , 3);
      version =                                Memory.read(memory, addr + 3                    , 1)[0];
      max_key_size =   Conversion.bytesToNat32(Memory.read(memory, addr + 3 + 1                , 4));
      max_value_size = Conversion.bytesToNat32(Memory.read(memory, addr + 3 + 1 + 4            , 4));
      root_addr =      Conversion.bytesToNat64(Memory.read(memory, addr + 3 + 1 + 4 + 4        , 8));
      length =         Conversion.bytesToNat64(Memory.read(memory, addr + 3 + 1 + 4 + 4 + 8    , 8));
      _buffer =                                Memory.read(memory, addr + 3 + 1 + 4 + 4 + 8 + 8, 24);
    };
    if (header.magic != Blob.toArray(Text.encodeUtf8(MAGIC))) { Debug.trap("Bad magic."); };
    if (header.version != LAYOUT_VERSION)                     { Debug.trap("Unsupported version."); };
    
    header;
  };

  type BTreeMapMembers<K, V> = {
    root_addr : Address;
    max_key_size : Nat32;
    max_value_size : Nat32;
    key_converter: BytesConverter<K>;
    value_converter: BytesConverter<V>;
    allocator : Allocator;
    length : Nat64;
    memory : Memory;
  };

  public class BTreeMap<K, V>(members: BTreeMapMembers<K, V>) = self {
    
    /// Members
    // The address of the root node. If a root node doesn't exist, the address is set to NULL.
    var root_addr_ : Address = members.root_addr;
    // The maximum size a key can have.
    let max_key_size_ : Nat32 = members.max_key_size;
    // The maximum size a value can have.
    let max_value_size_ : Nat32 = members.max_value_size;
    /// To convert the key into/from bytes.
    let key_converter_ : BytesConverter<K> = members.key_converter;
    /// To convert the value into/from bytes.
    let value_converter_ : BytesConverter<V> = members.value_converter;
    // An allocator used for managing memory and allocating nodes.
    let allocator_ : Allocator = members.allocator;
    // The number of elements in the map.
    var length_ : Nat64 = members.length;
    /// The memory used to load/save the map.
    let memory_ : Memory = members.memory;

    /// Getters
    public func getRootAddr() : Address { root_addr_; };
    public func getMaxKeySize() : Nat32 { max_key_size_; };
    public func getMaxValueSize() : Nat32 { max_value_size_; };
    public func getKeyConverter() : BytesConverter<K> { key_converter_; };
    public func getValueConverter() : BytesConverter<V> { value_converter_; };
    public func getAllocator() : Allocator { allocator_; };
    public func getLength() : Nat64 { length_; };
    public func getMemory() : Memory { memory_; };

    /// Inserts a key-value pair into the map.
    ///
    /// The previous value of the key, if present, is returned.
    ///
    /// The size of the key/value must be <= the max key/value sizes configured
    /// for the map. Otherwise, an `InsertError` is returned.
    public func insert(k: K, v: V) : Result<?V, InsertError> {
      let key = key_converter_.toBytes(k);
      let value = value_converter_.toBytes(v);

      // Verify the size of the key.
      if (key.size() > Nat32.toNat(max_key_size_)) {
        return #err(#KeyTooLarge {
          given = key.size();
          max = Nat32.toNat(max_key_size_);
        });
      };

      // Verify the size of the value.
      if (value.size() > Nat32.toNat(max_value_size_)) {
        return #err(#ValueTooLarge {
          given = value.size();
          max = Nat32.toNat(max_value_size_);
        });
      };

      let root = do {
        if (root_addr_ == Constants.NULL) {
          // No root present. Allocate one.
          let node = allocateNode(#Leaf);
          root_addr_ := node.getAddress();
          save();
          node;
        } else {
          // Load the root from memory.
          var root = loadNode(root_addr_);

          // Check if the key already exists in the root.
          switch(root.getKeyIdx(key)) {
            case(#ok(idx)){
              // The key exists. Overwrite it and return the previous value.
              let (_, previous_value) = root.swapEntry(idx, (key, value));
              root.save(memory_);
              return #ok(?(value_converter_.fromBytes(previous_value)));
            };
            case(#err(_)){
              // If the root is full, we need to introduce a new node as the root.
              //
              // NOTE: In the case where we are overwriting an existing key, then introducing
              // a new root node isn't strictly necessary. However, that's a micro-optimization
              // that adds more complexity than it's worth.
              if (root.isFull()) {
                // The root is full. Allocate a new node that will be used as the new root.
                var new_root = allocateNode(#Internal);
      
                // The new root has the old root as its only child.
                new_root.addChild(root_addr_);
      
                // Update the root address.
                root_addr_ := new_root.getAddress();
                save();
      
                // Split the old (full) root. 
                splitChild(new_root, 0);
      
                new_root;
              } else {
                root;
              };
            };
          };
        };
      };
      #ok(Option.map<[Nat8], V>(
        insertNonFull(root, key, value),
        func(bytes: [Nat8]) : V { value_converter_.fromBytes(bytes); })
      );
    };

    // Inserts an entry into a node that is *not full*.
    func insertNonFull(node: Node, key: [Nat8], value: [Nat8]) : ?[Nat8] {
      // We're guaranteed by the caller that the provided node is not full.
      assert(not node.isFull());

      // Look for the key in the node.
      switch(node.getKeyIdx(key)){
        case(#ok(idx)){
          // The key is already in the node.
          // Overwrite it and return the previous value.
          let (_, previous_value) = node.swapEntry(idx, (key, value));

          node.save(memory_);
          return ?previous_value;
        };
        case(#err(idx)){
          // The key isn't in the node. `idx` is where that key should be inserted.

          switch(node.getNodeType()) {
            case(#Leaf){
              // The node is a non-full leaf.
              // Insert the entry at the proper location.
              node.insertEntry(idx, (key, value));
              
              node.save(memory_);

              // Update the length.
              length_ += 1;
              save();

              // No previous value to return.
              return null;
            };
            case(#Internal){
              // The node is an internal node.
              // Load the child that we should add the entry to.
              var child = loadNode(node.getChild(idx));

              if (child.isFull()) {
                // Check if the key already exists in the child.
                switch(child.getKeyIdx(key)) {
                  case(#ok(idx)){
                    // The key exists. Overwrite it and return the previous value.
                    let (_, previous_value) = child.swapEntry(idx, (key, value));

                    child.save(memory_);
                    return ?previous_value;
                  };
                  case(#err(_)){
                    // The child is full. Split the child.
                    splitChild(node, idx);

                    // The children have now changed. Search again for
                    // the child where we need to store the entry in.
                    let index = switch(node.getKeyIdx(key)){
                      case(#ok(i))  { i; };
                      case(#err(i)) { i; };
                    };

                    child := loadNode(node.getChild(index));
                  };
                };
              };

              // The child should now be not full.
              assert(not child.isFull());

              insertNonFull(child, key, value);
            };
          };
        };
      };
    };

    // Takes as input a nonfull internal `node` and index to its full child, then
    // splits this child into two, adding an additional child to `node`.
    //
    // Example:
    //
    //                          [ ... M   Y ... ]
    //                                  |
    //                 [ N  O  P  Q  R  S  T  U  V  W  X ]
    //
    //
    // After splitting becomes:
    //
    //                         [ ... M  S  Y ... ]
    //                                 / \
    //                [ N  O  P  Q  R ]   [ T  U  V  W  X ]
    //
    func splitChild(node: Node, full_child_idx: Nat) {
      // The node must not be full.
      assert(not node.isFull());

      // The node's child must be full.
      var full_child = loadNode(node.getChild(full_child_idx));
      assert(full_child.isFull());

      // Create a sibling to this full child (which has to be the same type).
      var sibling = allocateNode(full_child.getNodeType());
      assert(sibling.getNodeType() == full_child.getNodeType());

      // Move the values above the median into the new sibling.
      sibling.setEntries(Utils.splitOff<Entry>(full_child.getEntries(), Constants.B));

      if (full_child.getNodeType() == #Internal) {
        sibling.setChildren(Utils.splitOff<Address>(full_child.getChildren(), Constants.B));
      };

      // Add sibling as a new child in the node. 
      node.insertChild(full_child_idx + 1, sibling.getAddress());

      // Move the median entry into the node.
      switch(full_child.popEntry()){
        case(null){
          Debug.trap("A full child cannot be empty");
        };
        case(?median_entry){
          node.insertEntry(full_child_idx, median_entry);
          sibling.save(memory_);
          full_child.save(memory_);
          node.save(memory_);
        };
      };
    };

    /// Returns the value associated with the given key if it exists.
    public func get(key: K) : ?V {
      if (root_addr_ == Constants.NULL) {
        return null;
      };
      Option.map<[Nat8], V>(
        getHelper(root_addr_, key_converter_.toBytes(key)),
        func(bytes: [Nat8]) : V { value_converter_.fromBytes(bytes); }
      );
    };

    func getHelper(node_addr: Address, key: [Nat8]) : ?[Nat8] {
      let node = loadNode(node_addr);
      switch(node.getKeyIdx(key)){
        case(#ok(idx)) { ?node.getEntry(idx).1; };
        case(#err(idx)) {
          switch(node.getNodeType()) {
            case(#Leaf) { null; }; // Key not found.
            case(#Internal) {
              // The key isn't in the node. Look for the key in the child.
              getHelper(node.getChild(idx), key);
            };
          };
        };
      };
    };

    /// Returns `true` if the key exists in the map, `false` otherwise.
    public func containsKey(key: K) : Bool {
      Option.isSome(get(key));
    };

    /// Returns `true` if the map contains no elements.
    public func isEmpty() : Bool {
      (length_ == 0);
    };

    /// Removes a key from the map, returning the previous value at the key if it exists.
    public func remove(key: K) : ?V {
      if (root_addr_ == Constants.NULL) {
        return null;
      };
      Option.map<[Nat8], V>(
        removeHelper(root_addr_, key_converter_.toBytes(key)),
        func(bytes: [Nat8]) : V { value_converter_.fromBytes(bytes); }
      );
    };

    // A helper method for recursively removing a key from the B-tree.
    func removeHelper(node_addr: Address, key: [Nat8]) : ?[Nat8] {
      var node = loadNode(node_addr);

      if(node.getAddress() != root_addr_){
        // We're guaranteed that whenever this method is called the number
        // of keys is >= `B`. Note that this is higher than the minimum required
        // in a node, which is `B - 1`, and that's because this strengthened
        // condition allows us to delete an entry in a single pass most of the
        // time without having to back up.
        assert(node.getEntries().size() >= Constants.B);
      };

      switch(node.getNodeType()) {
        case(#Leaf) {
          switch(node.getKeyIdx(key)){
            case(#ok(idx)) {
              // Case 1: The node is a leaf node and the key exists in it.
              // This is the simplest case. The key is removed from the leaf.
              let value = node.removeEntry(idx).1;
              length_ -= 1;

              if (node.getEntries().size() == 0) {
                if (node.getAddress() != root_addr_) {
                  Debug.trap("Removal can only result in an empty leaf node if that node is the root");
                };

                // Deallocate the empty node.
                allocator_.deallocate(node.getAddress());
                root_addr_ := Constants.NULL;
              } else {
                node.save(memory_);
              };

              save();
              ?value;
            };
            case(_) { null; }; // Key not found.
          };
        };
        case(#Internal) {
          switch(node.getKeyIdx(key)){
            case(#ok(idx)) {
              // Case 2: The node is an internal node and the key exists in it.

              // Check if the child that precedes `key` has at least `B` keys.
              let left_child = loadNode(node.getChild(idx));
              if (left_child.getEntries().size() >= Constants.B) {
                // Case 2.a: The node's left child has >= `B` keys.
                //
                //             parent
                //          [..., key, ...]
                //             /   \
                //      [left child]   [...]
                //       /      \
                //    [...]     [..., key predecessor]
                //
                // In this case, we replace `key` with the key's predecessor from the
                // left child's subtree, then we recursively delete the key's
                // predecessor for the following end result:
                //
                //             parent
                //      [..., key predecessor, ...]
                //             /   \
                //      [left child]   [...]
                //       /      \
                //    [...]      [...]

                // Recursively delete the predecessor.
                // TODO(EXC-1034): Do this in a single pass.
                let predecessor = left_child.getMax(memory_);
                ignore removeHelper(node.getChild(idx), predecessor.0);

                // Replace the `key` with its predecessor.
                let (_, old_value) = node.swapEntry(idx, predecessor);

                // Save the parent node.
                node.save(memory_);
                return ?old_value;
              };

              // Check if the child that succeeds `key` has at least `B` keys.
              let right_child = loadNode(node.getChild(idx + 1));
              if (right_child.getEntries().size() >= Constants.B) {
                // Case 2.b: The node's right child has >= `B` keys.
                //
                //             parent
                //          [..., key, ...]
                //             /   \
                //           [...]   [right child]
                //              /       \
                //        [key successor, ...]   [...]
                //
                // In this case, we replace `key` with the key's successor from the
                // right child's subtree, then we recursively delete the key's
                // successor for the following end result:
                //
                //             parent
                //      [..., key successor, ...]
                //             /   \
                //          [...]   [right child]
                //               /      \
                //            [...]      [...]

                // Recursively delete the successor.
                // TODO(EXC-1034): Do this in a single pass.
                let successor = right_child.getMin(memory_);
                ignore removeHelper(node.getChild(idx + 1), successor.0);

                // Replace the `key` with its successor.
                let (_, old_value) = node.swapEntry(idx, successor);

                // Save the parent node.
                node.save(memory_);
                return ?old_value;
              };

              // Case 2.c: Both the left child and right child have B - 1 keys.
              //
              //             parent
              //          [..., key, ...]
              //             /   \
              //      [left child]   [right child]
              //
              // In this case, we merge (left child, key, right child) into a single
              // node of size 2B - 1. The result will look like this:
              //
              //             parent
              //           [...  ...]
              //             |
              //      [left child, `key`, right child] <= new child
              //
              // We then recurse on this new child to delete `key`.
              //
              // If `parent` becomes empty (which can only happen if it's the root),
              // then `parent` is deleted and `new_child` becomes the new root.
              let num_keys : Int = Constants.B - 1;
              assert(left_child.getEntries().size() == num_keys);
              assert(right_child.getEntries().size() == num_keys);

              // Merge the right child into the left child.
              let new_child = merge(right_child, left_child, node.removeEntry(idx));

              // Remove the right child from the parent node.
              ignore node.removeChild(idx + 1);

              if (node.getEntries().size() == 0) {
                // Can only happen if this node is root.
                assert(node.getAddress() == root_addr_);
                assert(node.getChildren().toArray() == [new_child.getAddress()]);

                root_addr_ := new_child.getAddress();

                // Deallocate the root node.
                allocator_.deallocate(node.getAddress());
                save();
              };

              node.save(memory_);
              new_child.save(memory_);

              // Recursively delete the key.
              removeHelper(new_child.getAddress(), key);
            };
            case(#err(idx)) {
              // Case 3: The node is an internal node and the key does NOT exist in it.

              // If the key does exist in the tree, it will exist in the subtree at index
              // `idx`.
              var child = loadNode(node.getChild(idx));

              if (child.getEntries().size() >= Constants.B) {
                // The child has enough nodes. Recurse to delete the `key` from the
                // `child`.
                return removeHelper(node.getChild(idx), key);
              };

              // The child has < `B` keys. Let's see if it has a sibling with >= `B` keys.
              var left_sibling = do {
                if (idx > 0) {
                  ?loadNode(node.getChild(idx- 1));
                } else {
                  null;
                };
              };

              var right_sibling = do {
                if (idx + 1 < node.getChildren().size()) {
                  ?loadNode(node.getChild(idx + 1));
                } else {
                  null;
                };
              };

              switch(left_sibling){
                case(null){};
                case(?left_sibling){
                  if (left_sibling.getEntries().size() >= Constants.B) {
                    // Case 3.a (left): The child has a left sibling with >= `B` keys.
                    //
                    //              [d] (parent)
                    //               /   \
                    //  (left sibling) [a, b, c]   [e, f] (child)
                    //             \
                    //             [c']
                    //
                    // In this case, we move a key down from the parent into the child
                    // and move a key from the left sibling up into the parent
                    // resulting in the following tree:
                    //
                    //              [c] (parent)
                    //               /   \
                    //     (left sibling) [a, b]   [d, e, f] (child)
                    //                /
                    //              [c']
                    //
                    // We then recurse to delete the key from the child.

                    // Remove the last entry from the left sibling.
                    switch(left_sibling.popEntry()){
                      // We tested before that the entries size is not zero, this should never happen.
                      case(null) { Debug.trap("The left sibling entries must not be empty."); };
                      case(?(left_sibling_key, left_sibling_value)){

                        // Replace the parent's entry with the one from the left sibling.
                        let (parent_key, parent_value) = node
                          .swapEntry(idx - 1, (left_sibling_key, left_sibling_value));

                        // Move the entry from the parent into the child.
                        child.insertEntry(0, (parent_key, parent_value));

                        // Move the last child from left sibling into child.
                        switch(left_sibling.popChild()) {
                          case(?last_child){
                            assert(left_sibling.getNodeType() == #Internal);
                            assert(child.getNodeType() == #Internal);

                            child.insertChild(0, last_child);
                          };
                          case(null){
                            assert(left_sibling.getNodeType() == #Leaf);
                            assert(child.getNodeType() == #Leaf);
                          };
                        };

                        left_sibling.save(memory_);
                        child.save(memory_);
                        node.save(memory_);
                        return removeHelper(child.getAddress(), key);
                      };
                    };
                  };
                };
              };

              switch(right_sibling){
                case(null){};
                case(?right_sibling){
                  if (right_sibling.getEntries().size() >= Constants.B) {
                    // Case 3.a (right): The child has a right sibling with >= `B` keys.
                    //
                    //              [c] (parent)
                    //               /   \
                    //       (child) [a, b]   [d, e, f] (left sibling)
                    //                 /
                    //              [d']
                    //
                    // In this case, we move a key down from the parent into the child
                    // and move a key from the right sibling up into the parent
                    // resulting in the following tree:
                    //
                    //              [d] (parent)
                    //               /   \
                    //      (child) [a, b, c]   [e, f] (right sibling)
                    //              \
                    //               [d']
                    //
                    // We then recurse to delete the key from the child.

                    // Remove the first entry from the right sibling.
                    let (right_sibling_key, right_sibling_value) =
                      right_sibling.removeEntry(0);

                    // Replace the parent's entry with the one from the right sibling.
                    let parent_entry =
                      node.swapEntry(idx, (right_sibling_key, right_sibling_value));

                    // Move the entry from the parent into the child.
                    child.addEntry(parent_entry);

                    // Move the first child of right_sibling into `child`.
                    switch(right_sibling.getNodeType()) {
                      case(#Internal) {
                        assert(child.getNodeType() == #Internal);
                        child.addChild(right_sibling.removeChild(0));
                      };
                      case(#Leaf) {
                        assert(child.getNodeType() == #Leaf);
                      };
                    };

                    right_sibling.save(memory_);
                    child.save(memory_);
                    node.save(memory_);
                    return removeHelper(child.getAddress(), key);
                  };
                };
              };

              // Case 3.b: neither siblings of the child have >= `B` keys.

              switch(left_sibling){
                case(null){};
                case(?left_sibling){
                  // Merge child into left sibling if it exists.

                  let left_sibling_address = left_sibling.getAddress();
                  ignore merge(child, left_sibling, node.removeEntry(idx - 1));
                  // Removing child from parent.
                  ignore node.removeChild(idx);

                  if (node.getEntries().size() == 0) {
                    allocator_.deallocate(node.getAddress());

                    if (node.getAddress() == root_addr_) {
                      // Update the root.
                      root_addr_ := left_sibling_address;
                      save();
                    };
                  } else {
                    node.save(memory_);
                  };

                  return removeHelper(left_sibling_address, key);
                };
              };

              switch(right_sibling){
                case(null){};
                case(?right_sibling){
                  // Merge child into right sibling.

                  let right_sibling_address = right_sibling.getAddress();
                  ignore merge(child, right_sibling, node.removeEntry(idx));

                  // Removing child from parent.
                  ignore node.removeChild(idx);

                  if (node.getEntries().size() == 0) {
                    allocator_.deallocate(node.getAddress());

                    if (node.getAddress() == root_addr_) {
                      // Update the root.
                      root_addr_ := right_sibling_address;
                      save();
                    };
                  } else {
                    node.save(memory_);
                  };

                  return removeHelper(right_sibling_address, key);
                };
              };

              Debug.trap("At least one of the siblings must exist.");
            };
          };
        };
      };
    };

    // Returns an iterator over the entries of the map, sorted by key.
    public func iter() : Iter<K, V> {
      Iter.new(self);
    };

    /// Returns an iterator over the entries in the map where keys begin with the given `prefix`.
    /// If the optional `offset` is set, the iterator returned will start from the entry that
    /// contains this `offset` (while still iterating over all remaining entries that begin
    /// with the given `prefix`).
    public func range(prefix: [Nat8], offset: ?[Nat8]) : Iter<K, V> {
      if (root_addr_ == Constants.NULL) {
        // Map is empty.
        return Iter.empty(self);
      };

      var node = loadNode(root_addr_);
      let cursors : Buffer.Buffer<Cursor> = Buffer.Buffer<Cursor>(0);

      loop {
        // Look for the prefix in the node.
        let pivot = Utils.toBuffer<Nat8>(prefix);
        switch(offset) {
          case(null) {};
          case(?offset){
            pivot.append(Utils.toBuffer(offset));
          };
        };
        let idx = switch(node.getKeyIdx(pivot.toArray())){
          case(#err(idx)) { idx; };
          case(#ok(idx)) { idx; };
        };

        // If `prefix` is a key in the node, then `idx` would return its
        // location. Otherwise, `idx` is the location of the next key in
        // lexicographical order.

        // Load the next child of the node to visit if it exists.
        // This is done first to avoid cloning the node.
        let child = switch(node.getNodeType()) {
          case(#Internal) {
            // Note that loading a child node cannot fail since
            // len(children) = len(entries) + 1
            ?loadNode(node.getChild(idx));
          };
          case(#Leaf) { null; };
        };

        // If the prefix is found in the node, then add a cursor starting from its index.
        if (idx < node.getEntries().size() and Utils.isPrefixOf(prefix, node.getEntry(idx).0, Nat8.equal)){
          cursors.add(#Node {
            node;
            next = #Entry(Nat64.fromNat(idx));
          });
        };

        switch(child) {
          case(null) {
            // Leaf node. Return an iterator with the found cursors.
            switch(offset) {
              case(?offset) {
                return Iter.newWithPrefixAndOffset(
                  self, prefix, offset, cursors.toArray()
                );
              };
              case(null) {
                return Iter.newWithPrefix(self, prefix, cursors.toArray());
              };
            };
          };
          case(?child) {
            // Iterate over the child node.
            node := child;
          };
        };
      };
    };

    // Merges one node (`source`) into another (`into`), along with a median entry.
    //
    // Example (values are not included for brevity):
    //
    // Input:
    //   Source: [1, 2, 3]
    //   Into: [5, 6, 7]
    //   Median: 4
    //
    // Output:
    //   [1, 2, 3, 4, 5, 6, 7] (stored in the `into` node)
    //   `source` is deallocated.
    func merge(source: Node, into: Node, median: Entry) : Node {
      assert(source.getNodeType() == into.getNodeType());
      assert(source.getEntries().size() != 0);
      assert(into.getEntries().size() != 0);

      let into_address = into.getAddress();
      let source_address = source.getAddress();

      // Figure out which node contains lower values than the other.
      let (lower, higher) = do {
        if (Order.isLess(Node.compareEntryKeys(source.getEntry(0).0, into.getEntry(0).0))){
          (source, into);
        } else {
          (into, source);
        };
      };

      lower.addEntry(median);

      lower.appendEntries(higher.getEntries());

      lower.setAddress(into_address);

      // Move the children (if any exist).
      lower.appendChildren(higher.getChildren());

      lower.save(memory_);

      allocator_.deallocate(source_address);
      lower;
    };

    func allocateNode(node_type: NodeType) : Node {
      Node.Node({
        address = allocator_.allocate();
        entries = [];
        children = [];
        node_type;
        max_key_size = max_key_size_;
        max_value_size = max_value_size_;
      });
    };

    public func loadNode(address: Address) : Node {
      Node.load(address, memory_, max_key_size_, max_value_size_);
    };

    // Saves the map to memory.
    public func save() {
      let header : BTreeHeader = {
        magic = Blob.toArray(Text.encodeUtf8(MAGIC));
        version = LAYOUT_VERSION;
        root_addr = root_addr_;
        max_key_size = max_key_size_;
        max_value_size = max_value_size_;
        length = length_;
        _buffer = Array.freeze<Nat8>(Array.init<Nat8>(24, 0));
      };

      saveBTreeHeader(header, Constants.ADDRESS_0, memory_);
    };

  };

};