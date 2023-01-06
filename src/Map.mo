import TrieMap "TrieMap";
import Order "Order";
import Hash "Hash";

module {
  public class Map<Key, Value>(compare : (Key, Key) -> Order.Order, hash : Key -> Hash.Hash) {
    func equal(key1 : Key, key2 : Key) : Bool {
      switch (compare(key1, key2)) {
        case (#equal) true;
        case _ false
      }
    };
    var map = TrieMap.TrieMap<Key, Value>(equal, hash);
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
}
