/**
[#mod-Array]
= `Array` -- Arrays
*/

import Prim "mo:prim";
module {
  public func equals<A>(a : [A], b : [A], eq : (A,A) -> Bool) : Bool {
    if (a.len() != b.len()) { 
      return false; 
    };
    var i = 0;
    while (i < a.len()) {
      if (not eq(a[i],b[i])) { 
        return false; 
      };
      i += 1;
    };
    return true; 
  };

  public func append<A>(xs : [A], ys : [A]) : [A] {
    switch(xs.len(), ys.len()) {
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

  public func apply<A, B>(fs : [A -> B], xs : [A]) : [B] {
    var ys : [B] = [];
    for (f in fs.vals()) {
      ys := append<B>(ys, map<A, B>(f, xs));
    };
    ys;
  };

  public func bind<A, B>(xs : [A], f : A -> [B]) : [B] {
    var ys : [B] = [];
    for (i in xs.keys()) {
      ys := append<B>(ys, f(xs[i]));
    };
    ys;
  };

  public func enumerate<A>(xs : [A]) : [(A, Nat)] {
    Prim.Array_tabulate<(A, Nat)>(xs.len(), func (i : Nat) : (A, Nat) {
      (xs[i], i);
    });
  };

  public func filter<A>(f : A -> Bool, xs : [A]) : [A] {
    var ys : [A] = [];
    for (x in xs.vals()) {
      if (f(x)) {
        ys := append<A>(ys, [x]);
      };
    };
    ys;
  };

  public func foldl<A, B>(f : (B, A) -> B, initial : B, xs : [A]) : B {
    var acc = initial;
    let len = xs.len();
    var i = 0;
    while (i < len) {
      acc := f(acc, xs[i]);
      i += 1;
    };
    acc;
  };

  public func foldr<A, B>(f : (A, B) -> B, initial : B, xs : [A]) : B {
    var acc = initial;
    let len = xs.len();
    var i = len;
    while (i > 0) {
      i -= 1;
      acc := f(xs[i], acc);
    };
    acc;
  };

  public func find<A>(f : A -> Bool, xs : [A]) : ?A {
    for (x in xs.vals()) {
      if (f(x)) {
        return ?x;
      }
    };
    return null;
  };

  public func freeze<A>(xs : [var A]) : [A] {
    Prim.Array_tabulate<A>(xs.len(), func (i : Nat) : A {
      xs[i];
    });
  };

  public func join<A>(xs : [[A]]) : [A] {
    bind<[A], A>(xs, func (x : [A]) : [A] {
      x;
    });
  };

  public func map<A, B>(f : A -> B, xs : [A]) : [B] {
    Prim.Array_tabulate<B>(xs.len(), func (i : Nat) : B {
      f(xs[i]);
    });
  };

  public func mapWithIndex<A, B>(f : (A, Nat) -> B, xs : [A]) : [B] {
    Prim.Array_tabulate<B>(xs.len(), func (i : Nat) : B {
      f(xs[i], i);
    });
  };

  public func pure<A>(x: A) : [A] {
    [x];
  };

  public func thaw<A>(xs : [A]) : [var A] {
    let xsLen = xs.len();
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
