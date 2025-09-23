import StableBTree "../../../src/btreemap";
import StableBTreeTypes "../../../src/types";
import Conversion "../../../src/conversion";
import Memory "../../../src/memory";
import MemoryManager "../../../src/memoryManager";

import Result "mo:base/Result";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import TrieSet "mo:base/TrieSet";
import Trie "mo:base/Trie";

actor class MultipleBTrees(args: {
  max_key_size: Nat32;
  max_value_size: Nat32;
}) {
  
  // For convenience: from StableBTree types
  type Address = StableBTreeTypes.Address;
  type BytesConverter<T> = StableBTreeTypes.BytesConverter<T>;
  type Memory = StableBTreeTypes.Memory;
  type InsertError = StableBTreeTypes.InsertError;
  type MemoryId = MemoryManager.MemoryId;
  
  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  type Set<K> = TrieSet.Set<K>;

  // Arbitrary use of (Nat32, Text) for (key, value) types
  type K = Nat32;
  type V = Text;

  let nat32_converter_ = {
    fromBytes = func(bytes: [Nat8]) : Nat32 { Conversion.bytesToNat32(bytes); };
    toBytes = func(nat32: Nat32) : [Nat8] { Conversion.nat32ToBytes(nat32); };
  };

  let text_converter_ = {
    fromBytes = func(bytes: [Nat8]) : Text { Conversion.bytesToText(bytes); };
    toBytes = func(text: Text) : [Nat8] { Conversion.textToBytes(text); };
  };

  // The memory manager
  let memory_manager_ = MemoryManager.init(Memory.STABLE_MEMORY);

  // The BTreeMap identifiers
  var identifiers_ = TrieSet.empty<MemoryId>();

  // Get or create the BTreeMap identified with the btree_id
  func getBTreeMap(btree_id: MemoryId) : StableBTree.BTreeMap<K, V> {
    let memory = memory_manager_.get(btree_id);
    switch(Trie.get(identifiers_, { key = btree_id; hash = Nat32.fromNat(Nat8.toNat(btree_id)); }, Nat8.equal)){
      case(null){
        identifiers_ := TrieSet.put(identifiers_, btree_id, Nat32.fromNat(Nat8.toNat(btree_id)), Nat8.equal);
        StableBTree.init<K, V>(memory, args.max_key_size, args.max_value_size, nat32_converter_, text_converter_);
      };
      case(_){
        StableBTree.load<K, V>(memory, nat32_converter_, text_converter_);
      };
    };
  };

  public func getLength(btree_id: MemoryId) : async Nat64 {
    let btreemap = getBTreeMap(btree_id);
    btreemap.getLength();
  };

  public func insert(btree_id: MemoryId, key: K, value: V) : async Result<?V, InsertError> {
    let btreemap = getBTreeMap(btree_id);
    btreemap.insert(key, value);
  };

  public func get(btree_id: MemoryId, key: K) : async ?V {
    let btreemap = getBTreeMap(btree_id);
    btreemap.get(key);
  };

  public func containsKey(btree_id: MemoryId, key: K) : async Bool {
    let btreemap = getBTreeMap(btree_id);
    btreemap.containsKey(key);
  };

  public func isEmpty(btree_id: MemoryId) : async Bool {
    let btreemap = getBTreeMap(btree_id);
    btreemap.isEmpty();
  };

  public func remove(btree_id: MemoryId, key: K) : async ?V {
    let btreemap = getBTreeMap(btree_id);
    getBTreeMap(btree_id).remove(key);
  };

  public func insertMany(btree_id: MemoryId, entries: [(K, V)]) : async Result<(), [InsertError]> {
    let btreemap = getBTreeMap(btree_id);
    let buffer = Buffer.Buffer<InsertError>(0);
    for ((key, value) in Array.vals(entries)){
      switch(btreemap.insert(key, value)){
        case(#err(insert_error)) { buffer.add(insert_error); };
        case(_) {};
      };
    };
    if (buffer.size() > 0){
      #err(buffer.toArray());
    } else {
      #ok;
    };
  };

  public func getMany(btree_id: MemoryId, keys: [K]) : async [V] {
    let btreemap = getBTreeMap(btree_id);
    let buffer = Buffer.Buffer<V>(0);
    for (key in Array.vals(keys)){
      switch(btreemap.get(key)){
        case(?value) { buffer.add(value); };
        case(null) {};
      };
    };
    buffer.toArray();
  };

  public func containsKeys(btree_id: MemoryId, keys: [K]) : async Bool {
    let btreemap = getBTreeMap(btree_id);
    for (key in Array.vals(keys)){
      if (not btreemap.containsKey(key)) {
        return false;
      };
    };
    return true;
  };

  public func removeMany(btree_id: MemoryId, keys: [K]) : async [V] {
    let btreemap = getBTreeMap(btree_id);
    let buffer = Buffer.Buffer<V>(0);
    for (key in Array.vals(keys)){
      switch(btreemap.remove(key)){
        case(?value) { buffer.add(value); };
        case(null) {};
      };
    };
    buffer.toArray();
  };

  public func empty(btree_id: MemoryId) : async () {
    let btreemap = getBTreeMap(btree_id);
    let entries = Iter.toArray(btreemap.iter());
    for ((key, _) in Array.vals(entries)){
      ignore btreemap.remove(key);
    };
  };

};
