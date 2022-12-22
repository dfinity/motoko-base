import Debug "mo:base/Debug";
import Float "mo:base/Float";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class FloatTestable(number : Float, epsilon : Float) : T.TestableItem<Float> {
  public let item = number;
  public func display(number : Float) : Text {
    debug_show (number);
  };
  public let equals = func(x : Float, y : Float) : Bool {
    if (epsilon == 0.0) {
      x == y // to also test Float.abs()
    } else {
      Float.abs(x - y) < epsilon;
    };
  };
};

class Int64Testable(number : Int64) : T.TestableItem<Int64> {
  public let item = number;
  public func display(number : Int64) : Text {
    debug_show (number);
  };
  public let equals = func(x : Int64, y : Int64) : Bool {
    x == y;
  };
};

let negativeNaN = 0.0 / 0.0;
let positiveNaN = Float.copySign(negativeNaN, 1.0); // Compiler issue, NaN are represented negative by default. https://github.com/dfinity/motoko/issues/3647

func isPositiveNaN(number : Float) : Bool {
  debug_show (number) == "nan";
};

func isNegativeNaN(number : Float) : Bool {
  debug_show (number) == "-nan";
};

let positiveZero = 0.0;
let negativeZero = Float.copySign(0.0, -1.0); // Compiler bug, cannot use literal `-0.0`. https://github.com/dfinity/motoko/issues/3646

func isPositiveZero(number : Float) : Bool {
  number == 0.0 and 1.0 / number == Float.positiveInfinity();
};

func isNegativeZero(number : Float) : Bool {
  number == 0.0 and 1.0 / number == Float.negativeInfinity();
};

class PositiveZeroMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be '0.0' (positive zero)");
  };

  public func matches(number : Float) : Bool {
    isPositiveZero(number);
  };
};

class NegativeZeroMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be '-0.0' (negative zero)");
  };

  public func matches(number : Float) : Bool {
    isNegativeZero(number);
  };
};

let noEpsilon = 0.0;
let smallEpsilon = 1e-6;

class NaNMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be 'nan' or '-nan'");
  };

  public func matches(number : Float) : Bool {
    Float.isNaN(number);
  };
};

class PositiveNaNMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be 'nan' (positive)");
  };

  public func matches(number : Float) : Bool {
    isPositiveNaN(number);
  };
};

class NegativeNaNMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be '-nan' (negative)");
  };

  public func matches(number : Float) : Bool {
    isNegativeNaN(number);
  };
};

// Some tests are adopted from Motoko compiler test `float-ops.mo`.

/* --------------------------------------- */

