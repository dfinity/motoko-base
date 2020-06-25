/// Functions on functions
///
/// The functions in this module are rather useless on their own but they're
/// commonly used when programming in a functional style with higher-order
/// functions.

module {
  /// The composition of two functions `f` and `g` is a function that applies `g` and then `f`.
  ///
  /// ```motoko
  /// compose(f, g)(x) = f(g(x))
  /// ```
  public func compose<A, B, C>(f : B -> C, g : A -> B) : A -> C {
    func (x : A) : C {
      f(g(x));
    };
  };

  /// The `identity` function returns its argument.
  /// ```motoko
  /// identity(10) = 10
  /// identity(true) = true
  /// ```
  public func identity<A>(x : A) : A = x;

  /// The const function is a _curried_ function that accepts an argument `x`,
  /// and then returns a function that discards its argument and always returns
  /// the `x`.
  ///
  /// ```motoko
  /// const(10)("hello") = 10
  /// const(true)(20) = true
  /// ```
  public func const<A, B>(x : A) : B -> A =
    func _ = x;
}
