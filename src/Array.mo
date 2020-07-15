/// Functions on Arrays

import Prim "mo:prim";
import I "IterType";
import Buffer "Buffer";

module {
  public func equal<A>(a : [A], b : [A], eq : (A, A) -> Bool) : Bool {
    if (a.size() != b.size()) {
      return false;
    };
    var i = 0;
    while (i < a.size()) {
      if (not eq(a[i],b[i])) {
        return false;
      };
      i += 1;
    };
    return true;
  };

  public func append<A>(xs : [A], ys : [A]) : [A] {
    switch(xs.size(), ys.size()) {
      case (0, 0) { []; };
      case (0, _) { ys; };
      case (_, 0) { xs; };
      case (xsLen, ysLen) {
        Prim.Array_tabulate<A>(xsLen + ysLen, func (i : Nat) : A {
          if (i < xsLen) {
            xs[i];
          } else {
            ys[i - xsLen];
          };
        });
      };
    };
  };

  public func apply<A, B>(xs : [A], fs : [A -> B]) : [B] {
    var ys : [B] = [];
    for (f in fs.vals()) {
      ys := append<B>(ys, map<A, B>(xs, f));
    };
    ys;
  };

  public func chain<A, B>(xs : [A], f : A -> [B]) : [B] {
    var ys : [B] = [];
    for (i in xs.keys()) {
      ys := append<B>(ys, f(xs[i]));
    };
    ys;
  };

  public func filter<A>(xs : [A], f : A -> Bool) : [A] {
    let ys : Buffer.Buffer<A> = Buffer.Buffer(xs.size());
    for (x in xs.vals()) {
      if (f(x)) {
        ys.add(x);
      };
    };
    ys.toArray();
  };

  public func filterMap<A, B>(xs : [A], f : A -> ?B) : [B] {
    let ys : Buffer.Buffer<B> = Buffer.Buffer(xs.size());
    for (x in xs.vals()) {
      switch (f(x)) {
        case null {};
        case (?y) ys.add(y);
      }
    };
    ys.toArray();
  };

  public func foldLeft<A, B>(xs : [A], initial : B, f : (B, A) -> B) : B {
    var acc = initial;
    let len = xs.size();
    var i = 0;
    while (i < len) {
      acc := f(acc, xs[i]);
      i += 1;
    };
    acc;
  };

  public func foldRight<A, B>(xs : [A], initial : B, f : (A, B) -> B) : B {
    var acc = initial;
    let len = xs.size();
    var i = len;
    while (i > 0) {
      i -= 1;
      acc := f(xs[i], acc);
    };
    acc;
  };

  public func find<A>(xs : [A], f : A -> Bool) : ?A {
    for (x in xs.vals()) {
      if (f(x)) {
        return ?x;
      }
    };
    return null;
  };

  public func freeze<A>(xs : [var A]) : [A] {
    Prim.Array_tabulate<A>(xs.size(), func (i : Nat) : A {
      xs[i];
    });
  };

  public func flatten<A>(xs : [[A]]) : [A] {
    chain<[A], A>(xs, func (x : [A]) : [A] {
      x;
    });
  };

  public func map<A, B>(xs : [A], f : A -> B) : [B] {
    Prim.Array_tabulate<B>(xs.size(), func (i : Nat) : B {
      f(xs[i]);
    });
  };

  public func mapEntries<A, B>(xs : [A], f : (A, Nat) -> B) : [B] {
    Prim.Array_tabulate<B>(xs.size(), func (i : Nat) : B {
      f(xs[i], i);
    });
  };

  public func make<A>(x: A) : [A] {
    [x];
  };

  public func vals<A>(xs : [A]) : I.Iter<A> {
    xs.vals()
  };

  public func keys<A>(xs : [A]) : I.Iter<Nat> {
    xs.keys()
  };

  public func thaw<A>(xs : [A]) : [var A] {
    let xsLen = xs.size();
    if (xsLen == 0) {
      return [var];
    };
    let ys = Prim.Array_init<A>(xsLen, xs[0]);
    for (i in ys.keys()) {
      ys[i] := xs[i];
    };
    ys;
  };

  public func init<A>(len : Nat,  x : A) : [var A] {
    Prim.Array_init<A>(len, x);
  };

  public func tabulate<A>(len : Nat,  gen : Nat -> A) : [A] {
    Prim.Array_tabulate<A>(len, gen);
  };

  // copy from iter.mo, but iter depends on array
  class range(x : Nat, y : Int) {
    var i = x;
    public func next() : ?Nat { if (i > y) null else {let j = i; i += 1; ?j} };
  };

  public func tabulateVar<A>(len : Nat,  gen : Nat -> A) : [var A] {
    if (len == 0) { return [var] };
    let xs = Prim.Array_init<A>(len, gen 0);
    for (i in range(1,len-1)) {
      xs[i] := gen i;
    };
    return xs;
  };
}
