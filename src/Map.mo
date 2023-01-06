import TrieMap "TrieMap";
import Order "Order";
import Hash "Hash";
import Nat "Nat";

class Map<Key, Value>(
  utilities : module {
    compare : (Key, Key) -> Order.Order;
    hash : Key -> Hash.Hash
  }
) {
  // Pulling out utility functions
  let compare = utilities.compare;
  let hash = utilities.hash;
  func equal(key1 : Key, key2 : Key) : Bool {
    switch (compare(key1, key2)) {
      case (#equal) true;
      case _ false
    }
  };

  // Internal map implementation
  var map = TrieMap.TrieMap<Key, Value>(equal, hash);

  // Public API
  public func size() : Nat {
    map.size()
  };

  public func put(key : Key, value : Value) {
    map.put(key, value)
  };

  public func get(key : Key) : ?Value {
    map.get(key)
  };

  public func delete(key : Key) {
    map.delete(key)
  };

  public func clear() {
    map := TrieMap.TrieMap<Key, Value>(equal, hash)
  }
}
