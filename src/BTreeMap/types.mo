import Result "mo:base/Result";
import Buffer "mo:base/Buffer";

module {

  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  type Buffer<T> = Buffer.Buffer<T>;

  public type BytesConverter<T> = {
    fromBytes: ([Nat8]) -> T;
    toBytes: (T) -> [Nat8];
  };

  /// An indicator of the current position in the map.
  public type Cursor = {
    node: INode;
    next: Index;
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
    getEntries: () -> Buffer<Entry>;
    getChildren: () -> Buffer<INode>;
    getNodeType: () -> NodeType;
    getIdentifier: () -> Nat64;
    getMax: () -> Entry;
    getMin: () -> Entry;
    isFull: () -> Bool;
    swapEntry: (Nat, Entry) -> Entry;
    getKeyIdx: ([Nat8]) -> Result<Nat, Nat>;
    getChild: (Nat) -> INode;
    getEntry: (Nat) -> Entry;
    getChildrenIdentifiers : () -> [Nat64];
    setChildren: (Buffer<INode>) -> ();
    setEntries: (Buffer<Entry>) -> ();
    setChild: (Nat, INode) -> ();
    addChild: (INode) -> ();
    addEntry: (Entry) -> ();
    popEntry: () -> ?Entry;
    popChild: () -> ?INode;
    insertChild: (Nat, INode) -> ();
    insertEntry: (Nat, Entry) -> ();
    removeChild: (Nat) -> INode;
    removeEntry: (Nat) -> Entry;
    appendChildren: (Buffer<INode>) -> ();
    appendEntries: (Buffer<Entry>) -> ();
    entriesToText: () -> Text;
  };

  public type IBTreeMap<K, V> = {
    getRootNode : () -> INode;
    getKeyConverter : () -> BytesConverter<K>;
    getValueConverter : () -> BytesConverter<V>;
    getLength : () -> Nat64;
    insert : (k: K, v: V) -> ?V;
    get : (key: K) -> ?V;
    containsKey : (key: K) -> Bool;
    isEmpty : () -> Bool;
    remove : (key: K) -> ?V;
    iter : () -> IIter<K, V>;
    range : ([Nat8], ?[Nat8]) -> IIter<K, V>;
  };

};