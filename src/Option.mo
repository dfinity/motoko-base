/// Optional values

import P "Prelude";

module {

/// Returns true if the argument is not `null`.
public func isSome(x : ?Any) : Bool =
  switch x {
    case null false;
    case _ true;
  };

/// Returns true if the argument is `null`.
public func isNull(x : ?Any) : Bool =
  switch x {
    case null true;
    case _ false;
  };

/// Unwraps an optional value, with a default value, i.e. `unwrap(?x, d) = x` and `unwrap(null, d) = d`.
public func get<T>(x : ?T, default : T) : T =
  switch x {
    case null { default };
    case (?x_) x_;
  };

/// Unwraps an optional value using a function, or returns the default, i.e. `option(?x, f, d) = f x` and `option(null, f, d) = d`.
public func getMapped<A, B>(x : ?A, f : A -> B, default : B) : B =
  switch x {
    case null { default };
    case (?x_) f(x_);
  };

/// Applies a function to the wrapped value.
public func map<A, B>(f : A->B, x : ?A) : ?B =
  switch x {
    case null null;
    case (?x_) ?f(x_);
  };

/// Applies an optional function to an optional value. Returns `null` if at least one of the arguments is `null`.
public func apply<A, B>(x : ?A, f : ?(A -> B)) : ?B {
  switch (f, x) {
    case (?f_, ?x_) {
      ?f_(x_);
    };
    case (_, _) {
      null;
    };
  };
};

/// Applies an function to an optional value. Returns `null` if the argument is `null`, or the function returns `null`.
///
/// NOTE: Together with <<Option_pure,`pure`>>, this forms a “monad”.
public func chain<A, B>(x : ?A, f : A -> ?B) : ?B {
  switch(x) {
    case (?x_) {
      f(x_);
    };
    case (null) {
      null;
    };
  };
};

/// Given an optional optional value, removes one layer of optionality.
public func flatten<A>(x : ??A) : ?A {
  chain<?A, A>(x, func (x_ : ?A) : ?A {
    x_;
  });
};

/// Creates an optional value from a definite value.
public func make<A>(x: A) : ?A = ?x;

/// Asserts that the value is not `null`; fails otherwise.
/// Deprecated.
public func assertSome(x : ?Any) =
  switch x {
    case null { P.unreachable() };
    case _ {};
  };

/// Asserts that the value _is_ `null`; fails otherwise.
/// Deprecated.
public func assertNull(x : ?Any) =
  switch x {
    case null { };
    case _ { P.unreachable() };
  };

/// Unwraps an optional value, i.e. `unwrap(?x) = x`.
///
/// WARNING: `unwrap(x)` will fail if the argument is `null`, and is generally considered bad style. Use `switch x` instead.
public func unwrap<T>(x : ?T) : T =
  switch x {
    case null { P.unreachable() };
    case (?x_) x_;
  };
}
