import Types "types";
import Node "node";
import Constants "constants";
import Utils "utils";

import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";
import Stack "mo:base/Stack";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Order "mo:base/Order";

module {

  // For convenience: from types module
  type IBTreeMap<K, V> = Types.IBTreeMap<K, V>;
  type Index = Types.Index;
  type Cursor = Types.Cursor;
  // For convenience: from node module
  type Node = Node.Node;

  public func new<K, V>(map: IBTreeMap<K, V>) : Iter<K, V>{
    // Initialize the cursors with the root of the map.
    let node = map.getRootNode();
    let next : Index = switch(map.getRootNode().getNodeType()) {
      // Iterate on internal nodes starting from the first child.
      case(#Internal) { #Child(0); };
      // Iterate on leaf nodes starting from the first entry.
      case(#Leaf) { #Entry(0); };
    };
    Iter({
      map;
      cursors = [{node; next;}];
      prefix = null;
      offset = null;
    });
  };

  public func empty<K, V>(map: IBTreeMap<K, V>) : Iter<K, V>{
    Iter({
      map;
      cursors = [];
      prefix = null;
      offset = null;
    });
  };

  public func newWithPrefix<K, V>(map: IBTreeMap<K, V>, prefix: [Nat8], cursors: [Cursor]) : Iter<K, V>{
    Iter({
      map;
      cursors;
      prefix = ?prefix;
      offset = null;
    });
  };

  public func newWithPrefixAndOffset<K, V>(map: IBTreeMap<K, V>, prefix: [Nat8], offset: [Nat8], cursors: [Cursor]) : Iter<K, V>{
    Iter({
      map;
      cursors;
      prefix = ?prefix;
      offset = ?offset;
    });
  };

  type IterVariables<K, V> = {
    map: IBTreeMap<K, V>;
    cursors: [Cursor];
    prefix: ?[Nat8];
    offset: ?[Nat8];
  };

  /// An iterator over the entries of a [`BTreeMap`].
  /// Iterators are lazy and do nothing unless consumed
  public class Iter<K, V>(variables: IterVariables<K, V>) = self {
    
    // A reference to the map being iterated on.
    let map_: IBTreeMap<K, V> = variables.map;

    // A stack of cursors indicating the current position in the tree.
    var cursors_ = Stack.Stack<Cursor>();
    for (cursor in Array.vals(variables.cursors)) {
      cursors_.push(cursor);
    };

    // An optional prefix that the keys of all the entries returned must have.
    // Iteration stops as soon as it runs into a key that doesn't have this prefix.
    let prefix_: ?[Nat8] = variables.prefix;

    // An optional offset to begin iterating from in the keys with the same prefix.
    // Used only in the case that prefix is also set.
    let offset_: ?[Nat8] = variables.offset;

    public func next() : ?(K, V) {
      switch(cursors_.pop()) {
        case(?{node; next;}){
          switch(next){
            case(#Child(child_idx)){
              if (Nat64.toNat(child_idx) >= node.getChildren().size()){
                Debug.trap("Iterating over children went out of bounds.");
              };
              
              // After iterating on the child, iterate on the next _entry_ in this node.
              // The entry immediately after the child has the same index as the child's.
              cursors_.push({
                node;
                next = #Entry(child_idx);
              });

              // Add the child to the top of the cursors to be iterated on first.
              let child = node.getChild(Nat64.toNat(child_idx));
              cursors_.push({
                node = child;
                next = switch(child.getNodeType()) {
                  // Iterate on internal nodes starting from the first child.
                  case(#Internal) { #Child(0); };
                  // Iterate on leaf nodes starting from the first entry.
                  case(#Leaf) { #Entry(0); };
                };
              });

              return self.next();
            };
            case(#Entry(entry_idx)){
              if (Nat64.toNat(entry_idx) >= node.getEntries().size()) {
                // No more entries to iterate on in this node.
                return self.next();
              };

              // Take the entry from the node.
              let entry = node.getEntry(Nat64.toNat(entry_idx));

              // Add to the cursors the next element to be traversed.
              cursors_.push({
                next = switch(node.getNodeType()){
                  // If this is an internal node, add the next child to the cursors.
                  case(#Internal) { #Child(entry_idx + 1); };
                  // If this is a leaf node, add the next entry to the cursors.
                  case(#Leaf) { #Entry(entry_idx + 1); };
                };
                node;
              });

              // If there's a prefix, verify that the key has that given prefix.
              // Otherwise iteration is stopped.
              switch(prefix_){
                case(null) {};
                case(?prefix){
                  if (not Utils.isPrefixOf(prefix, entry.0, Nat8.equal)){
                    // Clear all cursors to avoid needless work in subsequent calls.
                    cursors_ := Stack.Stack<Cursor>();
                    return null;
                  } else switch(offset_) {
                    case(null) {};
                    case(?offset){
                      let prefix_with_offset = Utils.toBuffer<Nat8>(prefix);
                      prefix_with_offset.append(Utils.toBuffer<Nat8>(offset));
                      // Clear all cursors to avoid needless work in subsequent calls.
                      if (Order.isLess(Node.compareEntryKeys(entry.0, prefix_with_offset.toArray()))){  
                        cursors_ := Stack.Stack<Cursor>();
                        return null;
                      };
                    };
                  };
                };
              };
              return ?(map_.getKeyConverter().fromBytes(entry.0), map_.getValueConverter().fromBytes(entry.1));
            };
          };
        };
        case(null){
          // The cursors are empty. Iteration is complete.
          null;
        };
      };
    };
    
  };

};