import Debug "Debug";
import I "Iter";
import List "List";
import Nat "Nat";
import P "Prelude";
import Opt "Option";
import Ord "Ord";

module {

public type Ordering = Ord.Ordering;

public type Color = {#BB; #B; #R; #RR}; // (double) black, (double) red

public type Tree<X, Y> = {
  #node : (Color, Tree<X, Y>, (X, ?Y), Tree<X, Y>);
  #emp;
  #blackEmp
};

public class RBTree<X, Y>(compareTo:(X, X) -> Ordering) {

  var tree: Tree<X, Y> = (#emp : Tree<X, Y>);

  // Get non-OO, purely-functional representation:
  // for drawing, pretty-printing and non-OO contexts
  // (e.g., async args and results):
  public func getTree() : Tree<X, Y> {
    tree
  };

  public func find(x:X) : ?Y =
    findRec(x, compareTo, tree);

  public func insert(x:X, y:Y) : ?Y {
    let (res, t) = insertRoot(x, compareTo, y, tree);
    tree := t;
    res
  };

  public func remove(x:X) : ?Y {
    let (res, t) = removeRoot(x, compareTo, tree);
    tree := t;
    res
  };

  // iterator is persistent, like the tree itself;
  public func iter() : I.Iter<(X, Y)> = toIter(tree, #l2r);

  public func rev() : I.Iter<(X, Y)> = toIter(tree, #r2l);

};


type IterRep<X, Y> = List.List<{#tr:Tree<X, Y>; #xy:(X, ?Y)}>;

public func toIter<X, Y>(t:Tree<X, Y>, dir:{#l2r; #r2l}) : I.Iter<(X, Y)> {
  object {
    var trees : IterRep<X, Y> = ?(#tr t, null);
    public func next() : ?(X, Y) {
      switch (dir, trees) {
      case (_, null) { null };
      case (_, ?(#tr(#emp or #blackEmp), ts))                     { trees := ts; next() };
      case (_, ?(#xy xy, ts))                         { trees := ts; switch (xy.1) { case null next(); case (?y) ?(xy.0, y) } };
      case (#l2r, ?(#tr(#node(_, l, xy, r)), ts))     { trees := ?(#tr l, ?(#xy xy, ?(#tr r, ts))); next() };
      case (#r2l, ?(#tr(#node(_, l, xy, r)), ts))     { trees := ?(#tr r, ?(#xy xy, ?(#tr l, ts))); next() };
      }
    };
  }
};

func removeRoot<X, Y>(x:X, compareTo:(X, X) -> Ordering, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  // do recursion, then re-color root as black:
  switch (removeRec(x, compareTo, t)) {
  case (yo, #blackEmp) { (yo, #blackEmp) };
  case (yo, #emp) { (yo, #blackEmp) };
  case (yo, #node(_, l, xy, r)) { (yo, #node(#B, l, xy, r)) };
  }
};

func removeRec<X, Y>(x:X, compareTo:(X, X) -> Ordering, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  switch t {
    case (#blackEmp) { P.unreachable() };
    case (#emp) { (null, #emp) };
    case (#node(#R, #emp, xy, #emp)) {
           switch (compareTo(x, xy.0)) {
             case (#eq) { (xy.1, #blackEmp) };
             case _ { (null, t) }
           }
         };
    case (#node(#B, #emp, xy, #emp)) {
           switch (compareTo(x, xy.0)) {
             case (#eq) { (xy.1, #blackEmp) };
             case _ { (null, t) }
           }
         };
    case _ {
           P.xxx()
         }
  }
};

func balRec<X, Y>(color:Color, lt:Tree<X, Y>, kv:(X, ?Y), rt:Tree<X, Y>) : Tree<X, Y> {
  P.xxx()
};

func bal<X, Y>(color:Color, lt:Tree<X, Y>, kv:(X, ?Y), rt:Tree<X, Y>) : Tree<X, Y> {
  // thank you, algebraic pattern matching!
  // following notes from [Ravi Chugh](https://www.classes.cs.uchicago.edu/archive/2019/spring/22300-1/lectures/RedBlackTrees/index.html)
  switch (color, lt, kv, rt) {
  case (#B, #node(#R, #node(#R, a, x, b), y, c), z, d) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case (#B, #node(#R, a, x, #node(#R, b, y, c)), z, d) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case (#B, a, x, #node(#R, #node(#R, b, y, c), z, d)) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case (#B, a, x, #node(#R, b, y, #node(#R, c, z, d))) #node(#R, #node(#B, a, x, b), y, #node(#B, c, z, d));
  case _ { #node(color, lt, kv, rt) };
  }
};

func insertRoot<X, Y>(x:X, compareTo:(X, X) -> Ordering, y:Y, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  // do recursion, then re-color root as black:
  switch (insertRec(x, compareTo, y, t)) {
  case (_, #emp) { P.unreachable() };
  case (_, #blackEmp) { P.unreachable() };
  case (yo, #node(_, l, xy, r)) { (yo, #node(#B, l, xy, r)) };
  }
};

func insertRec<X, Y>(x:X, compareTo:(X, X) -> Ordering, y:Y, t:Tree<X, Y>)
  : (?Y, Tree<X, Y>)
{
  switch t {
  case (#emp) { (null, #node(#R, #emp, (x, ?y), #emp)) };
  case (#blackEmp) { (null, #node(#R, #blackEmp, (x, ?y), #blackEmp)) };
  case (#node(c, l, xy, r)) {
         switch (compareTo(x, xy.0)) {
         case (#lt) {
                let (yo, l2) = insertRec(x, compareTo, y, l);
                (yo, bal(c, l2, xy, r))
              };
         case (#eq) {
                (xy.1, #node(c, l, (x, ?y), r))
              };
         case (#gt) {
                let (yo, r2) = insertRec(x, compareTo, y, r);
                (yo, bal(c, l, xy, r2))
              };
         }
       }
  }
};

func findRec<X, Y>(x:X, compareTo:(X, X) -> Ordering, t:Tree<X, Y>) : ?Y {
  switch t {
  case (#emp or #blackEmp) { null };
  case (#node(c, l, xy, r)) {
         switch (compareTo(x, xy.0)) {
         case (#lt) { findRec(x, compareTo, l) };
         case (#eq) { xy.1 };
         case (#gt) { findRec(x, compareTo, r) };
         }
       };
  }
};


public func height<X, Y>(t:Tree<X, Y>) : Nat {
  switch t {
    case (#emp or #blackEmp) 0;
    case (#node(_, l, _, r)) {
           Nat.max(height(l), height(r))
         }
  }
};

public func size<X, Y>(t:Tree<X, Y>) : Nat {
  switch t {
    case (#emp or #blackEmp) 0;
    case (#node(_, l, _, r)) {
           size(l) + size(r)
         };
  }
};

}
