// @testmode wasi

import Debug "mo:base/Debug";
import Float "mo:base/Float";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class FloatTestable(number : Float, epsilon : Float) : T.TestableItem<Float> {
  public let item = number;
  public func display(number : Float) : Text {
    debug_show (number)
  };
  public let equals = func(x : Float, y : Float) : Bool {
    if (epsilon == 0.0) {
      x == y // to also test Float.abs()
    } else {
      Float.abs(x - y) < epsilon
    }
  }
};

class Int64Testable(number : Int64) : T.TestableItem<Int64> {
  public let item = number;
  public func display(number : Int64) : Text {
    debug_show (number)
  };
  public let equals = func(x : Int64, y : Int64) : Bool {
    x == y
  }
};

let positiveInfinity = 1.0 / 0.0;
let negativeInfinity = -1.0 / 0.0;

// Wasm specification: NaN signs are non-deterministic unless resulting from `copySign`, `abs`, or `neg`.
// With the NaN canonicalization mode, we get deterministic results for the NaN sign bit although it may
// be different to the expected result for floating point operations other than the ones mentioned before,
// e.g. `-0.0/0.0` results in a positive NaN with that canonicalization mode in wasmtime.
let positiveNaN = Float.copySign(0.0 / 0.0, 1.0);
let negativeNaN = Float.copySign(0.0 / 0.0, -1.0);

func isPositiveNaN(number : Float) : Bool {
  Float.isNaN(number) and Float.copySign(1.0, number) == 1.0
};

func isNegativeNaN(number : Float) : Bool {
  Float.isNaN(number) and Float.copySign(1.0, number) == -1.0
};

let positiveZero = 0.0;
let negativeZero = Float.copySign(0.0, -1.0); // Compiler bug, cannot use literal `-0.0`. https://github.com/dfinity/motoko/issues/3646

func isPositiveZero(number : Float) : Bool {
  number == 0.0 and 1.0 / number == positiveInfinity
};

func isNegativeZero(number : Float) : Bool {
  number == 0.0 and 1.0 / number == negativeInfinity
};

class PositiveZeroMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be '0.0' (positive zero)")
  };

  public func matches(number : Float) : Bool {
    isPositiveZero(number)
  }
};

class NegativeZeroMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be '-0.0' (negative zero)")
  };

  public func matches(number : Float) : Bool {
    isNegativeZero(number)
  }
};

let noEpsilon = 0.0;
let smallEpsilon = 1e-6;

class NaNMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be 'NaN' or '-NaN'")
  };

  public func matches(number : Float) : Bool {
    Float.isNaN(number)
  }
};

class PositiveNaNMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be 'NaN' (positive)")
  };

  public func matches(number : Float) : Bool {
    isPositiveNaN(number)
  }
};

