import Trie "mo:base/Trie";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import Text "mo:base/Text";
import Prelude "mo:base/Prelude";

import Rel "Rel";

/// OO-based binary relation representation.
///
/// See also: Rel module.
module {
  public class RelObj<X, Y>(
    hash : Rel.HashPair<X, Y>,
    equal : Rel.EqualPair<X, Y>) 
  {
    var rel = Rel.empty(hash, equal);
    public func put(x : X, y : Y) { 
      rel := Rel.put(rel, (x, y))
    };
    public func delete(x : X, y : Y) {
      rel := Rel.delete(rel, (x, y))
    };
    public func get0<Z>(x : X) : [Y] {
      Iter.toArray(Rel.getRelated0(rel, x))
    };
    public func get1<Z>(y : Y) : [X] {
      Iter.toArray(Rel.getRelated1(rel, y))
    };
    public func getMap0<Z>(x : X, f : Y -> Z) : [Z] {
      Iter.toArray(Iter.map(Rel.getRelated0(rel, x), f))
    };
    public func getMap1<Z>(y : Y, f : X -> Z) : [Z] {
      Iter.toArray(Iter.map(Rel.getRelated1(rel, y), f))
    };
  };
}
