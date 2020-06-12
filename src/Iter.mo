/// Iterators

import Array "Array";
import List "List";

module {
  public type Iter<T> = {next : () -> ?T};

  public class range(x : Nat, y : Int) {
    var i = x;
    public func next() : ?Nat { if (i > y) null else {let j = i; i += 1; ?j} };
  };

  public class revRange(x : Int, y : Int) {
      var i = x;
      public func next() : ?Int { if (i < y) null else {let j = i; i -= 1; ?j} };
  };

  public func apply<A>(
    xs : Iter<A>,
    f : (A, Nat) -> ()
  ) {
    var i = 0;
    label l loop {
      switch (xs.next()) {
        case (?next) {
          f(next, i);
        };
        case (null) {
          break l;
        };
      };
      i += 1;
      continue l;
    };
  };

  func size<A>(xs : Iter<A>) : Nat {
    var len = 0;
    apply<A>(xs, func (x, i) { len += 1; });
    len;
  };

  public func transform<A, B>(xs : Iter<A>, f : A -> B) : Iter<B> = object {
    var i = 0;
    public func next() : ?B {
      label l loop {
        switch (xs.next()) {
          case (?next) {
            return ?f(next);
          };
          case (null) {
            break l;
          };
        };
        i += 1;
        continue l;
      };
      null;
    };
  };

  public func make<A>(x : A) : Iter<A> = object {
    public func next() : ?A {
      ?x;
    };
  };

  public func fromArray<A>(xs : [A]) : Iter<A> {
    fromList<A>(List.fromArray<A>(xs));
  };

  public func fromArrayMut<A>(xs : [var A]) : Iter<A> {
    fromArray<A>(Array.freeze<A>(xs));
  };

  public func fromList<A>(xs : List.List<A>) : Iter<A> {
    List.toArray<A>(xs).vals();
  };

  public func toArray<A>(xs : Iter<A>) : [A] {
    List.toArray<A>(toList<A>(xs));
  };

  public func toArrayMut<A>(xs : Iter<A>) : [var A] {
    Array.thaw<A>(toArray<A>(xs));
  };

  public func toList<A>(xs : Iter<A>) : List.List<A> {
    toListWithSize<A>(xs).list;
  };

  public func toListWithSize<A>(
    xs : Iter<A>,
  ) : ({
    size : Nat;
    list : List.List<A>;
  }) {
    var _size = 0;
    var _list = List.nil<A>();
    apply<A>(xs, func (x, i) {
      _size += 1;
      _list := List.push<A>(x, _list);
    });
    { size = _size; list = List.rev<A>(_list); };
  };
}