class NegativeNaNMatcher() : M.Matcher<Float> {
  public func describeMismatch(number : Float, description : M.Description) {
    Debug.print(debug_show (number) # " should be '-NaN' (negative)")
  };

  public func matches(number : Float) : Bool {
    isNegativeNaN(number)
  }
};

// Some tests are adopted from Motoko compiler test `float-ops.mo`.

/* --------------------------------------- */

run(
  suite(
    "constant functions",
    [
      test(
        "positive infinity",
        positiveInfinity,
        M.equals(FloatTestable(1.0 / 0.0, noEpsilon))
      ),
      test(
        "negative infinity",
        negativeInfinity,
        M.equals(FloatTestable(-1.0 / 0.0, noEpsilon))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "isNaN",
    [
      test(
        "positive NaN",
        Float.isNaN(positiveNaN),
        M.equals(T.bool(true))
      ),
      test(
        "negative NaN",
        Float.isNaN(negativeNaN),
        M.equals(T.bool(true))
      ),
      test(
        "positive number",
        Float.isNaN(1.1),
        M.equals(T.bool(false))
      ),
      test(
        "negative number",
        Float.isNaN(-1.1),
        M.equals(T.bool(false))
      ),
      test(
        "zero",
        Float.isNaN(0.0),
        M.equals(T.bool(false))
      ),
      test(
        "positive zero",
        Float.isNaN(positiveZero),
        M.equals(T.bool(false))
      ),
      test(
        "negative zero",
        Float.isNaN(negativeZero),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity",
        Float.isNaN(positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity",
        Float.isNaN(negativeInfinity),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "abs",
    [
      test(
        "positive number",
        Float.abs(1.1),
        M.equals(FloatTestable(1.1, noEpsilon))
      ),
      test(
        "negative number",
        Float.abs(-1.1),
        M.equals(FloatTestable(1.1, noEpsilon))
      ),
      test(
        "zero",
        Float.abs(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive zero",
        Float.abs(positiveZero),
        PositiveZeroMatcher()
      ),
      test(
        "negative zero",
        Float.abs(negativeZero),
        PositiveZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.abs(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.abs(negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive NaN",
        Float.abs(positiveNaN),
        PositiveNaNMatcher()
      ),
      test(
        "negative NaN",
        Float.abs(negativeNaN),
        PositiveNaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "sqrt",
    [
      test(
        "positive number",
        Float.sqrt(6.25),
        M.equals(FloatTestable(2.5, noEpsilon))
      ),
      test(
        "zero",
        Float.sqrt(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive zero",
        Float.sqrt(positiveZero),
        PositiveZeroMatcher()
      ),
      test(
        "negative zero",
        Float.sqrt(negativeZero),
        NegativeZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.sqrt(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative",
        Float.sqrt(-16.0),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.sqrt(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.sqrt(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "ceil",
    [
      test(
        "positive fraction",
        Float.ceil(1.1),
        M.equals(FloatTestable(2.0, noEpsilon))
      ),
      test(
        "negative fraction",
        Float.ceil(-1.2),
        M.equals(FloatTestable(-1.0, noEpsilon))
      ),
      test(
        "integral number",
        Float.ceil(-3.0),
        M.equals(FloatTestable(-3.0, noEpsilon))
      ),
      test(
        "zero",
        Float.ceil(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive zero",
        Float.ceil(positiveZero),
        PositiveZeroMatcher()
      ),
      test(
        "negative zero",
        Float.ceil(negativeZero),
        NegativeZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.ceil(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.ceil(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive NaN",
        Float.ceil(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.ceil(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "floor",
    [
      test(
        "positive fraction",
        Float.floor(1.1),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "negative fraction",
        Float.floor(-1.2),
        M.equals(FloatTestable(-2.0, noEpsilon))
      ),
      test(
        "integral number",
        Float.floor(3.0),
        M.equals(FloatTestable(3.0, noEpsilon))
      ),
      test(
        "zero",
        Float.floor(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive zero",
        Float.floor(positiveZero),
        PositiveZeroMatcher()
      ),
      test(
        "negative zero",
        Float.floor(negativeZero),
        NegativeZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.floor(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.floor(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive NaN",
        Float.floor(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.floor(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "trunc",
    [
      test(
        "positive fraction",
        Float.trunc(3.9123),
        M.equals(FloatTestable(3.0, noEpsilon))
      ),
      test(
        "negative fraction",
        Float.trunc(-3.9123),
        M.equals(FloatTestable(-3.0, noEpsilon))
      ),
      test(
        "integral number",
        Float.trunc(3.0),
        M.equals(FloatTestable(3.0, noEpsilon))
      ),
      test(
        "zero",
        Float.trunc(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive zero",
        Float.trunc(positiveZero),
        PositiveZeroMatcher()
      ),
      test(
        "negative zero",
        Float.trunc(negativeZero),
        NegativeZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.trunc(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.trunc(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive NaN",
        Float.trunc(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.trunc(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "floor",
    [
      test(
        "positive round up",
        Float.nearest(3.75),
        M.equals(FloatTestable(4.0, noEpsilon))
      ),
      test(
        "negative round down",
        Float.nearest(-3.75),
        M.equals(FloatTestable(-4.0, noEpsilon))
      ),
      test(
        "positive round down",
        Float.nearest(3.25),
        M.equals(FloatTestable(3.0, noEpsilon))
      ),
      test(
        "negative round up",
        Float.nearest(-3.25),
        M.equals(FloatTestable(-3.0, noEpsilon))
      ),
      test(
        "positive .5",
        Float.nearest(3.5),
        M.equals(FloatTestable(4.0, noEpsilon))
      ),
      test(
        "negative .5",
        Float.nearest(-3.5),
        M.equals(FloatTestable(-4.0, noEpsilon))
      ),
      test(
        "integral number",
        Float.nearest(3.0),
        M.equals(FloatTestable(3.0, noEpsilon))
      ),
      test(
        "positive infinity",
        Float.nearest(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.nearest(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive NaN",
        Float.nearest(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.nearest(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "copySign",
    [
      test(
        "both positive",
        Float.copySign(1.2, 2.3),
        M.equals(FloatTestable(1.2, noEpsilon))
      ),
      test(
        "positive, negative",
        Float.copySign(1.2, -2.3),
        M.equals(FloatTestable(-1.2, noEpsilon))
      ),
      test(
        "both negative",
        Float.copySign(-1.2, -2.3),
        M.equals(FloatTestable(-1.2, noEpsilon))
      ),
      test(
        "negative, positive",
        Float.copySign(-1.2, 2.3),
        M.equals(FloatTestable(1.2, noEpsilon))
      ),
      test(
        "negate positive zero",
        Float.copySign(0.0, -1),
        NegativeZeroMatcher()
      ),
      test(
        "keep positive zero",
        Float.copySign(0.0, 1),
        PositiveZeroMatcher()
      ),
      test(
        "negate by negative zero",
        Float.copySign(2.1, negativeZero),
        M.equals(FloatTestable(-2.1, noEpsilon))
      ),
      test(
        "positive infinity",
        Float.copySign(1.2, positiveInfinity),
        M.equals(FloatTestable(1.2, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.copySign(1.2, negativeInfinity),
        M.equals(FloatTestable(-1.2, noEpsilon))
      ),
      test(
        "keep positive NaN",
        Float.copySign(positiveNaN, 1.0),
        PositiveNaNMatcher()
      ),
      test(
        "negate positive NaN",
        Float.copySign(positiveNaN, -1.0),
        NegativeNaNMatcher()
      ),
      test(
        "keep negative NaN",
        Float.copySign(negativeNaN, -1.0),
        NegativeNaNMatcher()
      ),
      test(
        "negate negative NaN",
        Float.copySign(negativeNaN, 1.0),
        PositiveNaNMatcher()
      ),
      test(
        "second argument positive NaN",
        Float.copySign(-1.2, positiveNaN),
        M.equals(FloatTestable(1.2, noEpsilon))
      ),
      test(
        "second argument negative NaN",
        Float.copySign(1.2, negativeNaN),
        M.equals(FloatTestable(-1.2, noEpsilon))
      ),
      test(
        "both NaN",
        Float.copySign(negativeNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.copySign(positiveNaN, positiveInfinity),
        PositiveNaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.copySign(positiveNaN, negativeInfinity),
        NegativeNaNMatcher()
      ),
      test(
        "positive infinity and positive NaN",
        Float.copySign(positiveInfinity, positiveNaN),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive infinity and negative NaN",
        Float.copySign(positiveInfinity, negativeNaN),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative infinity and positive NaN",
        Float.copySign(negativeInfinity, positiveNaN),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and negative NaN",
        Float.copySign(negativeInfinity, negativeNaN),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "min",
    [
      test(
        "both positive",
        Float.min(1.2, 2.3),
        M.equals(FloatTestable(1.2, noEpsilon))
      ),
      test(
        "positive, negative",
        Float.min(1.2, -2.3),
        M.equals(FloatTestable(-2.3, noEpsilon))
      ),
      test(
        "both negative",
        Float.min(-1.2, -2.3),
        M.equals(FloatTestable(-2.3, noEpsilon))
      ),
      test(
        "negative, positive",
        Float.min(-1.2, 2.3),
        M.equals(FloatTestable(-1.2, noEpsilon))
      ),
      test(
        "equal values",
        Float.min(1.23, 1.23),
        M.equals(FloatTestable(1.23, noEpsilon))
      ),
      test(
        "zero with different signs",
        Float.min(positiveZero, negativeZero),
        NegativeZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.min(1.23, positiveInfinity),
        M.equals(FloatTestable(1.23, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.min(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "double negative infinity",
        Float.min(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "left NaN",
        Float.min(positiveNaN, 1.0),
        NaNMatcher()
      ),
      test(
        "right NaN",
        Float.min(-1.0, positiveNaN),
        NaNMatcher()
      ),
      test(
        "both NaN",
        Float.min(negativeNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.min(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.min(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.min(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.min(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "max",
    [
      test(
        "both positive",
        Float.max(1.2, 2.3),
        M.equals(FloatTestable(2.3, noEpsilon))
      ),
      test(
        "positive, negative",
        Float.max(1.2, -2.3),
        M.equals(FloatTestable(1.2, noEpsilon))
      ),
      test(
        "both negative",
        Float.max(-1.2, -2.3),
        M.equals(FloatTestable(-1.2, noEpsilon))
      ),
      test(
        "negative, positive",
        Float.max(-1.2, 2.3),
        M.equals(FloatTestable(2.3, noEpsilon))
      ),
      test(
        "equal values",
        Float.max(1.23, 1.23),
        M.equals(FloatTestable(1.23, noEpsilon))
      ),
      test(
        "zero with different signs",
        Float.max(positiveZero, negativeZero),
        PositiveZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.max(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.max(1.23, negativeInfinity),
        M.equals(FloatTestable(1.23, noEpsilon))
      ),
      test(
        "double positive infinity",
        Float.max(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "left NaN",
        Float.max(positiveNaN, 1.0),
        NaNMatcher()
      ),
      test(
        "right NaN",
        Float.max(-1.0, positiveNaN),
        NaNMatcher()
      ),
      test(
        "both NaN",
        Float.max(negativeNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.max(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.max(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.max(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.max(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
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
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "90 degrees",
        Float.sin(ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon))
      ),
      test(
        "180 degrees",
        Float.sin(2 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "270 degrees",
        Float.sin(3 * ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon))
      ),
      test(
        "360 degrees",
        Float.sin(4 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "-90 degrees",
        Float.sin(-ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon))
      ),
      test(
        "-180 degrees",
        Float.sin(-2 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "-270 degrees",
        Float.sin(-3 * ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon))
      ),
      test(
        "-360 degrees",
        Float.sin(-4 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "positive infinity",
        Float.sin(positiveInfinity),
        NaNMatcher()
      ),
      test(
        "negative infinity",
        Float.sin(negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.sin(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.sin(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "cos",
    [
      test(
        "zero",
        Float.cos(0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "90 degrees",
        Float.cos(ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "180 degrees",
        Float.cos(2 * ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon))
      ),
      test(
        "270 degrees",
        Float.cos(3 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "360 degrees",
        Float.cos(4 * ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon))
      ),
      test(
        "-90 degrees",
        Float.cos(-ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "-180 degrees",
        Float.cos(-2 * ninetyDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon))
      ),
      test(
        "-270 degrees",
        Float.cos(-3 * ninetyDegrees),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "-360 degrees",
        Float.cos(-4 * ninetyDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon))
      ),
      test(
        "positive infinity",
        Float.cos(positiveInfinity),
        NaNMatcher()
      ),
      test(
        "negative infinity",
        Float.cos(negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.cos(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.cos(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "tan",
    [
      test(
        "zero",
        Float.tan(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "45 degrees",
        Float.tan(fortyFiveDegrees),
        M.equals(FloatTestable(1.0, smallEpsilon))
      ),
      test(
        "-45 degrees",
        Float.tan(-fortyFiveDegrees),
        M.equals(FloatTestable(-1.0, smallEpsilon))
      ),
      test(
        "positive infinity",
        Float.tan(positiveInfinity),
        NaNMatcher()
      ),
      test(
        "negative infinity",
        Float.tan(negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.tan(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.tan(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "arcsin",
    [
      test(
        "zero",
        Float.arcsin(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "90 degrees",
        Float.arcsin(1.0),
        M.equals(FloatTestable(ninetyDegrees, smallEpsilon))
      ),
      test(
        "-90 degrees",
        Float.arcsin(-1.0),
        M.equals(FloatTestable(-ninetyDegrees, smallEpsilon))
      ),
      test(
        "arbitrary angle",
        Float.arcsin(Float.sin(arbitraryAngle)),
        M.equals(FloatTestable(arbitraryAngle, smallEpsilon))
      ),
      test(
        "above 1",
        Float.arcsin(1.01),
        NaNMatcher()
      ),
      test(
        "below 1",
        Float.arcsin(-1.01),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.arcsin(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.arcsin(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "arccos",
    [
      test(
        "zero",
        Float.arccos(0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon))
      ),
      test(
        "90 degrees",
        Float.arccos(1.0),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "180 degrees",
        Float.arccos(-1.0),
        M.equals(FloatTestable(2 * ninetyDegrees, smallEpsilon))
      ),
      test(
        "arbitrary angle",
        Float.arccos(Float.cos(arbitraryAngle)),
        M.equals(FloatTestable(arbitraryAngle, smallEpsilon))
      ),
      test(
        "above 1",
        Float.arccos(1.01),
        NaNMatcher()
      ),
      test(
        "below 1",
        Float.arccos(-1.01),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.arccos(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.arccos(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "arctan",
    [
      test(
        "zero",
        Float.arctan(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "45 degrees",
        Float.arctan(1.0),
        M.equals(FloatTestable(fortyFiveDegrees, smallEpsilon))
      ),
      test(
        "-45 degrees",
        Float.arctan(-1.0),
        M.equals(FloatTestable(-fortyFiveDegrees, smallEpsilon))
      ),
      test(
        "arbitrary angle",
        Float.arctan(Float.tan(arbitraryAngle)),
        M.equals(FloatTestable(arbitraryAngle, smallEpsilon))
      ),
      test(
        "positive infinity",
        Float.arctan(positiveInfinity),
        M.equals(FloatTestable(ninetyDegrees, smallEpsilon))
      ),
      test(
        "negative infinity",
        Float.arctan(negativeInfinity),
        M.equals(FloatTestable(-ninetyDegrees, smallEpsilon))
      ),
      test(
        "positive NaN",
        Float.arctan(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.arctan(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "arctan2",
    [
      test(
        "zero",
        Float.arctan2(0.0, 0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "left negative zero",
        Float.arctan2(negativeZero, 0.0),
        NegativeZeroMatcher()
      ),
      test(
        "right negative zero",
        Float.arctan2(0.0, negativeZero),
        M.equals(FloatTestable(2 * ninetyDegrees, noEpsilon))
      ),
      test(
        "two negative zero",
        Float.arctan2(negativeZero, negativeZero),
        M.equals(FloatTestable(-2 * ninetyDegrees, noEpsilon))
      ),
      test(
        "90 degrees",
        Float.arctan2(1.0, 0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon))
      ),
      test(
        "-90 degrees",
        Float.arctan2(-1.0, 0.0),
        M.equals(FloatTestable(-ninetyDegrees, noEpsilon))
      ),
      test(
        "45 degrees",
        Float.arctan2(sqrt2over2, sqrt2over2),
        M.equals(FloatTestable(fortyFiveDegrees, noEpsilon))
      ),
      test(
        "-45 degrees",
        Float.arctan2(-sqrt2over2, sqrt2over2),
        M.equals(FloatTestable(-fortyFiveDegrees, noEpsilon))
      ),
      test(
        "left positive infinity",
        Float.arctan2(positiveInfinity, 0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon))
      ),
      test(
        "left negative infinity",
        Float.arctan2(negativeInfinity, 0.0),
        M.equals(FloatTestable(-ninetyDegrees, noEpsilon))
      ),
      test(
        "right positive infinity",
        Float.arctan2(0.0, positiveInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "right negative infinity",
        Float.arctan2(0.0, negativeInfinity),
        M.equals(FloatTestable(2 * ninetyDegrees, noEpsilon))
      ),
      test(
        "both positive infinity",
        Float.arctan2(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(fortyFiveDegrees, noEpsilon))
      ),
      test(
        "both negative infinity",
        Float.arctan2(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(-3 * fortyFiveDegrees, noEpsilon))
      ),
      test(
        "positive and negative infinity",
        Float.arctan2(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(3 * fortyFiveDegrees, noEpsilon))
      ),
      test(
        "negative and positive infinity",
        Float.arctan2(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(-fortyFiveDegrees, noEpsilon))
      ),
      test(
        "left positive NaN",
        Float.arctan2(positiveNaN, 0.0),
        NaNMatcher()
      ),
      test(
        "left negative NaN",
        Float.arctan2(negativeNaN, 0.0),
        NaNMatcher()
      ),
      test(
        "right positive NaN",
        Float.arctan2(0.0, positiveNaN),
        NaNMatcher()
      ),
      test(
        "left negative NaN",
        Float.arctan2(0.0, negativeNaN),
        NaNMatcher()
      ),
      test(
        "two NaNs",
        Float.arctan2(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.arctan2(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.arctan2(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.arctan2(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.arctan2(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "exp",
    [
      test(
        "zero",
        Float.exp(0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "one",
        Float.exp(1.0),
        M.equals(FloatTestable(Float.e, smallEpsilon))
      ),
      test(
        "positive infinity",
        Float.exp(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.exp(negativeInfinity),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "positive NaN",
        Float.exp(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.exp(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "log",
    [
      test(
        "one",
        Float.log(1.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "e",
        Float.log(Float.e),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "arbitrary number",
        Float.log(Float.exp(1.23)),
        M.equals(FloatTestable(1.23, smallEpsilon))
      ),
      test(
        "zero",
        Float.log(0.0),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative zero",
        Float.log(negativeZero),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative",
        Float.log(-0.01),
        NaNMatcher()
      ),
      test(
        "positive infinity",
        Float.log(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive NaN",
        Float.log(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN",
        Float.log(negativeNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

// TODO: Support in 64-bit
// run(
//   suite(
//     "format",
//     [
//       test(
//         "exact positive",
//         Float.format(#exact, 20.12345678901),
//         M.equals(T.text("20.12345678901"))
//       ),
//       test(
//         "exact negative",
//         Float.format(#exact, -20.12345678901),
//         M.equals(T.text("-20.12345678901"))
//       ),
//       test(
//         "exact positive zero",
//         Float.format(#exact, positiveZero),
//         M.equals(T.text("0"))
//       ),
//       test(
//         "exact negative zero",
//         Float.format(#exact, negativeZero),
//         M.equals(T.text("-0"))
//       ),
//       test(
//         "exact positive infinity",
//         Float.format(#exact, positiveInfinity),
//         M.equals(T.text("inf"))
//       ),
//       test(
//         "exact negative infinity",
//         Float.format(#exact, negativeInfinity),
//         M.equals(T.text("-inf"))
//       ),
//       test(
//         "exact positive NaN",
//         Float.format(#exact, positiveNaN),
//         M.equals(T.text("nan"))
//       ),
//       test(
//         "exact negative NaN",
//         Float.format(#exact, negativeNaN),
//         M.equals(T.text("-nan"))
//       ),
//       test(
//         "fix positive",
//         Float.format(#fix 6, 20.12345678901),
//         M.equals(T.text("20.123457"))
//       ),
//       test(
//         "fix negative",
//         Float.format(#fix 6, -20.12345678901),
//         M.equals(T.text("-20.123457"))
//       ),
//       test(
//         "fix positive zero",
//         Float.format(#fix 6, positiveZero),
//         M.equals(T.text("0.000000"))
//       ),
//       test(
//         "fix negative zero",
//         Float.format(#fix 6, negativeZero),
//         M.equals(T.text("-0.000000"))
//       ),
//       test(
//         "fix positive infinity",
//         Float.format(#fix 6, positiveInfinity),
//         M.equals(T.text("inf"))
//       ),
//       test(
//         "fix negative infinity",
//         Float.format(#fix 6, negativeInfinity),
//         M.equals(T.text("-inf"))
//       ),
//       test(
//         "fix positive NaN",
//         Float.format(#fix 6, positiveNaN),
//         M.equals(T.text("nan"))
//       ),
//       test(
//         "fix negative NaN",
//         Float.format(#fix 6, negativeNaN),
//         M.equals(T.text("-nan"))
//       ),
//       test(
//         "exp positive",
//         Float.format(#exp 9, 20.12345678901),
//         M.equals(T.text("2.012345679e+01"))
//       ),
//       test(
//         "exp negative",
//         Float.format(#exp 9, -20.12345678901),
//         M.equals(T.text("-2.012345679e+01"))
//       ),
//       test(
//         "exp positive zero",
//         Float.format(#exp 9, positiveZero),
//         M.equals(T.text("0.000000000e+00"))
//       ),
//       test(
//         "exp negative zero",
//         Float.format(#exp 9, negativeZero),
//         M.equals(T.text("-0.000000000e+00"))
//       ),
//       test(
//         "exp positive infinity",
//         Float.format(#exp 9, positiveInfinity),
//         M.equals(T.text("inf"))
//       ),
//       test(
//         "exp negative infinity",
//         Float.format(#exp 9, negativeInfinity),
//         M.equals(T.text("-inf"))
//       ),
//       test(
//         "exp positive NaN",
//         Float.format(#exp 9, positiveNaN),
//         M.equals(T.text("nan"))
//       ),
//       test(
//         "exp negative NaN",
//         Float.format(#exp 9, negativeNaN),
//         M.equals(T.text("-nan"))
//       ),
//       test(
//         "gen positive",
//         Float.format(#gen 12, 20.12345678901),
//         M.equals(T.text("20.123456789"))
//       ),
//       test(
//         "gen negative",
//         Float.format(#gen 12, -20.12345678901),
//         M.equals(T.text("-20.123456789"))
//       ),
//       test(
//         "gen positive zero",
//         Float.format(#gen 12, positiveZero),
//         M.equals(T.text("0"))
//       ),
//       test(
//         "gen negative zero",
//         Float.format(#gen 12, negativeZero),
//         M.equals(T.text("-0"))
//       ),
//       test(
//         "gen positive infinity",
//         Float.format(#gen 12, positiveInfinity),
//         M.equals(T.text("inf"))
//       ),
//       test(
//         "gen negative infinity",
//         Float.format(#gen 12, negativeInfinity),
//         M.equals(T.text("-inf"))
//       ),
//       test(
//         "gen positive NaN",
//         Float.format(#gen 12, positiveNaN),
//         M.equals(T.text("nan"))
//       ),
//       test(
//         "gen negative NaN",
//         Float.format(#gen 12, negativeNaN),
//         M.equals(T.text("-nan"))
//       ),
//       // TODO: Not yet supported
//       // test(
//       //   "hex positive",
//       //   Float.format(#hex 10, 20.12345678901),
//       //   M.equals(T.text("0x1.41f9add374p+4"))
//       // ),
//       // test(
//       //   "hex negative",
//       //   Float.format(#hex 10, -20.12345678901),
//       //   M.equals(T.text("-0x1.41f9add374p+4"))
//       // ),
//       // test(
//       //   "hex positive zero",
//       //   Float.format(#hex 10, positiveZero),
//       //   M.equals(T.text("0x0.0000000000p+0"))
//       // ),
//       // test(
//       //   "hex negative zero",
//       //   Float.format(#hex 10, negativeZero),
//       //   M.equals(T.text("-0x0.0000000000p+0"))
//       // ),
//       // test(
//       //   "hex positive infinity",
//       //   Float.format(#hex 10, positiveInfinity),
//       //   M.equals(T.text("inf"))
//       // ),
//       // test(
//       //   "hex negative infinity",
//       //   Float.format(#hex 10, negativeInfinity),
//       //   M.equals(T.text("-inf"))
//       // ),
//       // test(
//       //   "hex positive NaN",
//       //   Float.format(#hex 10, positiveNaN),
//       //   M.equals(T.text("nan"))
//       // ),
//       // test(
//       //   "hex negative NaN",
//       //   Float.format(#hex 10, negativeNaN),
//       //   M.equals(T.text("-nan"))
//       // )
//     ]
//   )
// );

/* --------------------------------------- */

// TODO: Support in 64-bit
// run(
//   suite(
//     "toText",
//     [
//       test(
//         "positive",
//         Float.toText(20.12345678901),
//         M.equals(T.text("20.123457"))
//       ),
//       test(
//         "negative",
//         Float.toText(-20.12345678901),
//         M.equals(T.text("-20.123457"))
//       ),
//       test(
//         "positive zero",
//         Float.toText(positiveZero),
//         M.equals(T.text("0.000000"))
//       ),
//       test(
//         "negative zero",
//         Float.toText(negativeZero),
//         M.equals(T.text("-0.000000"))
//       ),
//       test(
//         "positive infinity",
//         Float.toText(positiveInfinity),
//         M.equals(T.text("inf"))
//       ),
//       test(
//         "negative infinity",
//         Float.toText(negativeInfinity),
//         M.equals(T.text("-inf"))
//       ),
//       test(
//         "positive NaN",
//         Float.toText(positiveNaN),
//         M.equals(T.text("nan"))
//       ),
//       test(
//         "negative NaN",
//         Float.toText(negativeNaN),
//         M.equals(T.text("-nan"))
//       )
//     ]
//   )
// );

/* --------------------------------------- */

run(
  suite(
    "toInt64",
    [
      test(
        "positive",
        Float.toInt64(20.987),
        M.equals(Int64Testable(20))
      ),
      test(
        "negative",
        Float.toInt64(-20.987),
        M.equals(Int64Testable(-20))
      ),
      test(
        "nearly zero",
        Float.toInt64(-1e-40),
        M.equals(Int64Testable(0))
      ),
      test(
        "large integer",
        Float.toInt64(9223372036854774784.0),
        M.equals(Int64Testable(9223372036854774784))
      ),
      test(
        "small integer",
        Float.toInt64(-9223372036854774784.0),
        M.equals(Int64Testable(-9223372036854774784))
      ),
      test(
        "positive zero",
        Float.toInt64(positiveZero),
        M.equals(Int64Testable(0))
      ),
      test(
        "negative zero",
        Float.toInt64(negativeZero),
        M.equals(Int64Testable(0))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "fromInt64",
    [
      test(
        "positive",
        Float.fromInt64(20),
        M.equals(FloatTestable(20.0, noEpsilon))
      ),
      test(
        "negative",
        Float.fromInt64(-20),
        M.equals(FloatTestable(-20.0, noEpsilon))
      ),
      test(
        "zero",
        Float.fromInt64(0),
        PositiveZeroMatcher()
      ),
      test(
        "max integer",
        Float.fromInt64(9223372036854775807),
        M.equals(FloatTestable(9223372036854775807.0, noEpsilon))
      ),
      test(
        "min integer",
        Float.fromInt64(-9223372036854775808),
        M.equals(FloatTestable(-9223372036854775808.0, noEpsilon))
      )
    ]
  )
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
        M.equals(T.int(20))
      ),
      test(
        "negative",
        Float.toInt(-20.987),
        M.equals(T.int(-20))
      ),
      test(
        "nearly zero",
        Float.toInt(-1e-40),
        M.equals(T.int(0))
      ),
      test(
        "positive big integer",
        Float.toInt(arbitraryBigIntAsFloat),
        M.equals(T.int(arbitraryBigInt))
      ),
      test(
        "negative big integer",
        Float.toInt(-arbitraryBigIntAsFloat),
        M.equals(T.int(-arbitraryBigInt))
      ),
      test(
        "positive zero",
        Float.toInt(positiveZero),
        M.equals(T.int(0))
      ),
      test(
        "negative zero",
        Float.toInt(negativeZero),
        M.equals(T.int(0))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "fromInt",
    [
      test(
        "positive",
        Float.fromInt(20),
        M.equals(FloatTestable(20.0, noEpsilon))
      ),
      test(
        "negative",
        Float.fromInt(-20),
        M.equals(FloatTestable(-20.0, noEpsilon))
      ),
      test(
        "zero",
        Float.fromInt(0),
        PositiveZeroMatcher()
      ),
      test(
        "positive big integer",
        Float.fromInt(arbitraryBigInt),
        M.equals(FloatTestable(arbitraryBigIntAsFloat, noEpsilon))
      ),
      test(
        "negative big integer",
        Float.fromInt(-arbitraryBigInt),
        M.equals(FloatTestable(-arbitraryBigIntAsFloat, noEpsilon))
      ),
      test(
        "positive infinity",
        Float.fromInt(3 ** 7777),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.fromInt(-3 ** 7777),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "equalWithin",
    [
      test(
        "positive equal, no epsilon",
        Float.equalWithin(1.23, 1.23, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "positive equal, small epsilon",
        Float.equalWithin(0.1 + 0.1 + 0.1, 0.3, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal, no epsilon",
        Float.equalWithin(-1.23, -1.23, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal, small epsilon",
        Float.equalWithin(-0.1 - 0.1 - 0.1, -0.3, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "zero",
        Float.equalWithin(0.0, 0.0, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "mixed zero signs",
        Float.equalWithin(positiveZero, negativeZero, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "positive not equal, small epsilon",
        Float.equalWithin(1.23, 1.24, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "negative not equal, small epsilon",
        Float.equalWithin(-1.23, -1.24, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs, smallEpsilon",
        Float.equalWithin(1.23, -1.23, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity, no epsilon",
        Float.equalWithin(positiveInfinity, positiveInfinity, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "positive infinity, small epsilon",
        Float.equalWithin(positiveInfinity, positiveInfinity, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "negative infinity, no epsilon",
        Float.equalWithin(negativeInfinity, negativeInfinity, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "negative infinity, small epsilon",
        Float.equalWithin(negativeInfinity, negativeInfinity, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "mixed infinity signs",
        Float.equalWithin(positiveInfinity, negativeInfinity, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "two positive NaNs",
        Float.equalWithin(positiveNaN, positiveNaN, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "two negative NaNs",
        Float.equalWithin(negativeNaN, negativeNaN, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "NaNs with mixed signs",
        Float.equalWithin(positiveNaN, negativeNaN, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "number and NaN, no epsilon",
        Float.equalWithin(1.23, positiveNaN, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "number and NaN, small epsilon",
        Float.equalWithin(1.23, positiveNaN, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and number, no epsilon",
        Float.equalWithin(positiveNaN, -1.23, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and number, small epsilon",
        Float.equalWithin(positiveNaN, -1.23, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and NaN",
        Float.equalWithin(positiveNaN, positiveNaN, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and positive infinity",
        Float.equalWithin(positiveNaN, positiveInfinity, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and negative infinity",
        Float.equalWithin(positiveNaN, negativeInfinity, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and NaN",
        Float.equalWithin(positiveInfinity, positiveNaN, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and NaN",
        Float.equalWithin(negativeInfinity, positiveNaN, smallEpsilon),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "notEqualWithin",
    [
      test(
        "positive equal, no epsilon",
        Float.notEqualWithin(1.23, 1.23, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "positive equal, small epsilon",
        Float.notEqualWithin(0.1 + 0.1 + 0.1, 0.3, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal, no epsilon",
        Float.notEqualWithin(-1.23, -1.23, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal, small epsilon",
        Float.notEqualWithin(-0.1 - 0.1 - 0.1, -0.3, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "zero",
        Float.notEqualWithin(0.0, 0.0, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "mixed zero signs",
        Float.notEqualWithin(positiveZero, negativeZero, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "positive not equal",
        Float.notEqualWithin(1.23, 1.24, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "negative not equal",
        Float.notEqualWithin(-1.23, -1.24, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs",
        Float.notEqualWithin(1.23, -1.23, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "positive infinity, no epsilon",
        Float.notEqualWithin(positiveInfinity, positiveInfinity, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity, small epsilon",
        Float.notEqualWithin(positiveInfinity, positiveInfinity, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity, no epsilon",
        Float.notEqualWithin(negativeInfinity, negativeInfinity, noEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity, small epsilon",
        Float.notEqualWithin(negativeInfinity, negativeInfinity, smallEpsilon),
        M.equals(T.bool(false))
      ),
      test(
        "mixed infinity signs",
        Float.notEqualWithin(positiveInfinity, negativeInfinity, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "two positive NaNs",
        Float.notEqualWithin(positiveNaN, positiveNaN, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "two negative NaNs",
        Float.notEqualWithin(negativeNaN, negativeNaN, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "NaNs with mixed signs",
        Float.notEqualWithin(positiveNaN, negativeNaN, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "number and NaN, no epsilon",
        Float.notEqualWithin(1.23, positiveNaN, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "number and NaN, small epsilon",
        Float.notEqualWithin(1.23, positiveNaN, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "NaN and number, no epsilon",
        Float.notEqualWithin(positiveNaN, -1.23, noEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "NaN and number, small epsilon",
        Float.notEqualWithin(positiveNaN, -1.23, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "NaN and NaN",
        Float.notEqualWithin(positiveNaN, positiveNaN, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "NaN and positive infinity",
        Float.notEqualWithin(positiveNaN, positiveInfinity, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "NaN and negative infinity",
        Float.notEqualWithin(positiveNaN, negativeInfinity, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "positive infinity and NaN",
        Float.notEqualWithin(positiveInfinity, positiveNaN, smallEpsilon),
        M.equals(T.bool(true))
      ),
      test(
        "negative infinity and NaN",
        Float.notEqualWithin(negativeInfinity, positiveNaN, smallEpsilon),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "less",
    [
      test(
        "positive equal",
        Float.less(1.23, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "positive less",
        Float.less(1.23, 2.45),
        M.equals(T.bool(true))
      ),
      test(
        "positive greater",
        Float.less(2.45, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal",
        Float.less(-1.23, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "negative less",
        Float.less(-2.45, -1.23),
        M.equals(T.bool(true))
      ),
      test(
        "negative greater",
        Float.less(-1.23, -2.45),
        M.equals(T.bool(false))
      ),
      test(
        "positive zeros",
        Float.less(positiveZero, positiveZero),
        M.equals(T.bool(false))
      ),
      test(
        "negative zeros",
        Float.less(negativeZero, negativeZero),
        M.equals(T.bool(false))
      ),
      test(
        "positive and negative zero",
        Float.less(positiveZero, negativeZero),
        M.equals(T.bool(false))
      ),
      test(
        "negative and positive zero",
        Float.less(negativeZero, positiveZero),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs less",
        Float.less(-1.23, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs greater",
        Float.less(1.23, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "number and positive infinity",
        Float.less(1.23, positiveInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "positive infinity and number",
        Float.less(positiveInfinity, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "number and negative infinity",
        Float.less(1.23, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and number",
        Float.less(negativeInfinity, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "double positive infinity",
        Float.less(positiveInfinity, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive and negative infinity",
        Float.less(positiveInfinity, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "double negative infinity",
        Float.less(negativeInfinity, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "negative and positive infinity",
        Float.less(negativeInfinity, positiveInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "two positive NaNs",
        Float.less(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "two negative NaNs",
        Float.less(negativeNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaNs with mixed signs",
        Float.less(positiveNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "number and NaN",
        Float.less(1.23, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and number",
        Float.less(positiveNaN, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and NaN",
        Float.less(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and positive infinity",
        Float.less(positiveNaN, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and negative infinity",
        Float.less(positiveNaN, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and NaN",
        Float.less(positiveInfinity, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and NaN",
        Float.less(negativeInfinity, positiveNaN),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "lessOrEqual",
    [
      test(
        "positive equal",
        Float.lessOrEqual(1.23, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "positive less",
        Float.lessOrEqual(1.23, 2.45),
        M.equals(T.bool(true))
      ),
      test(
        "positive greater",
        Float.lessOrEqual(2.45, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal",
        Float.lessOrEqual(-1.23, -1.23),
        M.equals(T.bool(true))
      ),
      test(
        "negative less",
        Float.lessOrEqual(-2.45, -1.23),
        M.equals(T.bool(true))
      ),
      test(
        "negative greater",
        Float.lessOrEqual(-1.23, -2.45),
        M.equals(T.bool(false))
      ),
      test(
        "positive zeros",
        Float.lessOrEqual(positiveZero, positiveZero),
        M.equals(T.bool(true))
      ),
      test(
        "negative zeros",
        Float.lessOrEqual(negativeZero, negativeZero),
        M.equals(T.bool(true))
      ),
      test(
        "positive and negative zero",
        Float.lessOrEqual(positiveZero, negativeZero),
        M.equals(T.bool(true))
      ),
      test(
        "negative and positive zero",
        Float.lessOrEqual(negativeZero, positiveZero),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs less",
        Float.lessOrEqual(-1.23, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs greater",
        Float.lessOrEqual(1.23, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "number and positive infinity",
        Float.lessOrEqual(1.23, positiveInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "positive infinity and number",
        Float.lessOrEqual(positiveInfinity, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "number and negative infinity",
        Float.lessOrEqual(1.23, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and number",
        Float.lessOrEqual(negativeInfinity, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "double positive infinity",
        Float.lessOrEqual(positiveInfinity, positiveInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "positive and negative infinity",
        Float.lessOrEqual(positiveInfinity, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "double negative infinity",
        Float.lessOrEqual(negativeInfinity, negativeInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "negative and positive infinity",
        Float.lessOrEqual(negativeInfinity, positiveInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "two positive NaNs",
        Float.lessOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "two negative NaNs",
        Float.lessOrEqual(negativeNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaNs with mixed signs",
        Float.lessOrEqual(positiveNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "number and NaN",
        Float.lessOrEqual(1.23, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and number",
        Float.lessOrEqual(positiveNaN, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and NaN",
        Float.lessOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and positive infinity",
        Float.lessOrEqual(positiveNaN, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and negative infinity",
        Float.lessOrEqual(positiveNaN, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and NaN",
        Float.lessOrEqual(positiveInfinity, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and NaN",
        Float.lessOrEqual(negativeInfinity, positiveNaN),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "greater",
    [
      test(
        "positive equal",
        Float.greater(1.23, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "positive less",
        Float.greater(1.23, 2.45),
        M.equals(T.bool(false))
      ),
      test(
        "positive greater",
        Float.greater(2.45, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal",
        Float.greater(-1.23, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "negative less",
        Float.greater(-2.45, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "negative greater",
        Float.greater(-1.23, -2.45),
        M.equals(T.bool(true))
      ),
      test(
        "positive zeros",
        Float.greater(positiveZero, positiveZero),
        M.equals(T.bool(false))
      ),
      test(
        "negative zeros",
        Float.greater(negativeZero, negativeZero),
        M.equals(T.bool(false))
      ),
      test(
        "positive and negative zero",
        Float.greater(positiveZero, negativeZero),
        M.equals(T.bool(false))
      ),
      test(
        "negative and positive zero",
        Float.greater(negativeZero, positiveZero),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs less",
        Float.greater(-1.23, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs greater",
        Float.greater(1.23, -1.23),
        M.equals(T.bool(true))
      ),
      test(
        "less than positive infinity",
        Float.greater(1.23, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and number",
        Float.greater(positiveInfinity, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "number and negative infinity",
        Float.greater(1.23, negativeInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "negative infinity and number",
        Float.greater(negativeInfinity, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "double positive infinity",
        Float.greater(positiveInfinity, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive and negative infinity",
        Float.greater(positiveInfinity, negativeInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "double negative infinity",
        Float.greater(negativeInfinity, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "negative and positive infinity",
        Float.greater(negativeInfinity, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "two positive NaNs",
        Float.greater(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "two negative NaNs",
        Float.greater(negativeNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaNs with mixed signs",
        Float.greater(positiveNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "number and NaN",
        Float.greater(1.23, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and number",
        Float.greater(positiveNaN, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and NaN",
        Float.greater(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and positive infinity",
        Float.greater(positiveNaN, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and negative infinity",
        Float.greater(positiveNaN, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and NaN",
        Float.greater(positiveInfinity, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and NaN",
        Float.greater(negativeInfinity, positiveNaN),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "greaterOrEqual",
    [
      test(
        "positive equal",
        Float.greaterOrEqual(1.23, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "positive less",
        Float.greaterOrEqual(1.23, 2.45),
        M.equals(T.bool(false))
      ),
      test(
        "positive greater",
        Float.greaterOrEqual(2.45, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal",
        Float.greaterOrEqual(-1.23, -1.23),
        M.equals(T.bool(true))
      ),
      test(
        "negative less",
        Float.greaterOrEqual(-2.45, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "negative greater",
        Float.greaterOrEqual(-1.23, -2.45),
        M.equals(T.bool(true))
      ),
      test(
        "positive zeros",
        Float.greaterOrEqual(positiveZero, positiveZero),
        M.equals(T.bool(true))
      ),
      test(
        "negative zeros",
        Float.greaterOrEqual(negativeZero, negativeZero),
        M.equals(T.bool(true))
      ),
      test(
        "positive and negative zero",
        Float.greaterOrEqual(positiveZero, negativeZero),
        M.equals(T.bool(true))
      ),
      test(
        "negative and positive zero",
        Float.greaterOrEqual(negativeZero, positiveZero),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs less",
        Float.greaterOrEqual(-1.23, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs greater",
        Float.greaterOrEqual(1.23, -1.23),
        M.equals(T.bool(true))
      ),
      test(
        "number and positive infinity",
        Float.greaterOrEqual(1.23, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and number",
        Float.greaterOrEqual(positiveInfinity, 1.23),
        M.equals(T.bool(true))
      ),
      test(
        "number and negative infinity",
        Float.greaterOrEqual(1.23, negativeInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "negative infinity and number",
        Float.greaterOrEqual(negativeInfinity, 1.23),
        M.equals(T.bool(false))
      ),
      test(
        "double positive infinity",
        Float.greaterOrEqual(positiveInfinity, positiveInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "positive and negative infinity",
        Float.greaterOrEqual(positiveInfinity, negativeInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "double negative infinity",
        Float.greaterOrEqual(negativeInfinity, negativeInfinity),
        M.equals(T.bool(true))
      ),
      test(
        "negative and positive infinity",
        Float.greaterOrEqual(negativeInfinity, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "two positive NaNs",
        Float.greaterOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "two negative NaNs",
        Float.greaterOrEqual(negativeNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaNs with mixed signs",
        Float.greaterOrEqual(positiveNaN, negativeNaN),
        M.equals(T.bool(false))
      ),
      test(
        "number and NaN",
        Float.greaterOrEqual(1.23, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and number",
        Float.greaterOrEqual(positiveNaN, -1.23),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and NaN",
        Float.greaterOrEqual(positiveNaN, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and positive infinity",
        Float.greaterOrEqual(positiveNaN, positiveInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "NaN and negative infinity",
        Float.greaterOrEqual(positiveNaN, negativeInfinity),
        M.equals(T.bool(false))
      ),
      test(
        "positive infinity and NaN",
        Float.greaterOrEqual(positiveInfinity, positiveNaN),
        M.equals(T.bool(false))
      ),
      test(
        "negative infinity and NaN",
        Float.greaterOrEqual(negativeInfinity, positiveNaN),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

type Order = { #less; #equal; #greater };

class OrderTestable(value : Order) : T.TestableItem<Order> {
  public let item = value;
  public func display(value : Order) : Text {
    debug_show (value)
  };
  public let equals = func(x : Order, y : Order) : Bool {
    x == y
  }
};

let subnormal = 2.2250738585072014e-308;

run(
  suite(
    "compare",
    [
      test(
        "positive equal",
        Float.compare(1.23, 1.23),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "positive less",
        Float.compare(1.23, 2.45),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive greater",
        Float.compare(2.45, 1.23),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative equal",
        Float.compare(-1.23, -1.23),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "negative less",
        Float.compare(-2.45, -1.23),
        M.equals(OrderTestable(#less))
      ),
      test(
        "negative greater",
        Float.compare(-1.23, -2.45),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "positive zeros",
        Float.compare(positiveZero, positiveZero),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "negative zeros",
        Float.compare(negativeZero, negativeZero),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "positive and negative zero",
        Float.compare(positiveZero, negativeZero),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "negative and positive zero",
        Float.compare(negativeZero, positiveZero),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "subnormal negative number and negative number",
        Float.compare(-subnormal, -1e-100),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "subnormal negative number and zero",
        Float.compare(-subnormal, negativeZero),
        M.equals(OrderTestable(#less))
      ),
      test(
        "subnormal positive number and zero",
        Float.compare(subnormal, positiveZero),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "subnormal positive number and positive number",
        Float.compare(subnormal, 1e-100),
        M.equals(OrderTestable(#less))
      ),
      test(
        "mixed signs less",
        Float.compare(-1.23, 1.23),
        M.equals(OrderTestable(#less))
      ),
      test(
        "mixed signs greater",
        Float.compare(1.23, -1.23),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "number and positive infinity",
        Float.compare(1.23, positiveInfinity),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive infinity and number",
        Float.compare(positiveInfinity, 1.23),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "number and negative infinity",
        Float.compare(1.23, negativeInfinity),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative infinity and number",
        Float.compare(negativeInfinity, 1.23),
        M.equals(OrderTestable(#less))
      ),
      test(
        "double positive infinity",
        Float.compare(positiveInfinity, positiveInfinity),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "positive and negative infinity",
        Float.compare(positiveInfinity, negativeInfinity),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "double negative infinity",
        Float.compare(negativeInfinity, negativeInfinity),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "negative and positive infinity",
        Float.compare(negativeInfinity, positiveInfinity),
        M.equals(OrderTestable(#less))
      ),
      test(
        "two positive NaNs",
        Float.compare(positiveNaN, positiveNaN),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "two negative NaNs",
        Float.compare(negativeNaN, negativeNaN),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "positive NaN, negative NaN",
        Float.compare(positiveNaN, negativeNaN),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative NaN, positive NaN",
        Float.compare(negativeNaN, positiveNaN),
        M.equals(OrderTestable(#less))
      ),
      test(
        "number and positive NaN",
        Float.compare(1.23, positiveNaN),
        M.equals(OrderTestable(#less))
      ),
      test(
        "number and negative NaN",
        Float.compare(1.23, negativeNaN),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "positive NaN and positive number",
        Float.compare(positiveNaN, -1.23),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "positive NaN and negative number",
        Float.compare(positiveNaN, -1.23),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative NaN and positive number",
        Float.compare(negativeNaN, -1.23),
        M.equals(OrderTestable(#less))
      ),
      test(
        "negative NaN and negative number",
        Float.compare(negativeNaN, -1.23),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive NaN and positive NaN",
        Float.compare(positiveNaN, positiveNaN),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "negative NaN and positive NaN",
        Float.compare(negativeNaN, positiveNaN),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive NaN and negative NaN",
        Float.compare(positiveNaN, negativeNaN),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative NaN and negative NaN",
        Float.compare(negativeNaN, negativeNaN),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "positive NaN and positive infinity",
        Float.compare(positiveNaN, positiveInfinity),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "positive NaN and negative infinity",
        Float.compare(positiveNaN, negativeInfinity),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "positive NaN and positive infinity",
        Float.compare(positiveNaN, positiveInfinity),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative NaN and negative infinity",
        Float.compare(negativeNaN, negativeInfinity),
        M.equals(OrderTestable(#less))
      ),
      test(
        "negative NaN and positive infinity",
        Float.compare(negativeNaN, positiveInfinity),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive infinity and positive NaN",
        Float.compare(positiveInfinity, positiveNaN),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive infinity and negative NaN",
        Float.compare(positiveInfinity, negativeNaN),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "positive infinity and positive NaN",
        Float.compare(positiveInfinity, positiveNaN),
        M.equals(OrderTestable(#less))
      ),
      test(
        "negative infinity and positive NaN",
        Float.compare(negativeInfinity, positiveNaN),
        M.equals(OrderTestable(#less))
      ),
      test(
        "negative infinity and negative NaN",
        Float.compare(negativeInfinity, negativeNaN),
        M.equals(OrderTestable(#greater))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "neg",
    [
      test(
        "positive number",
        Float.neg(1.1),
        M.equals(FloatTestable(-1.1, noEpsilon))
      ),
      test(
        "negative number",
        Float.neg(-1.1),
        M.equals(FloatTestable(1.1, noEpsilon))
      ),
      test(
        "zero",
        Float.neg(0.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive zero",
        Float.neg(positiveZero),
        NegativeZeroMatcher()
      ),
      test(
        "negative zero",
        Float.neg(negativeZero),
        PositiveZeroMatcher()
      ),
      test(
        "positive infinity",
        Float.neg(positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative infinity",
        Float.neg(negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive NaN (provisional test)",
        Float.neg(positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative NaN (provisional test)",
        Float.neg(negativeNaN),
        NaNMatcher()
      ),
      test(
        "positive NaN",
        Float.neg(positiveNaN),
        NegativeNaNMatcher()
      ),
      test(
        "negative NaN",
        Float.neg(negativeNaN),
        PositiveNaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "add",
    [
      test(
        "positive",
        Float.add(1.23, 1.23),
        M.equals(FloatTestable(2.46, smallEpsilon))
      ),
      test(
        "negative",
        Float.add(-1.23, -1.23),
        M.equals(FloatTestable(-2.46, smallEpsilon))
      ),
      test(
        "mixed signs",
        Float.add(-1.23, 2.23),
        M.equals(FloatTestable(1.0, smallEpsilon))
      ),
      test(
        "positive zeros",
        Float.add(positiveZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "negative zeros",
        Float.add(negativeZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "positive and negative zero",
        Float.add(positiveZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "negative and positive zero",
        Float.add(negativeZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "number and positive infinity",
        Float.add(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive infinity and number",
        Float.add(positiveInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "number and negative infinity",
        Float.add(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative infinity and number",
        Float.add(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "double positive infinity",
        Float.add(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive and negative infinity",
        Float.add(positiveInfinity, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "double negative infinity",
        Float.add(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative and positive infinity",
        Float.add(negativeInfinity, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "two positive NaNs",
        Float.add(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "two negative NaNs",
        Float.add(negativeNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaNs with mixed signs",
        Float.add(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "number and NaN",
        Float.add(1.23, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and number",
        Float.add(positiveNaN, -1.23),
        NaNMatcher()
      ),
      test(
        "NaN and NaN",
        Float.add(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.add(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.add(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.add(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.add(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "sub",
    [
      test(
        "positive",
        Float.sub(1.23, 2.34),
        M.equals(FloatTestable(-1.11, smallEpsilon))
      ),
      test(
        "negative",
        Float.sub(-1.23, -2.34),
        M.equals(FloatTestable(1.11, smallEpsilon))
      ),
      test(
        "mixed signs",
        Float.sub(-1.23, 2.34),
        M.equals(FloatTestable(-3.57, smallEpsilon))
      ),
      test(
        "positive zeros",
        Float.sub(positiveZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "negative zeros",
        Float.sub(negativeZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "positive and negative zero",
        Float.sub(positiveZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "negative and positive zero",
        Float.sub(negativeZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "number and positive infinity",
        Float.sub(1.23, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive infinity and number",
        Float.sub(positiveInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "number and negative infinity",
        Float.sub(1.23, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and number",
        Float.sub(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "double positive infinity",
        Float.sub(positiveInfinity, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "positive and negative infinity",
        Float.sub(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "double negative infinity",
        Float.sub(negativeInfinity, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "negative and positive infinity",
        Float.sub(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "two positive NaNs",
        Float.sub(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "two negative NaNs",
        Float.sub(negativeNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaNs with mixed signs",
        Float.sub(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "number and NaN",
        Float.sub(1.23, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and number",
        Float.sub(positiveNaN, -1.23),
        NaNMatcher()
      ),
      test(
        "NaN and NaN",
        Float.sub(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.sub(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.sub(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.sub(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.sub(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "mul",
    [
      test(
        "positive",
        Float.mul(1.23, 2.34),
        M.equals(FloatTestable(2.8782, smallEpsilon))
      ),
      test(
        "negative",
        Float.mul(-1.23, -2.34),
        M.equals(FloatTestable(2.8782, smallEpsilon))
      ),
      test(
        "mixed signs",
        Float.mul(-1.23, 2.34),
        M.equals(FloatTestable(-2.8782, smallEpsilon))
      ),
      test(
        "positive zeros",
        Float.mul(positiveZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "negative zeros",
        Float.mul(negativeZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "positive and negative zero",
        Float.mul(positiveZero, negativeZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "negative and positive zero",
        Float.mul(negativeZero, positiveZero),
        M.equals(FloatTestable(0.0, smallEpsilon))
      ),
      test(
        "positive number and positive infinity",
        Float.mul(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative number and positive infinity",
        Float.mul(-1.23, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "zero and positive infinity",
        Float.mul(0.0, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and positive number",
        Float.mul(positiveInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive infinity and negative number",
        Float.mul(positiveInfinity, -1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive infinity and zero",
        Float.mul(positiveInfinity, 0.0),
        NaNMatcher()
      ),
      test(
        "positive number and negative infinity",
        Float.mul(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative number and negative infinity",
        Float.mul(-1.23, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "zero and negative infinity",
        Float.mul(0.0, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "negative infinity and positive number",
        Float.mul(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative infinity and negative number",
        Float.mul(negativeInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and zero",
        Float.mul(negativeInfinity, 0.0),
        NaNMatcher()
      ),
      test(
        "double positive infinity",
        Float.mul(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive and negative infinity",
        Float.mul(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "double negative infinity",
        Float.mul(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative and positive infinity",
        Float.mul(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "two positive NaNs",
        Float.mul(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "two negative NaNs",
        Float.mul(negativeNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaNs with mixed signs",
        Float.mul(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "number and NaN",
        Float.mul(1.23, positiveNaN),
        NaNMatcher()
      ),
      test(
        "zero and NaN",
        Float.mul(0.0, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and number",
        Float.mul(positiveNaN, -1.23),
        NaNMatcher()
      ),
      test(
        "NaN and zero",
        Float.mul(positiveNaN, 0.0),
        NaNMatcher()
      ),
      test(
        "NaN and NaN",
        Float.mul(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.mul(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.mul(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.mul(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.mul(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "div",
    [
      test(
        "positive",
        Float.div(1.23, 2.34),
        M.equals(FloatTestable(0.525641025641026, smallEpsilon))
      ),
      test(
        "negative",
        Float.div(-1.23, -2.34),
        M.equals(FloatTestable(0.525641025641026, smallEpsilon))
      ),
      test(
        "mixed signs",
        Float.div(-1.23, 2.34),
        M.equals(FloatTestable(-0.525641025641026, smallEpsilon))
      ),
      test(
        "positive zeros",
        Float.div(positiveZero, positiveZero),
        NaNMatcher()
      ),
      test(
        "negative zeros",
        Float.div(negativeZero, negativeZero),
        NaNMatcher()
      ),
      test(
        "positive and negative zero",
        Float.div(positiveZero, negativeZero),
        NaNMatcher()
      ),
      test(
        "negative and positive zero",
        Float.div(negativeZero, positiveZero),
        NaNMatcher()
      ),
      test(
        "positive number and positive infinity",
        Float.div(1.23, positiveInfinity),
        PositiveZeroMatcher()
      ),
      test(
        "negative number and positive infinity",
        Float.div(-1.23, positiveInfinity),
        NegativeZeroMatcher()
      ),
      test(
        "positive infinity and negative number",
        Float.div(positiveInfinity, -1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "positive infinity and zero",
        Float.div(positiveInfinity, 0.0),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive infinity and positive number",
        Float.div(positiveInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive number and negative infinity",
        Float.div(1.23, negativeInfinity),
        NegativeZeroMatcher()
      ),
      test(
        "negative number and negative infinity",
        Float.div(-1.23, negativeInfinity),
        PositiveZeroMatcher()
      ),
      test(
        "negative infinity and positive number",
        Float.div(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative infinity and negative number",
        Float.div(negativeInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and zero",
        Float.div(negativeInfinity, 0.0),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "double positive infinity",
        Float.div(positiveInfinity, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "positive and negative infinity",
        Float.div(positiveInfinity, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "double negative infinity",
        Float.div(negativeInfinity, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "negative and positive infinity",
        Float.div(negativeInfinity, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "two positive NaNs",
        Float.div(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "two negative NaNs",
        Float.div(negativeNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaNs with mixed signs",
        Float.div(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "number and NaN",
        Float.div(1.23, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and number",
        Float.div(positiveNaN, -1.23),
        NaNMatcher()
      ),
      test(
        "NaN and NaN",
        Float.div(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.div(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.div(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.div(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.div(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "rem",
    [
      test(
        "positive quotient, positive divisor",
        Float.rem(7.2, 2.3),
        M.equals(FloatTestable(0.3, smallEpsilon))
      ),
      test(
        "positive quotient, negative divisor",
        Float.rem(7.2, -2.3),
        M.equals(FloatTestable(0.3, smallEpsilon))
      ),
      test(
        "negative quotient, positive divisor",
        Float.rem(-8.2, 3.12),
        M.equals(FloatTestable(-1.96, smallEpsilon))
      ),
      test(
        "negative quotient, negative divisor",
        Float.rem(-8.2, -3.12),
        M.equals(FloatTestable(-1.96, smallEpsilon))
      ),
      test(
        "positive zeros",
        Float.rem(positiveZero, positiveZero),
        NaNMatcher()
      ),
      test(
        "negative zeros",
        Float.rem(negativeZero, negativeZero),
        NaNMatcher()
      ),
      test(
        "positive and negative zero",
        Float.rem(positiveZero, negativeZero),
        NaNMatcher()
      ),
      test(
        "negative and positive zero",
        Float.rem(negativeZero, positiveZero),
        NaNMatcher()
      ),
      test(
        "positive number and positive infinity",
        Float.rem(1.23, positiveInfinity),
        M.equals(FloatTestable(1.23, noEpsilon))
      ),
      test(
        "negative number and positive infinity",
        Float.rem(-1.23, positiveInfinity),
        M.equals(FloatTestable(-1.23, noEpsilon))
      ),
      test(
        "zero and positive infinity",
        Float.rem(0.0, positiveInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive infinity and positive number",
        Float.rem(positiveInfinity, 1.23),
        NaNMatcher()
      ),
      test(
        "positive infinity and negative number",
        Float.rem(positiveInfinity, -1.23),
        NaNMatcher()
      ),
      test(
        "positive infinity and zero",
        Float.rem(positiveInfinity, 0.0),
        NaNMatcher()
      ),
      test(
        "positive number and negative infinity",
        Float.rem(1.23, negativeInfinity),
        M.equals(FloatTestable(1.23, noEpsilon))
      ),
      test(
        "negative number and negative infinity",
        Float.rem(-1.23, negativeInfinity),
        M.equals(FloatTestable(-1.23, noEpsilon))
      ),
      test(
        "zero and negative infinity",
        Float.rem(0.0, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "negative infinity and positive number",
        Float.rem(negativeInfinity, 1.23),
        NaNMatcher()
      ),
      test(
        "negative infinity and negative number",
        Float.rem(negativeInfinity, -1.23),
        NaNMatcher()
      ),
      test(
        "negative infinity and zero",
        Float.rem(negativeInfinity, 0.0),
        NaNMatcher()
      ),
      test(
        "double positive infinity",
        Float.rem(positiveInfinity, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "positive and negative infinity",
        Float.rem(positiveInfinity, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "double negative infinity",
        Float.rem(negativeInfinity, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "negative and positive infinity",
        Float.rem(negativeInfinity, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "two positive NaNs",
        Float.rem(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "two negative NaNs",
        Float.rem(negativeNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaNs with mixed signs",
        Float.rem(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "number and NaN",
        Float.rem(1.23, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and number",
        Float.rem(positiveNaN, -1.23),
        NaNMatcher()
      ),
      test(
        "NaN and NaN",
        Float.rem(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and positive infinity",
        Float.rem(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative infinity",
        Float.rem(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "positive infinity and NaN",
        Float.rem(positiveInfinity, positiveNaN),
        NaNMatcher()
      ),
      test(
        "negative infinity and NaN",
        Float.rem(negativeInfinity, positiveNaN),
        NaNMatcher()
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "pow",
    [
      test(
        "positive base, positive integral exponent",
        Float.pow(7.2, 3.0),
        M.equals(FloatTestable(373.248, smallEpsilon))
      ),
      test(
        "positive base, positive non-integral exponent",
        Float.pow(7.2, 3.2),
        M.equals(FloatTestable(553.941609551155657, smallEpsilon))
      ),
      test(
        "positive base, zero exponent",
        Float.pow(7.2, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "positive base, negative integral exponent",
        Float.pow(7.2, -3.0),
        M.equals(FloatTestable(0.002679183813443, smallEpsilon))
      ),
      test(
        "positive base, negative non-integral exponent",
        Float.pow(7.2, -3.2),
        M.equals(FloatTestable(0.001805244420635, smallEpsilon))
      ),
      test(
        "negative base, positive integral exponent",
        Float.pow(-7.2, 3.0),
        M.equals(FloatTestable(-373.248, smallEpsilon))
      ),
      test(
        "negative base, positive non-integral exponent",
        Float.pow(-7.2, 3.2),
        NaNMatcher()
      ),
      test(
        "negative base, zero exponent",
        Float.pow(-7.2, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "negative base, negative integral exponent",
        Float.pow(-7.2, -3.0),
        M.equals(FloatTestable(-0.002679183813443, smallEpsilon))
      ),
      test(
        "negative base, negative non-integral exponent",
        Float.pow(-7.2, -3.2),
        NaNMatcher()
      ),
      test(
        "positive zeros",
        Float.pow(positiveZero, positiveZero),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "negative zeros",
        Float.pow(negativeZero, negativeZero),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "positive and negative zero",
        Float.pow(positiveZero, negativeZero),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "negative and positive zero",
        Float.pow(negativeZero, positiveZero),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "positive number and positive infinity",
        Float.pow(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "zero and positive infinity",
        Float.pow(0.0, positiveInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "negative number and positive infinity",
        Float.pow(-1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive infinity and positive number",
        Float.pow(positiveInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive infinity and negative number",
        Float.pow(positiveInfinity, -0.1),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "positive infinity and zero",
        Float.pow(positiveInfinity, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "positive number and negative infinity",
        Float.pow(1.23, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "negative number and negative infinity",
        Float.pow(-1.23, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "zero and negative infinity",
        Float.pow(0.0, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and positive odd positive number",
        Float.pow(negativeInfinity, 3.0),
        M.equals(FloatTestable(negativeInfinity, noEpsilon))
      ),
      test(
        "negative infinity and positive odd negative number",
        Float.pow(negativeInfinity, -3.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "negative infinity and positive even positive number",
        Float.pow(negativeInfinity, 4.0),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and positive even negative number",
        Float.pow(negativeInfinity, -4.0),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "negative infinity and zero",
        Float.pow(negativeInfinity, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "negative infinity and non-integral positive number",
        Float.pow(negativeInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "negative infinity and non-integral negative number",
        Float.pow(negativeInfinity, -1.23),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "double positive infinity",
        Float.pow(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "positive and negative infinity",
        Float.pow(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "double negative infinity",
        Float.pow(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon))
      ),
      test(
        "negative and positive infinity",
        Float.pow(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon))
      ),
      test(
        "two positive NaNs",
        Float.pow(positiveNaN, positiveNaN),
        NaNMatcher()
      ),
      test(
        "two negative NaNs",
        Float.pow(negativeNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "NaNs with mixed signs",
        Float.pow(positiveNaN, negativeNaN),
        NaNMatcher()
      ),
      test(
        "number and NaN",
        Float.pow(1.23, positiveNaN),
        NaNMatcher()
      ),
      test(
        "NaN and number",
        Float.pow(positiveNaN, 2.0),
        NaNMatcher()
      ),
      test(
        "NaN and zero",
        Float.pow(positiveNaN, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon))
      ),
      test(
        "NaN and positive infinity",
        Float.pow(positiveNaN, positiveInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and negative Infinity",
        Float.pow(positiveNaN, negativeInfinity),
        NaNMatcher()
      ),
      test(
        "NaN and NaN",
        Float.pow(positiveNaN, positiveNaN),
        NaNMatcher()
      )
    ]
  )
)