run(
  suite(
    "constant functions",
    [
      test(
        "positive infinity",
        Float.positiveInfinity(),
        M.equals(FloatTestable(1.0/0.0, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.negativeInfinity(),
        M.equals(FloatTestable(-1.0/0.0, noEpsilon)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "isNaN",
    [
      test(
        "positive NaN",
        Float.isNaN(positiveNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        Float.isNaN(negativeNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "positive number",
        Float.isNaN(1.1),
        M.equals(T.bool(false)),
      ),
      test(
        "negative number",
        Float.isNaN(-1.1),
        M.equals(T.bool(false)),
      ),
      test(
        "zero",
        Float.isNaN(0.0),
        M.equals(T.bool(false)),
      ),
      test(
        "positive zero",
        Float.isNaN(positiveZero),
        M.equals(T.bool(false)),
      ),
      test(
        "negative zero",
        Float.isNaN(negativeZero),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity",
        Float.isNaN(Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity",
        Float.isNaN(Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "abs",
    [
      test(
        "positive number",
        Float.abs(1.1),
        M.equals(FloatTestable(1.1, noEpsilon)),
      ),
      test(
        "negative number",
        Float.abs(-1.1),
        M.equals(FloatTestable(1.1, noEpsilon)),
      ),
      test(
        "zero",
        Float.abs(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive zero",
        Float.abs(positiveZero),
        PositiveZeroMatcher(),
      ),
      test(
        "negative zero",
        Float.abs(negativeZero),
        PositiveZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.abs(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.abs(Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN",
        Float.abs(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.abs(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "sqrt",
    [
      test(
        "positive number",
        Float.sqrt(6.25),
        M.equals(FloatTestable(2.5, noEpsilon)),
      ),
      test(
        "zero",
        Float.sqrt(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive zero",
        Float.sqrt(positiveZero),
        PositiveZeroMatcher(),
      ),
      test(
        "negative zero",
        Float.sqrt(negativeZero),
        NegativeZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.sqrt(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative",
        Float.sqrt(-16.0),
        NaNMatcher(),
      ),
      test(
        "positive NaN",
        Float.sqrt(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.sqrt(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "ceil",
    [
      test(
        "positive fraction",
        Float.ceil(1.1),
        M.equals(FloatTestable(2.0, noEpsilon)),
      ),
      test(
        "negative fraction",
        Float.ceil(-1.2),
        M.equals(FloatTestable(-1.0, noEpsilon)),
      ),
      test(
        "integral number",
        Float.ceil(-3.0),
        M.equals(FloatTestable(-3.0, noEpsilon)),
      ),
      test(
        "zero",
        Float.ceil(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive zero",
        Float.ceil(positiveZero),
        PositiveZeroMatcher(),
      ),
      test(
        "negative zero",
        Float.ceil(negativeZero),
        NegativeZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.ceil(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.ceil(Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN",
        Float.ceil(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.ceil(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "floor",
    [
      test(
        "positive fraction",
        Float.floor(1.1),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "negative fraction",
        Float.floor(-1.2),
        M.equals(FloatTestable(-2.0, noEpsilon)),
      ),
      test(
        "integral number",
        Float.floor(3.0),
        M.equals(FloatTestable(3.0, noEpsilon)),
      ),
      test(
        "zero",
        Float.floor(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive zero",
        Float.floor(positiveZero),
        PositiveZeroMatcher(),
      ),
      test(
        "negative zero",
        Float.floor(negativeZero),
        NegativeZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.floor(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.floor(Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN",
        Float.floor(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.floor(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "trunc",
    [
      test(
        "positive fraction",
        Float.trunc(3.9123),
        M.equals(FloatTestable(3.0, noEpsilon)),
      ),
      test(
        "negative fraction",
        Float.trunc(-3.9123),
        M.equals(FloatTestable(-3.0, noEpsilon)),
      ),
      test(
        "integral number",
        Float.trunc(3.0),
        M.equals(FloatTestable(3.0, noEpsilon)),
      ),
      test(
        "zero",
        Float.trunc(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive zero",
        Float.trunc(positiveZero),
        PositiveZeroMatcher(),
      ),
      test(
        "negative zero",
        Float.trunc(negativeZero),
        NegativeZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.trunc(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.trunc(Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN",
        Float.trunc(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.trunc(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "floor",
    [
      test(
        "positive round up",
        Float.nearest(3.75),
        M.equals(FloatTestable(4.0, noEpsilon)),
      ),
      test(
        "negative round down",
        Float.nearest(-3.75),
        M.equals(FloatTestable(-4.0, noEpsilon)),
      ),
      test(
        "positive round down",
        Float.nearest(3.25),
        M.equals(FloatTestable(3.0, noEpsilon)),
      ),
      test(
        "negative round up",
        Float.nearest(-3.25),
        M.equals(FloatTestable(-3.0, noEpsilon)),
      ),
      test(
        "positive .5",
        Float.nearest(3.5),
        M.equals(FloatTestable(4.0, noEpsilon)),
      ),
      test(
        "negative .5",
        Float.nearest(-3.5),
        M.equals(FloatTestable(-4.0, noEpsilon)),
      ),
      test(
        "integral number",
        Float.nearest(3.0),
        M.equals(FloatTestable(3.0, noEpsilon)),
      ),
      test(
        "positive infinity",
        Float.nearest(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.nearest(Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN",
        Float.nearest(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.nearest(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "copySign",
    [
      test(
        "both positive",
        Float.copySign(1.2, 2.3),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "positive, negative",
        Float.copySign(1.2, -2.3),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "both negative",
        Float.copySign(-1.2, -2.3),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "negative, positive",
        Float.copySign(-1.2, 2.3),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "negate positive zero",
        Float.copySign(0.0, -1),
        NegativeZeroMatcher(),
      ),
      test(
        "keep positive zero",
        Float.copySign(0.0, 1),
        PositiveZeroMatcher(),
      ),
      test(
        "negate by negative zero",
        Float.copySign(2.1, negativeZero),
        M.equals(FloatTestable(-2.1, noEpsilon)),
      ),
      test(
        "positive infinity",
        Float.copySign(1.2, Float.positiveInfinity()),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.copySign(1.2, Float.negativeInfinity()),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "keep positive NaN",
        Float.copySign(positiveNaN, 1.0),
        PositiveNaNMatcher(),
      ),
      test(
        "negate positive NaN",
        Float.copySign(positiveNaN, -1.0),
        NegativeNaNMatcher(),
      ),
      test(
        "keep negative NaN",
        Float.copySign(negativeNaN, -1.0),
        NegativeNaNMatcher(),
      ),
      test(
        "negate negative NaN",
        Float.copySign(negativeNaN, 1.0),
        PositiveNaNMatcher(),
      ),
      test(
        "second argument positive NaN",
        Float.copySign(-1.2, positiveNaN),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "second argument negative NaN",
        Float.copySign(1.2, negativeNaN),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "both NaN",
        Float.copySign(negativeNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.copySign(positiveNaN, Float.positiveInfinity()),
        PositiveNaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.copySign(positiveNaN, Float.negativeInfinity()),
        NegativeNaNMatcher(),
      ),
      test(
        "positive infinity and positive NaN",
        Float.copySign(Float.positiveInfinity(), positiveNaN),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and negative NaN",
        Float.copySign(Float.positiveInfinity(), negativeNaN),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and positive NaN",
        Float.copySign(Float.negativeInfinity(), positiveNaN),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and negative NaN",
        Float.copySign(Float.negativeInfinity(), negativeNaN),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "min",
    [
      test(
        "both positive",
        Float.min(1.2, 2.3),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "positive, negative",
        Float.min(1.2, -2.3),
        M.equals(FloatTestable(-2.3, noEpsilon)),
      ),
      test(
        "both negative",
        Float.min(-1.2, -2.3),
        M.equals(FloatTestable(-2.3, noEpsilon)),
      ),
      test(
        "negative, positive",
        Float.min(-1.2, 2.3),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "equal values",
        Float.min(1.23, 1.23),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "zero with different signs",
        Float.min(positiveZero, negativeZero),
        NegativeZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.min(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.min(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.min(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "left NaN",
        Float.min(positiveNaN, 1.0),
        NaNMatcher(),
      ),
      test(
        "right NaN",
        Float.min(-1.0, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "both NaN",
        Float.min(negativeNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.min(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.min(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.min(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.min(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "max",
    [
      test(
        "both positive",
        Float.max(1.2, 2.3),
        M.equals(FloatTestable(2.3, noEpsilon)),
      ),
      test(
        "positive, negative",
        Float.max(1.2, -2.3),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "both negative",
        Float.max(-1.2, -2.3),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "negative, positive",
        Float.max(-1.2, 2.3),
        M.equals(FloatTestable(2.3, noEpsilon)),
      ),
      test(
        "equal values",
        Float.max(1.23, 1.23),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "zero with different signs",
        Float.max(positiveZero, negativeZero),
        PositiveZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.max(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.max(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.max(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "left NaN",
        Float.max(positiveNaN, 1.0),
        NaNMatcher(),
      ),
      test(
        "right NaN",
        Float.max(-1.0, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "both NaN",
        Float.max(negativeNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.max(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.max(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.max(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.max(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

let ninetyDegrees = Float.pi / 2.0;
let fortyFiveDegrees = Float.pi / 4.0;
let arbitraryAngle = 0.123;
let sqrt2over2 = Float.sqrt(2) / 2;

run(
  suite(
    "sin",
    [
      test(
        "zero",
        Float.sin(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "90 degrees",
        Float.sin(ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon)),
      ),
      test(
        "180 degrees",
        Float.sin(2 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "270 degrees",
        Float.sin(3 * ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon)),
      ),
      test(
        "360 degrees",
        Float.sin(4 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "-90 degrees",
        Float.sin(-ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon)),
      ),
      test(
        "-180 degrees",
        Float.sin(-2 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "-270 degrees",
        Float.sin(-3 * ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon)),
      ),
      test(
        "-360 degrees",
        Float.sin(-4 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive infinity",
        Float.sin(Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative infinity",
        Float.sin(Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive NaN",
        Float.sin(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.sin(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "cos",
    [
      test(
        "zero",
        Float.cos(0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "90 degrees",
        Float.cos(ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "180 degrees",
        Float.cos(2 * ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon)),
      ),
      test(
        "270 degrees",
        Float.cos(3 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "360 degrees",
        Float.cos(4 * ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon)),
      ),
      test(
        "-90 degrees",
        Float.cos(-ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "-180 degrees",
        Float.cos(-2 * ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon)),
      ),
      test(
        "-270 degrees",
        Float.cos(-3 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "-360 degrees",
        Float.cos(-4 * ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon)),
      ),
      test(
        "positive infinity",
        Float.cos(Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative infinity",
        Float.cos(Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive NaN",
        Float.cos(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.cos(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "tan",
    [
      test(
        "zero",
        Float.tan(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "45 degrees",
        Float.tan(fortyFiveDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon)),
      ),
      test(
        "-45 degrees",
        Float.tan(-fortyFiveDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon)),
      ),
      test(
        "positive infinity",
        Float.tan(Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative infinity",
        Float.tan(Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive NaN",
        Float.tan(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.tan(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "arcsin",
    [
      test(
        "zero",
        Float.arcsin(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "90 degrees",
        Float.arcsin(1.0),
        M.equals(FloatTestable(ninetyDegrees, smallEpsilon)),
      ),
      test(
        "-90 degrees",
        Float.arcsin(-1.0),
        M.equals(FloatTestable(-ninetyDegrees, smallEpsilon)),
      ),
      test(
        "arbitrary angle",
        Float.arcsin(Float.sin(arbitraryAngle)),
        M.equals(FloatTestable(arbitraryAngle, smallEpsilon)),
      ),
      test(
        "above 1",
        Float.arcsin(1.01),
        NaNMatcher(),
      ),
      test(
        "below 1",
        Float.arcsin(-1.01),
        NaNMatcher(),
      ),
      test(
        "positive NaN",
        Float.arcsin(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.arcsin(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "arccos",
    [
      test(
        "zero",
        Float.arccos(0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon)),
      ),
      test(
        "90 degrees",
        Float.arccos(1.0),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "180 degrees",
        Float.arccos(-1.0),
        M.equals(FloatTestable(2 * ninetyDegrees, smallEpsilon)),
      ),
      test(
        "arbitrary angle",
        Float.arccos(Float.cos(arbitraryAngle)),
        M.equals(FloatTestable(arbitraryAngle, smallEpsilon)),
      ),
      test(
        "above 1",
        Float.arccos(1.01),
        NaNMatcher(),
      ),
      test(
        "below 1",
        Float.arccos(-1.01),
        NaNMatcher(),
      ),
      test(
        "positive NaN",
        Float.arccos(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.arccos(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "arctan",
    [
      test(
        "zero",
        Float.arctan(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "45 degrees",
        Float.arctan(1.0),
        M.equals(FloatTestable(fortyFiveDegrees, smallEpsilon)),
      ),
      test(
        "-45 degrees",
        Float.arctan(-1.0),
        M.equals(FloatTestable(-fortyFiveDegrees, smallEpsilon)),
      ),
      test(
        "arbitrary angle",
        Float.arctan(Float.tan(arbitraryAngle)),
        M.equals(FloatTestable(arbitraryAngle, smallEpsilon)),
      ),
      test(
        "positive infinity",
        Float.arctan(Float.positiveInfinity()),
        M.equals(FloatTestable(ninetyDegrees, smallEpsilon)),
      ),
      test(
        "negative infinity",
        Float.arctan(Float.negativeInfinity()),
        M.equals(FloatTestable(-ninetyDegrees, smallEpsilon)),
      ),
      test(
        "positive NaN",
        Float.arctan(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.arctan(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "arctan2",
    [
      test(
        "zero",
        Float.arctan2(0.0, 0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "left negative zero",
        Float.arctan2(negativeZero, 0.0),
        NegativeZeroMatcher(),
      ),
      test(
        "right negative zero",
        Float.arctan2(0.0, negativeZero),
        M.equals(FloatTestable(2 * ninetyDegrees, noEpsilon)),
      ),
      test(
        "two negative zero",
        Float.arctan2(negativeZero, negativeZero),
        M.equals(FloatTestable(-2 * ninetyDegrees, noEpsilon)),
      ),
      test(
        "90 degrees",
        Float.arctan2(1.0, 0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon)),
      ),
      test(
        "-90 degrees",
        Float.arctan2(-1.0, 0.0),
        M.equals(FloatTestable(-ninetyDegrees, noEpsilon)),
      ),
      test(
        "45 degrees",
        Float.arctan2(sqrt2over2, sqrt2over2),
        M.equals(FloatTestable(fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "-45 degrees",
        Float.arctan2(-sqrt2over2, sqrt2over2),
        M.equals(FloatTestable(-fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "left positive infinity",
        Float.arctan2(Float.positiveInfinity(), 0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon)),
      ),
      test(
        "left negative infinity",
        Float.arctan2(Float.negativeInfinity(), 0.0),
        M.equals(FloatTestable(-ninetyDegrees, noEpsilon)),
      ),
      test(
        "right positive infinity",
        Float.arctan2(0.0, Float.positiveInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "right negative infinity",
        Float.arctan2(0.0, Float.negativeInfinity()),
        M.equals(FloatTestable(2 * ninetyDegrees, noEpsilon)),
      ),
      test(
        "both positive infinity",
        Float.arctan2(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "both negative infinity",
        Float.arctan2(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(-3 * fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.arctan2(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(3 * fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.arctan2(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(-fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "left positive NaN",
        Float.arctan2(positiveNaN, 0.0),
        NaNMatcher(),
      ),
      test(
        "left negative NaN",
        Float.arctan2(negativeNaN, 0.0),
        NaNMatcher(),
      ),
      test(
        "right positive NaN",
        Float.arctan2(0.0, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "left negative NaN",
        Float.arctan2(0.0, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "two NaNs",
        Float.arctan2(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.arctan2(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.arctan2(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.arctan2(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.arctan2(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "exp",
    [
      test(
        "zero",
        Float.exp(0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "one",
        Float.exp(1.0),
        M.equals(FloatTestable(Float.e, noEpsilon)),
      ),
      test(
        "positive infinity",
        Float.exp(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.exp(Float.negativeInfinity()),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive NaN",
        Float.exp(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.exp(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "log",
    [
      test(
        "one",
        Float.log(1.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "e",
        Float.log(Float.e),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "arbitrary number",
        Float.log(Float.exp(1.23)),
        M.equals(FloatTestable(1.23, smallEpsilon)),
      ),
      test(
        "zero",
        Float.log(0.0),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative zero",
        Float.log(negativeZero),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative",
        Float.log(-0.01),
        NaNMatcher(),
      ),
      test(
        "positive infinity",
        Float.log(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN",
        Float.log(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN",
        Float.log(negativeNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "format",
    [
      test(
        "exact positive",
        Float.format(#exact, 20.12345678901),
        M.equals(T.text("20.12345678901")),
      ),
      test(
        "exact negative",
        Float.format(#exact, -20.12345678901),
        M.equals(T.text("-20.12345678901")),
      ),
      test(
        "exact positive zero",
        Float.format(#exact, positiveZero),
        M.equals(T.text("0")),
      ),
      test(
        "exact negative zero",
        Float.format(#exact, negativeZero),
        M.equals(T.text("-0")),
      ),
      test(
        "exact positive infinity",
        Float.format(#exact, Float.positiveInfinity()),
        M.equals(T.text("inf")),
      ),
      test(
        "exact negative infinity",
        Float.format(#exact, Float.negativeInfinity()),
        M.equals(T.text("-inf")),
      ),
      test(
        "exact positive NaN",
        Float.format(#exact, positiveNaN),
        M.equals(T.text("nan")),
      ),
      test(
        "exact negative NaN",
        Float.format(#exact, negativeNaN),
        M.equals(T.text("-nan")),
      ),
      test(
        "fix positive",
        Float.format(#fix 6, 20.12345678901),
        M.equals(T.text("20.123457")),
      ),
      test(
        "fix negative",
        Float.format(#fix 6, -20.12345678901),
        M.equals(T.text("-20.123457")),
      ),
      test(
        "fix positive zero",
        Float.format(#fix 6, positiveZero),
        M.equals(T.text("0.000000")),
      ),
      test(
        "fix negative zero",
        Float.format(#fix 6, negativeZero),
        M.equals(T.text("-0.000000")),
      ),
      test(
        "fix positive infinity",
        Float.format(#fix 6, Float.positiveInfinity()),
        M.equals(T.text("inf")),
      ),
      test(
        "fix negative infinity",
        Float.format(#fix 6, Float.negativeInfinity()),
        M.equals(T.text("-inf")),
      ),
      test(
        "fix positive NaN",
        Float.format(#fix 6, positiveNaN),
        M.equals(T.text("nan")),
      ),
      test(
        "fix negative NaN",
        Float.format(#fix 6, negativeNaN),
        M.equals(T.text("-nan")),
      ),
      test(
        "exp positive",
        Float.format(#exp 9, 20.12345678901),
        M.equals(T.text("2.012345679e+01")),
      ),
      test(
        "exp negative",
        Float.format(#exp 9, -20.12345678901),
        M.equals(T.text("-2.012345679e+01")),
      ),
      test(
        "exp positive zero",
        Float.format(#exp 9, positiveZero),
        M.equals(T.text("0.000000000e+00")),
      ),
      test(
        "exp negative zero",
        Float.format(#exp 9, negativeZero),
        M.equals(T.text("-0.000000000e+00")),
      ),
      test(
        "exp positive infinity",
        Float.format(#exp 9, Float.positiveInfinity()),
        M.equals(T.text("inf")),
      ),
      test(
        "exp negative infinity",
        Float.format(#exp 9, Float.negativeInfinity()),
        M.equals(T.text("-inf")),
      ),
      test(
        "exp positive NaN",
        Float.format(#exp 9, positiveNaN),
        M.equals(T.text("nan")),
      ),
      test(
        "exp negative NaN",
        Float.format(#exp 9, negativeNaN),
        M.equals(T.text("-nan")),
      ),
      test(
        "gen positive",
        Float.format(#gen 12, 20.12345678901),
        M.equals(T.text("20.123456789")),
      ),
      test(
        "gen negative",
        Float.format(#gen 12, -20.12345678901),
        M.equals(T.text("-20.123456789")),
      ),
      test(
        "gen positive zero",
        Float.format(#gen 12, positiveZero),
        M.equals(T.text("0")),
      ),
      test(
        "gen negative zero",
        Float.format(#gen 12, negativeZero),
        M.equals(T.text("-0")),
      ),
      test(
        "gen positive infinity",
        Float.format(#gen 12, Float.positiveInfinity()),
        M.equals(T.text("inf")),
      ),
      test(
        "gen negative infinity",
        Float.format(#gen 12, Float.negativeInfinity()),
        M.equals(T.text("-inf")),
      ),
      test(
        "gen positive NaN",
        Float.format(#gen 12, positiveNaN),
        M.equals(T.text("nan")),
      ),
      test(
        "gen negative NaN",
        Float.format(#gen 12, negativeNaN),
        M.equals(T.text("-nan")),
      ),
      test(
        "hex positive",
        Float.format(#hex 10, 20.12345678901),
        M.equals(T.text("0x1.41f9add374p+4")),
      ),
      test(
        "hex negative",
        Float.format(#hex 10, -20.12345678901),
        M.equals(T.text("-0x1.41f9add374p+4")),
      ),
      test(
        "hex positive zero",
        Float.format(#hex 10, positiveZero),
        M.equals(T.text("0x0.0000000000p+0")),
      ),
      test(
        "hex negative zero",
        Float.format(#hex 10, negativeZero),
        M.equals(T.text("-0x0.0000000000p+0")),
      ),
      test(
        "hex positive infinity",
        Float.format(#hex 10, Float.positiveInfinity()),
        M.equals(T.text("inf")),
      ),
      test(
        "hex negative infinity",
        Float.format(#hex 10, Float.negativeInfinity()),
        M.equals(T.text("-inf")),
      ),
      test(
        "hex positive NaN",
        Float.format(#hex 10, positiveNaN),
        M.equals(T.text("nan")),
      ),
      test(
        "hex negative NaN",
        Float.format(#hex 10, negativeNaN),
        M.equals(T.text("-nan")),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "toText",
    [
      test(
        "positive",
        Float.toText(20.12345678901),
        M.equals(T.text("20.123457")),
      ),
      test(
        "negative",
        Float.toText(-20.12345678901),
        M.equals(T.text("-20.123457")),
      ),
      test(
        "positive zero",
        Float.toText(positiveZero),
        M.equals(T.text("0.000000")),
      ),
      test(
        "negative zero",
        Float.toText(negativeZero),
        M.equals(T.text("-0.000000")),
      ),
      test(
        "positive infinity",
        Float.toText(Float.positiveInfinity()),
        M.equals(T.text("inf")),
      ),
      test(
        "negative infinity",
        Float.toText(Float.negativeInfinity()),
        M.equals(T.text("-inf")),
      ),
      test(
        "positive NaN",
        Float.toText(positiveNaN),
        M.equals(T.text("nan")),
      ),
      test(
        "negative NaN",
        Float.toText(negativeNaN),
        M.equals(T.text("-nan")),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "toInt64",
    [
      test(
        "positive",
        Float.toInt64(20.987),
        M.equals(Int64Testable(20)),
      ),
      test(
        "negative",
        Float.toInt64(-20.987),
        M.equals(Int64Testable(-20)),
      ),
      test(
        "nearly zero",
        Float.toInt64(-1e-40),
        M.equals(Int64Testable(0)),
      ),
      test(
        "large integer",
        Float.toInt64(9223372036854774784.0),
        M.equals(Int64Testable(9223372036854774784)),
      ),
      test(
        "small integer",
        Float.toInt64(-9223372036854774784.0),
        M.equals(Int64Testable(-9223372036854774784)),
      ),
      test(
        "positive zero",
        Float.toInt64(positiveZero),
        M.equals(Int64Testable(0)),
      ),
      test(
        "negative zero",
        Float.toInt64(negativeZero),
        M.equals(Int64Testable(0)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "fromInt64",
    [
      test(
        "positive",
        Float.fromInt64(20),
        M.equals(FloatTestable(20.0, noEpsilon)),
      ),
      test(
        "negative",
        Float.fromInt64(-20),
        M.equals(FloatTestable(-20.0, noEpsilon)),
      ),
      test(
        "zero",
        Float.fromInt64(0),
        PositiveZeroMatcher(),
      ),
      test(
        "max integer",
        Float.fromInt64(9223372036854775807),
        M.equals(FloatTestable(9223372036854775807.0, noEpsilon)),
      ),
      test(
        "min integer",
        Float.fromInt64(-9223372036854775808),
        M.equals(FloatTestable(-9223372036854775808.0, noEpsilon)),
      ),
    ],
  ),
);

/* --------------------------------------- */

let arbitraryBigInt = 169_999_999_999_999_993_883_079_578_865_998_174_333_346_074_304_075_874_502_773_119_193_537_729_178_160_565_864_330_091_787_584_707_988_572_262_467_983_188_919_169_916_105_593_357_174_268_369_962_062_473_635_296_474_636_515_660_464_935_663_040_684_957_844_303_524_367_815_028_553_272_712_298_986_386_310_828_644_513_212_353_921_123_253_311_675_499_856_875_650_512_437_415_429_217_994_623_324_794_855_339_589_632;
let arbitraryBigIntAsFloat = 1.7e308;

run(
  suite(
    "toInt",
    [
      test(
        "positive",
        Float.toInt(20.987),
        M.equals(T.int(20)),
      ),
      test(
        "negative",
        Float.toInt(-20.987),
        M.equals(T.int(-20)),
      ),
      test(
        "nearly zero",
        Float.toInt(-1e-40),
        M.equals(T.int(0)),
      ),
      test(
        "positive big integer",
        Float.toInt(arbitraryBigIntAsFloat),
        M.equals(T.int(arbitraryBigInt)),
      ),
      test(
        "negative big integer",
        Float.toInt(-arbitraryBigIntAsFloat),
        M.equals(T.int(-arbitraryBigInt)),
      ),
      test(
        "positive zero",
        Float.toInt(positiveZero),
        M.equals(T.int(0)),
      ),
      test(
        "negative zero",
        Float.toInt(negativeZero),
        M.equals(T.int(0)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "fromInt",
    [
      test(
        "positive",
        Float.fromInt(20),
        M.equals(FloatTestable(20.0, noEpsilon)),
      ),
      test(
        "negative",
        Float.fromInt(-20),
        M.equals(FloatTestable(-20.0, noEpsilon)),
      ),
      test(
        "zero",
        Float.fromInt(0),
        PositiveZeroMatcher(),
      ),
      test(
        "positive big integer",
        Float.fromInt(arbitraryBigInt),
        M.equals(FloatTestable(arbitraryBigIntAsFloat, noEpsilon)),
      ),
      test(
        "negative big integer",
        Float.fromInt(-arbitraryBigInt),
        M.equals(FloatTestable(-arbitraryBigIntAsFloat, noEpsilon)),
      ),
      test(
        "positive infinity",
        Float.fromInt(3 ** 7777),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.fromInt(-3 ** 7777),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "equal",
    [
      test(
        "positive equal",
        Float.equal(1.23, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative equal",
        Float.equal(-1.23, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "zero",
        Float.equal(0.0, 0.0),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed zero signs",
        Float.equal(positiveZero, negativeZero),
        M.equals(T.bool(true)),
      ),
      test(
        "positive not equal",
        Float.equal(1.23, 1.24),
        M.equals(T.bool(false)),
      ),
      test(
        "negative not equal",
        Float.equal(-1.23, -1.24),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed signs",
        Float.equal(1.23, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity",
        Float.equal(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity",
        Float.equal(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed infinity signs",
        Float.equal(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "two positive NaNs",
        Float.equal(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "two negative NaNs",
        Float.equal(negativeNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaNs with mixed signs",
        Float.equal(positiveNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "number and NaN",
        Float.equal(1.23, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and number",
        Float.equal(positiveNaN, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and NaN",
        Float.equal(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and positive infinity",
        Float.equal(positiveNaN, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.equal(positiveNaN, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.equal(Float.positiveInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.equal(Float.negativeInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "notEqual",
    [
      test(
        "positive equal",
        Float.notEqual(1.23, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative equal",
        Float.notEqual(-1.23, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "zero",
        Float.notEqual(0.0, 0.0),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed zero signs",
        Float.notEqual(positiveZero, negativeZero),
        M.equals(T.bool(false)),
      ),
      test(
        "positive not equal",
        Float.notEqual(1.23, 1.24),
        M.equals(T.bool(true)),
      ),
      test(
        "negative not equal",
        Float.notEqual(-1.23, -1.24),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed signs",
        Float.notEqual(1.23, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity",
        Float.notEqual(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity",
        Float.notEqual(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed infinity signs",
        Float.notEqual(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "two positive NaNs",
        Float.notEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "two negative NaNs",
        Float.notEqual(negativeNaN, negativeNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "NaNs with mixed signs",
        Float.notEqual(positiveNaN, negativeNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "number and NaN",
        Float.notEqual(1.23, positiveNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "NaN and number",
        Float.notEqual(positiveNaN, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "NaN and NaN",
        Float.notEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "NaN and positive infinity",
        Float.notEqual(positiveNaN, Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "NaN and negative infinity",
        Float.notEqual(positiveNaN, Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity and NaN",
        Float.notEqual(Float.positiveInfinity(), positiveNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity and NaN",
        Float.notEqual(Float.negativeInfinity(), positiveNaN),
        M.equals(T.bool(true)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "less",
    [
      test(
        "positive equal",
        Float.less(1.23, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "positive less",
        Float.less(1.23, 2.45),
        M.equals(T.bool(true)),
      ),
      test(
        "positive greater",
        Float.less(2.45, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative equal",
        Float.less(-1.23, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative less",
        Float.less(-2.45, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative greater",
        Float.less(-1.23, -2.45),
        M.equals(T.bool(false)),
      ),
      test(
        "positive zeros",
        Float.less(positiveZero, positiveZero),
        M.equals(T.bool(false)),
      ),
      test(
        "negative zeros",
        Float.less(negativeZero, negativeZero),
        M.equals(T.bool(false)),
      ),
      test(
        "positive and negative zero",
        Float.less(positiveZero, negativeZero),
        M.equals(T.bool(false)),
      ),
      test(
        "negative and positive zero",
        Float.less(negativeZero, positiveZero),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed signs less",
        Float.less(-1.23, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed signs greater",
        Float.less(1.23, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "number and positive infinity",
        Float.less(1.23, Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity and number",
        Float.less(Float.positiveInfinity(), 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "number and negative infinity",
        Float.less(1.23, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and number",
        Float.less(Float.negativeInfinity(), 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "double positive infinity",
        Float.less(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive and negative infinity",
        Float.less(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "double negative infinity",
        Float.less(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "negative and positive infinity",
        Float.less(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "two positive NaNs",
        Float.less(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "two negative NaNs",
        Float.less(negativeNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaNs with mixed signs",
        Float.less(positiveNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "number and NaN",
        Float.less(1.23, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and number",
        Float.less(positiveNaN, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and NaN",
        Float.less(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and positive infinity",
        Float.less(positiveNaN, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.less(positiveNaN, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.less(Float.positiveInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.less(Float.negativeInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "lessOrEqual",
    [
      test(
        "positive equal",
        Float.lessOrEqual(1.23, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "positive less",
        Float.lessOrEqual(1.23, 2.45),
        M.equals(T.bool(true)),
      ),
      test(
        "positive greater",
        Float.lessOrEqual(2.45, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative equal",
        Float.lessOrEqual(-1.23, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative less",
        Float.lessOrEqual(-2.45, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative greater",
        Float.lessOrEqual(-1.23, -2.45),
        M.equals(T.bool(false)),
      ),
      test(
        "positive zeros",
        Float.lessOrEqual(positiveZero, positiveZero),
        M.equals(T.bool(true)),
      ),
      test(
        "negative zeros",
        Float.lessOrEqual(negativeZero, negativeZero),
        M.equals(T.bool(true)),
      ),
      test(
        "positive and negative zero",
        Float.lessOrEqual(positiveZero, negativeZero),
        M.equals(T.bool(true)),
      ),
      test(
        "negative and positive zero",
        Float.lessOrEqual(negativeZero, positiveZero),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed signs less",
        Float.lessOrEqual(-1.23, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed signs greater",
        Float.lessOrEqual(1.23, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "number and positive infinity",
        Float.lessOrEqual(1.23, Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity and number",
        Float.lessOrEqual(Float.positiveInfinity(), 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "number and negative infinity",
        Float.lessOrEqual(1.23, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and number",
        Float.lessOrEqual(Float.negativeInfinity(), 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "double positive infinity",
        Float.lessOrEqual(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "positive and negative infinity",
        Float.lessOrEqual(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "double negative infinity",
        Float.lessOrEqual(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "negative and positive infinity",
        Float.lessOrEqual(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "two positive NaNs",
        Float.lessOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "two negative NaNs",
        Float.lessOrEqual(negativeNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaNs with mixed signs",
        Float.lessOrEqual(positiveNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "number and NaN",
        Float.lessOrEqual(1.23, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and number",
        Float.lessOrEqual(positiveNaN, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and NaN",
        Float.lessOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and positive infinity",
        Float.lessOrEqual(positiveNaN, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.lessOrEqual(positiveNaN, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.lessOrEqual(Float.positiveInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.lessOrEqual(Float.negativeInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "greater",
    [
      test(
        "positive equal",
        Float.greater(1.23, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "positive less",
        Float.greater(1.23, 2.45),
        M.equals(T.bool(false)),
      ),
      test(
        "positive greater",
        Float.greater(2.45, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative equal",
        Float.greater(-1.23, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative less",
        Float.greater(-2.45, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative greater",
        Float.greater(-1.23, -2.45),
        M.equals(T.bool(true)),
      ),
      test(
        "positive zeros",
        Float.greater(positiveZero, positiveZero),
        M.equals(T.bool(false)),
      ),
      test(
        "negative zeros",
        Float.greater(negativeZero, negativeZero),
        M.equals(T.bool(false)),
      ),
      test(
        "positive and negative zero",
        Float.greater(positiveZero, negativeZero),
        M.equals(T.bool(false)),
      ),
      test(
        "negative and positive zero",
        Float.greater(negativeZero, positiveZero),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed signs less",
        Float.greater(-1.23, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed signs greater",
        Float.greater(1.23, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "less than positive infinity",
        Float.greater(1.23, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and number",
        Float.greater(Float.positiveInfinity(), 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "number and negative infinity",
        Float.greater(1.23, Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity and number",
        Float.greater(Float.negativeInfinity(), 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "double positive infinity",
        Float.greater(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive and negative infinity",
        Float.greater(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "double negative infinity",
        Float.greater(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "negative and positive infinity",
        Float.greater(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "two positive NaNs",
        Float.greater(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "two negative NaNs",
        Float.greater(negativeNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaNs with mixed signs",
        Float.greater(positiveNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "number and NaN",
        Float.greater(1.23, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and number",
        Float.greater(positiveNaN, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and NaN",
        Float.greater(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and positive infinity",
        Float.greater(positiveNaN, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.greater(positiveNaN, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.greater(Float.positiveInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.greater(Float.negativeInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "greaterOrEqual",
    [
      test(
        "positive equal",
        Float.greaterOrEqual(1.23, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "positive less",
        Float.greaterOrEqual(1.23, 2.45),
        M.equals(T.bool(false)),
      ),
      test(
        "positive greater",
        Float.greaterOrEqual(2.45, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative equal",
        Float.greaterOrEqual(-1.23, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "negative less",
        Float.greaterOrEqual(-2.45, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "negative greater",
        Float.greaterOrEqual(-1.23, -2.45),
        M.equals(T.bool(true)),
      ),
      test(
        "positive zeros",
        Float.greaterOrEqual(positiveZero, positiveZero),
        M.equals(T.bool(true)),
      ),
      test(
        "negative zeros",
        Float.greaterOrEqual(negativeZero, negativeZero),
        M.equals(T.bool(true)),
      ),
      test(
        "positive and negative zero",
        Float.greaterOrEqual(positiveZero, negativeZero),
        M.equals(T.bool(true)),
      ),
      test(
        "negative and positive zero",
        Float.greaterOrEqual(negativeZero, positiveZero),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed signs less",
        Float.greaterOrEqual(-1.23, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed signs greater",
        Float.greaterOrEqual(1.23, -1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "number and positive infinity",
        Float.greaterOrEqual(1.23, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and number",
        Float.greaterOrEqual(Float.positiveInfinity(), 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "number and negative infinity",
        Float.greaterOrEqual(1.23, Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity and number",
        Float.greaterOrEqual(Float.negativeInfinity(), 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "double positive infinity",
        Float.greaterOrEqual(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "positive and negative infinity",
        Float.greaterOrEqual(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "double negative infinity",
        Float.greaterOrEqual(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(T.bool(true)),
      ),
      test(
        "negative and positive infinity",
        Float.greaterOrEqual(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "two positive NaNs",
        Float.greaterOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "two negative NaNs",
        Float.greaterOrEqual(negativeNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaNs with mixed signs",
        Float.greaterOrEqual(positiveNaN, negativeNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "number and NaN",
        Float.greaterOrEqual(1.23, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and number",
        Float.greaterOrEqual(positiveNaN, -1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and NaN",
        Float.greaterOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and positive infinity",
        Float.greaterOrEqual(positiveNaN, Float.positiveInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.greaterOrEqual(positiveNaN, Float.negativeInfinity()),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.greaterOrEqual(Float.positiveInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.greaterOrEqual(Float.negativeInfinity(), positiveNaN),
        M.equals(T.bool(false)),
      ),
    ],
  ),
);

/* --------------------------------------- */

type Order = { #less; #equal; #greater };

class OrderTestable(value : Order) : T.TestableItem<Order> {
  public let item = value;
  public func display(value : Order) : Text {
    debug_show (value);
  };
  public let equals = func(x : Order, y : Order) : Bool {
    x == y;
  };
};

run(
  suite(
    "compare",
    [
      test(
        "positive equal",
        Float.compare(1.23, 1.23),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "positive less",
        Float.compare(1.23, 2.45),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "positive greater",
        Float.compare(2.45, 1.23),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "negative equal",
        Float.compare(-1.23, -1.23),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "negative less",
        Float.compare(-2.45, -1.23),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "negative greater",
        Float.compare(-1.23, -2.45),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "positive zeros",
        Float.compare(positiveZero, positiveZero),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "negative zeros",
        Float.compare(negativeZero, negativeZero),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "positive and negative zero",
        Float.compare(positiveZero, negativeZero),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "negative and positive zero",
        Float.compare(negativeZero, positiveZero),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "mixed signs less",
        Float.compare(-1.23, 1.23),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "mixed signs greater",
        Float.compare(1.23, -1.23),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "number and positive infinity",
        Float.compare(1.23, Float.positiveInfinity()),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "positive infinity and number",
        Float.compare(Float.positiveInfinity(), 1.23),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "number and negative infinity",
        Float.compare(1.23, Float.negativeInfinity()),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "negative infinity and number",
        Float.compare(Float.negativeInfinity(), 1.23),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "double positive infinity",
        Float.compare(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "positive and negative infinity",
        Float.compare(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "double negative infinity",
        Float.compare(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "negative and positive infinity",
        Float.compare(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "two positive NaNs",
        Float.compare(positiveNaN, positiveNaN),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "two negative NaNs",
        Float.compare(negativeNaN, negativeNaN),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "NaNs with mixed signs",
        Float.compare(positiveNaN, negativeNaN),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "number and NaN",
        Float.compare(1.23, positiveNaN),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "NaN and number",
        Float.compare(positiveNaN, -1.23),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "NaN and NaN",
        Float.compare(positiveNaN, positiveNaN),
        M.equals(OrderTestable(#greater)), // Inconsistent, needs to be fixed
      ),
      test(
        "NaN and positive infinity",
        Float.compare(positiveNaN, Float.positiveInfinity()),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "NaN and negative infinity",
        Float.compare(positiveNaN, Float.negativeInfinity()),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "positive infinity and NaN",
        Float.compare(Float.positiveInfinity(), positiveNaN),
        M.equals(OrderTestable(#greater)), // Inconsistent, needs to be fixed
      ),
      test(
        "negative infinity and NaN",
        Float.compare(Float.negativeInfinity(), positiveNaN),
        M.equals(OrderTestable(#greater)), // Inconsistent, needs to be fixed
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "neg",
    [
      test(
        "positive number",
        Float.neg(1.1),
        M.equals(FloatTestable(-1.1, noEpsilon)),
      ),
      test(
        "negative number",
        Float.neg(-1.1),
        M.equals(FloatTestable(1.1, noEpsilon)),
      ),
      test(
        "zero",
        Float.neg(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      // fails due to issue, probably related to https://github.com/dfinity/motoko/issues/3646
      // test(
      //   "positive zero",
      //   Float.neg(positiveZero),
      //   NegativeZeroMatcher(),
      // ),
      test(
        "negative zero",
        Float.neg(negativeZero),
        PositiveZeroMatcher(),
      ),
      test(
        "positive infinity",
        Float.neg(Float.positiveInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.neg(Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive NaN (provisional test)",
        Float.neg(positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative NaN (provisional test)",
        Float.neg(negativeNaN),
        NaNMatcher(),
      ),
      // Not working correctly, probably related to https://github.com/dfinity/motoko/issues/3646
      // test(
      //   "positive NaN",
      //   Float.neg(positiveNaN),
      //   NegativeNaNMatcher(),
      // ),
      // test(
      //   "negative NaN",
      //   Float.neg(negativeNaN),
      //   PositiveNaNMatcher(),
      // ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "add",
    [
      test(
        "positive",
        Float.add(1.23, 1.23),
        M.equals(FloatTestable(2.46, smallEpsilon)),
      ),
      test(
        "negative",
        Float.add(-1.23, -1.23),
        M.equals(FloatTestable(-2.46, smallEpsilon)),
      ),
      test(
        "mixed signs",
        Float.add(-1.23, 2.23),
        M.equals(FloatTestable(1.0, smallEpsilon)),
      ),
      test(
        "positive zeros",
        Float.add(positiveZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "negative zeros",
        Float.add(negativeZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive and negative zero",
        Float.add(positiveZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "negative and positive zero",
        Float.add(negativeZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "number and positive infinity",
        Float.add(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and number",
        Float.add(Float.positiveInfinity(), -1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "number and negative infinity",
        Float.add(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and number",
        Float.add(Float.negativeInfinity(), 1.23),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.add(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.add(Float.positiveInfinity(), Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "double negative infinity",
        Float.add(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.add(Float.negativeInfinity(), Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "two positive NaNs",
        Float.add(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "two negative NaNs",
        Float.add(negativeNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaNs with mixed signs",
        Float.add(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "number and NaN",
        Float.add(1.23, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and number",
        Float.add(positiveNaN, -1.23),
        NaNMatcher(),
      ),
      test(
        "NaN and NaN",
        Float.add(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.add(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.add(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.add(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.add(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "sub",
    [
      test(
        "positive",
        Float.sub(1.23, 2.34),
        M.equals(FloatTestable(-1.11, smallEpsilon)),
      ),
      test(
        "negative",
        Float.sub(-1.23, -2.34),
        M.equals(FloatTestable(1.11, smallEpsilon)),
      ),
      test(
        "mixed signs",
        Float.sub(-1.23, 2.34),
        M.equals(FloatTestable(-3.57, smallEpsilon)),
      ),
      test(
        "positive zeros",
        Float.sub(positiveZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "negative zeros",
        Float.sub(negativeZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive and negative zero",
        Float.sub(positiveZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "negative and positive zero",
        Float.sub(negativeZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "number and positive infinity",
        Float.sub(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and number",
        Float.sub(Float.positiveInfinity(), -1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "number and negative infinity",
        Float.sub(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and number",
        Float.sub(Float.negativeInfinity(), 1.23),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.sub(Float.positiveInfinity(), Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive and negative infinity",
        Float.sub(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.sub(Float.negativeInfinity(), Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative and positive infinity",
        Float.sub(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "two positive NaNs",
        Float.sub(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "two negative NaNs",
        Float.sub(negativeNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaNs with mixed signs",
        Float.sub(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "number and NaN",
        Float.sub(1.23, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and number",
        Float.sub(positiveNaN, -1.23),
        NaNMatcher(),
      ),
      test(
        "NaN and NaN",
        Float.sub(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.sub(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.sub(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.sub(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.sub(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "mul",
    [
      test(
        "positive",
        Float.mul(1.23, 2.34),
        M.equals(FloatTestable(2.8782, smallEpsilon)),
      ),
      test(
        "negative",
        Float.mul(-1.23, -2.34),
        M.equals(FloatTestable(2.8782, smallEpsilon)),
      ),
      test(
        "mixed signs",
        Float.mul(-1.23, 2.34),
        M.equals(FloatTestable(-2.8782, smallEpsilon)),
      ),
      test(
        "positive zeros",
        Float.mul(positiveZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "negative zeros",
        Float.mul(negativeZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive and negative zero",
        Float.mul(positiveZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "negative and positive zero",
        Float.mul(negativeZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive number and positive infinity",
        Float.mul(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative number and positive infinity",
        Float.mul(-1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "zero and positive infinity",
        Float.mul(0.0, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and positive number",
        Float.mul(Float.positiveInfinity(), 1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and negative number",
        Float.mul(Float.positiveInfinity(), -1.23),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and zero",
        Float.mul(Float.positiveInfinity(), 0.0),
        NaNMatcher(),
      ),
      test(
        "positive number and negative infinity",
        Float.mul(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative number and negative infinity",
        Float.mul(-1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "zero and negative infinity",
        Float.mul(0.0, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative infinity and positive number",
        Float.mul(Float.negativeInfinity(), 1.23),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and negative number",
        Float.mul(Float.negativeInfinity(), -1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and zero",
        Float.mul(Float.negativeInfinity(), 0.0),
        NaNMatcher(),
      ),
      test(
        "double positive infinity",
        Float.mul(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.mul(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.mul(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.mul(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "two positive NaNs",
        Float.mul(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "two negative NaNs",
        Float.mul(negativeNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaNs with mixed signs",
        Float.mul(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "number and NaN",
        Float.mul(1.23, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "zero and NaN",
        Float.mul(0.0, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and number",
        Float.mul(positiveNaN, -1.23),
        NaNMatcher(),
      ),
      test(
        "NaN and zero",
        Float.mul(positiveNaN, 0.0),
        NaNMatcher(),
      ),
      test(
        "NaN and NaN",
        Float.mul(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.mul(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.mul(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.mul(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.mul(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "div",
    [
      test(
        "positive",
        Float.div(1.23, 2.34),
        M.equals(FloatTestable(0.525641025641026, smallEpsilon)),
      ),
      test(
        "negative",
        Float.div(-1.23, -2.34),
        M.equals(FloatTestable(0.525641025641026, smallEpsilon)),
      ),
      test(
        "mixed signs",
        Float.div(-1.23, 2.34),
        M.equals(FloatTestable(-0.525641025641026, smallEpsilon)),
      ),
      test(
        "positive zeros",
        Float.div(positiveZero, positiveZero),
        NaNMatcher(),
      ),
      test(
        "negative zeros",
        Float.div(negativeZero, negativeZero),
        NaNMatcher(),
      ),
      test(
        "positive and negative zero",
        Float.div(positiveZero, negativeZero),
        NaNMatcher(),
      ),
      test(
        "negative and positive zero",
        Float.div(negativeZero, positiveZero),
        NaNMatcher(),
      ),
      test(
        "positive number and positive infinity",
        Float.div(1.23, Float.positiveInfinity()),
        PositiveZeroMatcher(),
      ),
      test(
        "negative number and positive infinity",
        Float.div(-1.23, Float.positiveInfinity()),
        NegativeZeroMatcher(),
      ),
      test(
        "positive infinity and negative number",
        Float.div(Float.positiveInfinity(), -1.23),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and zero",
        Float.div(Float.positiveInfinity(), 0.0),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and positive number",
        Float.div(Float.positiveInfinity(), 1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive number and negative infinity",
        Float.div(1.23, Float.negativeInfinity()),
        NegativeZeroMatcher(),
      ),
      test(
        "negative number and negative infinity",
        Float.div(-1.23, Float.negativeInfinity()),
        PositiveZeroMatcher(),
      ),
      test(
        "negative infinity and positive number",
        Float.div(Float.negativeInfinity(), 1.23),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and negative number",
        Float.div(Float.negativeInfinity(), -1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and zero",
        Float.div(Float.negativeInfinity(), 0.0),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.div(Float.positiveInfinity(), Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive and negative infinity",
        Float.div(Float.positiveInfinity(), Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "double negative infinity",
        Float.div(Float.negativeInfinity(), Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative and positive infinity",
        Float.div(Float.negativeInfinity(), Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "two positive NaNs",
        Float.div(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "two negative NaNs",
        Float.div(negativeNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaNs with mixed signs",
        Float.div(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "number and NaN",
        Float.div(1.23, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and number",
        Float.div(positiveNaN, -1.23),
        NaNMatcher(),
      ),
      test(
        "NaN and NaN",
        Float.div(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.div(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.div(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.div(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.div(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "rem",
    [
      test(
        "positive quotient, positive divisor",
        Float.rem(7.2, 2.3),
        M.equals(FloatTestable(0.3, smallEpsilon)),
      ),
      test(
        "positive quotient, negative divisor",
        Float.rem(7.2, -2.3),
        M.equals(FloatTestable(0.3, smallEpsilon)),
      ),
      test(
        "negative quotient, positive divisor",
        Float.rem(-8.2, 3.12),
        M.equals(FloatTestable(-1.96, smallEpsilon)),
      ),
      test(
        "negative quotient, negative divisor",
        Float.rem(-8.2, -3.12),
        M.equals(FloatTestable(-1.96, smallEpsilon)),
      ),
      test(
        "positive zeros",
        Float.rem(positiveZero, positiveZero),
        NaNMatcher(),
      ),
      test(
        "negative zeros",
        Float.rem(negativeZero, negativeZero),
        NaNMatcher(),
      ),
      test(
        "positive and negative zero",
        Float.rem(positiveZero, negativeZero),
        NegativeNaNMatcher(),
      ),
      test(
        "negative and positive zero",
        Float.rem(negativeZero, positiveZero),
        NegativeNaNMatcher(),
      ),
      test(
        "positive number and positive infinity",
        Float.rem(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "negative number and positive infinity",
        Float.rem(-1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(-1.23, noEpsilon)),
      ),
      test(
        "zero and positive infinity",
        Float.rem(0.0, Float.positiveInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive infinity and positive number",
        Float.rem(Float.positiveInfinity(), 1.23),
        NaNMatcher(),
      ),
      test(
        "positive infinity and negative number",
        Float.rem(Float.positiveInfinity(), -1.23),
        NaNMatcher(),
      ),
      test(
        "positive infinity and zero",
        Float.rem(Float.positiveInfinity(), 0.0),
        NaNMatcher(),
      ),
      test(
        "positive number and negative infinity",
        Float.rem(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "negative number and negative infinity",
        Float.rem(-1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(-1.23, noEpsilon)),
      ),
      test(
        "zero and negative infinity",
        Float.rem(0.0, Float.negativeInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative infinity and positive number",
        Float.rem(Float.negativeInfinity(), 1.23),
        NaNMatcher(),
      ),
      test(
        "negative infinity and negative number",
        Float.rem(Float.negativeInfinity(), -1.23),
        NaNMatcher(),
      ),
      test(
        "negative infinity and zero",
        Float.rem(Float.negativeInfinity(), 0.0),
        NaNMatcher(),
      ),
      test(
        "double positive infinity",
        Float.rem(Float.positiveInfinity(), Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive and negative infinity",
        Float.rem(Float.positiveInfinity(), Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "double negative infinity",
        Float.rem(Float.negativeInfinity(), Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "negative and positive infinity",
        Float.rem(Float.negativeInfinity(), Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "two positive NaNs",
        Float.rem(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "two negative NaNs",
        Float.rem(negativeNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaNs with mixed signs",
        Float.rem(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "number and NaN",
        Float.rem(1.23, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and number",
        Float.rem(positiveNaN, -1.23),
        NaNMatcher(),
      ),
      test(
        "NaN and NaN",
        Float.rem(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and positive infinity",
        Float.rem(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative infinity",
        Float.rem(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "positive infinity and NaN",
        Float.rem(Float.positiveInfinity(), positiveNaN),
        NaNMatcher(),
      ),
      test(
        "negative infinity and NaN",
        Float.rem(Float.negativeInfinity(), positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);

/* --------------------------------------- */

run(
  suite(
    "pow",
    [
      test(
        "positive base, positive integral exponent",
        Float.pow(7.2, 3.0),
        M.equals(FloatTestable(373.248, smallEpsilon)),
      ),
      test(
        "positive base, positive non-integral exponent",
        Float.pow(7.2, 3.2),
        M.equals(FloatTestable(553.941609551155657, smallEpsilon)),
      ),
      test(
        "positive base, zero exponent",
        Float.pow(7.2, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "positive base, negative integral exponent",
        Float.pow(7.2, -3.0),
        M.equals(FloatTestable(0.002679183813443, smallEpsilon)),
      ),
      test(
        "positive base, negative non-integral exponent",
        Float.pow(7.2, -3.2),
        M.equals(FloatTestable(0.001805244420635, smallEpsilon)),
      ),
      test(
        "negative base, positive integral exponent",
        Float.pow(-7.2, 3.0),
        M.equals(FloatTestable(-373.248, smallEpsilon)),
      ),
      test(
        "negative base, positive non-integral exponent",
        Float.pow(-7.2, 3.2),
        NaNMatcher(),
      ),
      test(
        "negative base, zero exponent",
        Float.pow(-7.2, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "negative base, negative integral exponent",
        Float.pow(-7.2, -3.0),
        M.equals(FloatTestable(-0.002679183813443, smallEpsilon)),
      ),
      test(
        "negative base, negative non-integral exponent",
        Float.pow(-7.2, -3.2),
        NaNMatcher(),
      ),
      test(
        "positive zeros",
        Float.pow(positiveZero, positiveZero),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "negative zeros",
        Float.pow(negativeZero, negativeZero),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "positive and negative zero",
        Float.pow(positiveZero, negativeZero),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "negative and positive zero",
        Float.pow(negativeZero, positiveZero),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "positive number and positive infinity",
        Float.pow(1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "zero and positive infinity",
        Float.pow(0.0, Float.positiveInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative number and positive infinity",
        Float.pow(-1.23, Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and positive number",
        Float.pow(Float.positiveInfinity(), 1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive infinity and negative number",
        Float.pow(Float.positiveInfinity(), -0.1),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive infinity and zero",
        Float.pow(Float.positiveInfinity(), 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "positive number and negative infinity",
        Float.pow(1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative number and negative infinity",
        Float.pow(-1.23, Float.negativeInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "zero and negative infinity",
        Float.pow(0.0, Float.negativeInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and positive odd positive number",
        Float.pow(Float.negativeInfinity(), 3.0),
        M.equals(FloatTestable(Float.negativeInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and positive odd negative number",
        Float.pow(Float.negativeInfinity(), -3.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative infinity and positive even positive number",
        Float.pow(Float.negativeInfinity(), 4.0),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and positive even negative number",
        Float.pow(Float.negativeInfinity(), -4.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative infinity and zero",
        Float.pow(Float.negativeInfinity(), 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "negative infinity and non-integral positive number",
        Float.pow(Float.negativeInfinity(), 1.23),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "negative infinity and non-integral negative number",
        Float.pow(Float.negativeInfinity(), -1.23),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.pow(Float.positiveInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.pow(Float.positiveInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.pow(Float.negativeInfinity(), Float.negativeInfinity()),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.pow(Float.negativeInfinity(), Float.positiveInfinity()),
        M.equals(FloatTestable(Float.positiveInfinity(), noEpsilon)),
      ),
      test(
        "two positive NaNs",
        Float.pow(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "two negative NaNs",
        Float.pow(negativeNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "NaNs with mixed signs",
        Float.pow(positiveNaN, negativeNaN),
        NaNMatcher(),
      ),
      test(
        "number and NaN",
        Float.pow(1.23, positiveNaN),
        NaNMatcher(),
      ),
      test(
        "NaN and number",
        Float.pow(positiveNaN, 2.0),
        NaNMatcher(),
      ),
      test(
        "NaN and zero",
        Float.pow(positiveNaN, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "NaN and positive infinity",
        Float.pow(positiveNaN, Float.positiveInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and negative Infinity",
        Float.pow(positiveNaN, Float.negativeInfinity()),
        NaNMatcher(),
      ),
      test(
        "NaN and NaN",
        Float.pow(positiveNaN, positiveNaN),
        NaNMatcher(),
      ),
    ],
  ),
);
