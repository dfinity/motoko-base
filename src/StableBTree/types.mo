import Result "mo:base/Result";
import Buffer "mo:base/Buffer";

module {

  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  type Buffer<T> = Buffer.Buffer<T>;

  public type Address = Nat64;
  public type Bytes = Nat64;

  public type BytesConverter<T> = {
    fromBytes: ([Nat8]) -> T;
    toBytes: (T) -> [Nat8];
  };

  public type Memory = {
    size: () -> Nat64;
    grow: (Nat64) -> Int64;
    write: (Nat64, [Nat8]) -> ();
    read: (Nat64, Nat) -> [Nat8];
  };

  /// An indicator of the current position in the map.
  public type Cursor = {
    #Address: Address;
    #Node: { node: INode; next: Index; };
  };

  /// An index into a node's child or entry.
  public type Index = {
    #Child: Nat64;
    #Entry: Nat64;
  };

  public type IIter<K, V> = {
    next: () -> ?(K, V);
  };

  // Entries in the node are key-value pairs and both are blobs.
  public type Entry = ([Nat8], [Nat8]);

  public type NodeType = {
    #Leaf;
    #Internal;
  };

  public type INode = {
    getAddress: () -> Address;
    getEntries: () -> Buffer<Entry>;
    getChildren: () -> Buffer<Address>;
    getNodeType: () -> NodeType;
    getMaxKeySize: () -> Nat32;
    getMaxValueSize: () -> Nat32;
    save: (Memory) -> ();
    getMax: (Memory) -> Entry;
    getMin: (Memory) -> Entry;
    isFull: () -> Bool;
    swapEntry: (Nat, Entry) -> Entry;
    getKeyIdx: ([Nat8]) -> Result<Nat, Nat>;
    getChild: (Nat) -> Address;
    getEntry: (Nat) -> Entry;
    setChildren: (Buffer<Address>) -> ();
    setEntries: (Buffer<Entry>) -> ();
    setAddress: (Address) -> ();
    addChild: (Address) -> ();
    addEntry: (Entry) -> ();
    popEntry: () -> ?Entry;
    popChild: () -> ?Address;
    insertChild: (Nat, Address) -> ();
    insertEntry: (Nat, Entry) -> ();
    removeChild: (Nat) -> Address;
    removeEntry: (Nat) -> Entry;
    appendChildren: (Buffer<Address>) -> ();
    appendEntries: (Buffer<Entry>) -> ();
    entriesToText: () -> Text;
  };

  public type IAllocator = {
    getHeaderAddr: () -> Address;
    getAllocationSize: () -> Bytes;
    getNumAllocatedChunks: () -> Nat64;
    getFreeListHead: () -> Address;
    getMemory: () -> Memory;
    allocate: () ->  Address;
    deallocate: (Address) -> ();
    saveAllocator: () -> ();
    chunkSize: () -> Bytes;
  };

  public type InsertError = {
    #KeyTooLarge : { given : Nat; max : Nat; };
    #ValueTooLarge : { given : Nat; max : Nat; };
  };

  public type IBTreeMap<K, V> = {
    getRootAddr : () -> Address;
    getMaxKeySize : () -> Nat32;
    getMaxValueSize : () -> Nat32;
    getKeyConverter : () -> BytesConverter<K>;
    getValueConverter : () -> BytesConverter<V>;
    getAllocator : () -> IAllocator;
    getLength : () -> Nat64;
    getMemory : () -> Memory;
    insert : (k: K, v: V) -> Result<?V, InsertError>;
    get : (key: K) -> ?V;
    containsKey : (key: K) -> Bool;
    isEmpty : () -> Bool;
    remove : (key: K) -> ?V;
    iter : () -> IIter<K, V>;
    loadNode : (address: Address) -> INode;
  };

};