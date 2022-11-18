import Array "mo:base/Array";
import T "mo:matchers/Testable";

module {

  func joinWith(xs : [var Text], sep : Text) : Text {
    let size = xs.size();

    if (size == 0) return "";
    if (size == 1) return xs[0];

    var result = xs[0];
    var i = 0;
    label l loop {
      i += 1;
      if (i >= size) { break l; };
      result #= sep # xs[i]
    };
    result
  };

  func varArrayMap<A, B>(array: [var A], f: A -> B): [var B] {
    Array.tabulateVar<B>(array.size(), func(i) { f(array[i]) });
  };

  public func varArrayTestable<A>(testableA : T.Testable<A>) : T.Testable<[var A]> {
    {
      display = func (xs : [var A]) : Text =
        "[" # 
        joinWith(
          varArrayMap<A, Text>(xs, testableA.display), ", "
        ) # 
        "]";
      equals = func (xs1 : [var A], xs2 : [var A]) : Bool {
        if (xs1.size() != xs2.size()) {
          return false;
        };

        var i = 0;
        while (i < xs1.size()) {
          if (not testableA.equals(xs1[i], xs2[i])) {
            return false;
          };
          i += 1;
        };

        true;
      }
    }
  };

  public func varArray<A>(testableA: T.Testable<A>, xs: [var A]): T.TestableItem<[var A]> {
    let testableAs = varArrayTestable<A>(testableA);
    {
        item = xs;
        display = testableAs.display;
        equals = testableAs.equals;
    };
  };



  public func tuple3Testable<A, B, C>(ta : T.Testable<A>, tb: T.Testable<B>,  tc : T.Testable<C>) : T.Testable<(A, B, C)> {
    {
      display = func ((a, b, c) : (A, B, C)) : Text =
        "(" # ta.display(a) # ", " # tb.display(b) # ", " # tc.display(c) # ")";
      equals = func((a1, b1, c1) : (A, B, C), (a2, b2, c2) : (A, B, C)) : Bool =
        ta.equals(a1, a2) and tb.equals(b1, b2) and tc.equals(c1, c2);
    }
  };

  public func tuple3<A, B, C>(ta : T.Testable<A>, tb : T.Testable<B>, tc: T.Testable<C>, x : (A, B, C)) : T.TestableItem<(A, B, C)> {
    let testableTABC = tuple3Testable(ta, tb, tc);
    {
        item = x;
        display = testableTABC.display;
        equals = testableTABC.equals;
    }
  };

}