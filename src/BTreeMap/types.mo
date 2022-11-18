
module {
  public type Node<K, V> = {
    #leaf: Leaf<K, V>;
    #internal: Internal<K, V>;
  };

  public type Data<K, V> = {
    kvs: [var ?(K, V)];
    var count: Nat;
  };

  public type Internal<K, V> = {
    data: Data<K, V>;
    children: [var ?Node<K, V>]
  };

  public type Leaf<K, V> = {
    data: Data<K, V>;
  };

  public type BTree<K, V> = {
    var root: Node<K, V>;
    order: Nat;
  };
}