import Debug "mo:base/Debug";
import Float "mo:base/Float";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class FloatTestable(number : Float, epsilon: Float) : T.TestableItem<Float> {
  public let item = number;
  public func display(number : Float) : Text {
    debug_show (number);
  };
  public let equals = func(x : Float, y : Float) : Bool { 
    if (epsilon == 0.0) {
      x == y // to also test Float.abs()
    } else {
      Float.abs(x - y) < epsilon
    }
   };
};

class Int64Testable(number : Int64) : T.TestableItem<Int64> {
  public let item = number;
  public func display(number : Int64) : Text {
    debug_show (number);
  };
  public let equals = func(x : Int64, y : Int64) : Bool { 
    x == y
  };
};

func isNaN(number: Float): Bool {
  number != number
};

let positiveInfinity = 1.0/0.0;
let negativeInfinity = -1.0/0.0;

let negativeNaN = 0.0/0.0;
let positiveNaN = Float.copySign(negativeNaN, 1.0); // Compiler issue, NaN are represented negative by default. https://github.com/dfinity/motoko/issues/3647

func isPositiveNaN(number: Float): Bool {
  debug_show(number) == "nan"
};

func isNegativeNaN(number: Float): Bool {
  debug_show(number) == "-nan"
};

let positiveZero = 0.0;
let negativeZero = Float.copySign(0.0, -1.0); // Compiler bug, cannot use literal `-0.0`. https://github.com/dfinity/motoko/issues/3646

func isPositiveZero(number: Float): Bool {
  number == 0.0 and 1.0 / number == positiveInfinity
};

func isNegativeZero(number: Float): Bool {
  number == 0.0 and 1.0 / number == negativeInfinity
};

let noEpsilon = 0.0;
let smallEpsilon = 1e-6;

let holds = M.equals(T.bool(true));

// Some tests are adopted from Motoko compiler test `float-ops.mo`.

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
        isPositiveZero(Float.abs(positiveZero)), 
        holds,
      ),
      test(
        "negative zero",
        isPositiveZero(Float.abs(negativeZero)), 
        holds,
      ),
      test(
        "positive infinity",
        Float.abs(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.abs(negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.abs(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.abs(negativeNaN)),
        holds,
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
        isPositiveZero(Float.sqrt(positiveZero)),
        holds,
      ),
      test(
        "negative zero",
        isNegativeZero(Float.sqrt(negativeZero)),
        holds,
      ),
      test(
        "positive infinity",
        Float.sqrt(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative",
        isNaN(Float.sqrt(-16.0)),
        holds,
      ),
      test(
        "positive NaN",
        isNaN(Float.sqrt(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.sqrt(negativeNaN)),
        holds,
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
        isPositiveZero(Float.ceil(positiveZero)),
        holds,
      ),
      test(
        "negative zero",
        isNegativeZero(Float.ceil(negativeZero)),
        holds,
      ),
      test(
        "positive infinity",
        Float.ceil(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.ceil(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.ceil(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.ceil(negativeNaN)),
        holds,
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
        isPositiveZero(Float.floor(positiveZero)),
        holds,
      ),
      test(
        "negative zero",
        isNegativeZero(Float.floor(negativeZero)),
        holds,
      ),
      test(
        "positive infinity",
        Float.floor(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.floor(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.floor(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.floor(negativeNaN)),
        holds,
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
        isPositiveZero(Float.trunc(positiveZero)),
        holds,
      ),
      test(
        "negative zero",
        isNegativeZero(Float.trunc(negativeZero)),
        holds,
      ),
      test(
        "positive infinity",
        Float.trunc(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.trunc(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.trunc(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.trunc(negativeNaN)),
        holds,
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
        Float.nearest(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.nearest(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.nearest(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.nearest(negativeNaN)),
        holds,
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
        isNegativeZero(Float.copySign(0.0, -1)),
        holds,
      ),
      test(
        "keep positive zero",
        isPositiveZero(Float.copySign(0.0, 1)),
        holds,
      ),
      test(
        "negate by negative zero",
        Float.copySign(2.1, negativeZero),
        M.equals(FloatTestable(-2.1, noEpsilon)),
      ),
      test(
        "positive infinity",
        Float.copySign(1.2, positiveInfinity),
        M.equals(FloatTestable(1.2, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.copySign(1.2, negativeInfinity),
        M.equals(FloatTestable(-1.2, noEpsilon)),
      ),
      test(
        "keep positive NaN",
        isPositiveNaN(Float.copySign(positiveNaN, 1.0)),
        holds,
      ),
      test(
        "negate positive NaN",
        isNegativeNaN(Float.copySign(positiveNaN, -1.0)),
        holds,
      ),
      test(
        "keep negative NaN",
        isNegativeNaN(Float.copySign(negativeNaN, -1.0)),
        holds,
      ),
      test(
        "negate negative NaN",
        isPositiveNaN(Float.copySign(negativeNaN, 1.0)),
        holds,
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
        isNaN(Float.copySign(negativeNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isPositiveNaN(Float.copySign(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNegativeNaN(Float.copySign(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and positive NaN",
        Float.copySign(positiveInfinity, positiveNaN),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and negative NaN",
        Float.copySign(positiveInfinity, negativeNaN),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and positive NaN",
        Float.copySign(negativeInfinity, positiveNaN),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and negative NaN",
        Float.copySign(negativeInfinity, negativeNaN),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
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
        isNegativeZero(Float.min(positiveZero, negativeZero)),
        holds,
      ),
      test(
        "positive infinity",
        Float.min(1.23, positiveInfinity),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.min(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.min(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "left NaN",
        isNaN(Float.min(positiveNaN, 1.0)),
        holds,
      ),
      test(
        "right NaN",
        isNaN(Float.min(-1.0, positiveNaN)),
        holds,
      ),
      test(
        "both NaN",
        isNaN(Float.min(negativeNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.min(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.min(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.min(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.min(negativeInfinity, positiveNaN)),
        holds,
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
        isPositiveZero(Float.max(positiveZero, negativeZero)),
        holds,
      ),
      test(
        "positive infinity",
        Float.max(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.max(1.23, negativeInfinity),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.max(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "left NaN",
        isNaN(Float.max(positiveNaN, 1.0)),
        holds,
      ),
      test(
        "right NaN",
        isNaN(Float.max(-1.0, positiveNaN)),
        holds,
      ),
      test(
        "both NaN",
        isNaN(Float.max(negativeNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.max(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.max(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.max(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.max(negativeInfinity, positiveNaN)),
        holds,
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
        isNaN(Float.sin(positiveInfinity)),
        holds,
      ),
      test(
        "negative infinity",
        isNaN(Float.sin(negativeInfinity)),
        holds,
      ),
      test(
        "positive NaN",
        isNaN(Float.sin(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.sin(negativeNaN)),
        holds,
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
        isNaN(Float.cos(positiveInfinity)),
        holds,
      ),
      test(
        "negative infinity",
        isNaN(Float.cos(negativeInfinity)),
        holds,
      ),
      test(
        "positive NaN",
        isNaN(Float.cos(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.cos(negativeNaN)),
        holds,
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
        isNaN(Float.tan(positiveInfinity)),
        holds,
      ),
      test(
        "negative infinity",
        isNaN(Float.tan(negativeInfinity)),
        holds,
      ),
      test(
        "positive NaN",
        isNaN(Float.tan(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.tan(negativeNaN)),
        holds,
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
        isNaN(Float.arcsin(1.01)),
        holds,
      ),
      test(
        "below 1",
        isNaN(Float.arcsin(-1.01)),
        holds,
      ),
      test(
        "positive NaN",
        isNaN(Float.arcsin(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.arcsin(negativeNaN)),
        holds,
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
        isNaN(Float.arccos(1.01)),
        holds,
      ),
      test(
        "below 1",
        isNaN(Float.arccos(-1.01)),
        holds,
      ),
      test(
        "positive NaN",
        isNaN(Float.arccos(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.arccos(negativeNaN)),
        holds,
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
        Float.arctan(positiveInfinity),
        M.equals(FloatTestable(ninetyDegrees, smallEpsilon)),
      ),
      test(
        "negative infinity",
        Float.arctan(negativeInfinity),
        M.equals(FloatTestable(-ninetyDegrees, smallEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.arctan(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.arctan(negativeNaN)),
        holds,
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
        isNegativeZero(Float.arctan2(negativeZero, 0.0)),
        M.equals(T.bool(true)),
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
        Float.arctan2(positiveInfinity, 0.0),
        M.equals(FloatTestable(ninetyDegrees, noEpsilon)),
      ),
      test(
        "left negative infinity",
        Float.arctan2(negativeInfinity, 0.0),
        M.equals(FloatTestable(-ninetyDegrees, noEpsilon)),
      ),
      test(
        "right positive infinity",
        Float.arctan2(0.0, positiveInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "right negative infinity",
        Float.arctan2(0.0, negativeInfinity),
        M.equals(FloatTestable(2 * ninetyDegrees, noEpsilon)),
      ),
      test(
        "both positive infinity",
        Float.arctan2(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "both negative infinity",
        Float.arctan2(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(-3 * fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.arctan2(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(3 * fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.arctan2(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(-fortyFiveDegrees, noEpsilon)),
      ),
      test(
        "left positive NaN",
        isNaN(Float.arctan2(positiveNaN, 0.0)),
        holds,
      ),
      test(
        "left negative NaN",
        isNaN(Float.arctan2(negativeNaN, 0.0)),
        holds,
      ),
      test(
        "right positive NaN",
        isNaN(Float.arctan2(0.0, positiveNaN)),
        holds,
      ),
      test(
        "left negative NaN",
        isNaN(Float.arctan2(0.0, negativeNaN)),
        holds,
      ),
      test(
        "two NaNs",
        isNaN(Float.arctan2(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.arctan2(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.arctan2(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.arctan2(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.arctan2(negativeInfinity, positiveNaN)),
        holds,
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
        Float.exp(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.exp(negativeInfinity),
        M.equals(FloatTestable(0.0, smallEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.exp(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.exp(negativeNaN)),
        holds,
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
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative zero",
        Float.log(negativeZero),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative",
        isNaN(Float.log(-0.01)),
        holds,
      ),
      test(
        "positive infinity",
        Float.log(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.log(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN",
        isNaN(Float.log(negativeNaN)),
        holds,
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
        Float.format(#exact, positiveInfinity),
        M.equals(T.text("inf")),
      ),
      test(
        "exact negative infinity",
        Float.format(#exact, negativeInfinity),
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
        Float.format(#fix 6, positiveInfinity),
        M.equals(T.text("inf")),
      ),
      test(
        "fix negative infinity",
        Float.format(#fix 6, negativeInfinity),
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
        Float.format(#exp 9, positiveInfinity),
        M.equals(T.text("inf")),
      ),
      test(
        "exp negative infinity",
        Float.format(#exp 9, negativeInfinity),
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
        Float.format(#gen 12, positiveInfinity),
        M.equals(T.text("inf")),
      ),
      test(
        "gen negative infinity",
        Float.format(#gen 12, negativeInfinity),
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
        Float.format(#hex 10, positiveInfinity),
        M.equals(T.text("inf")),
      ),
      test(
        "hex negative infinity",
        Float.format(#hex 10, negativeInfinity),
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
        Float.toText(positiveInfinity),
        M.equals(T.text("inf")),
      ),
      test(
        "negative infinity",
        Float.toText(negativeInfinity),
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
        isPositiveZero(Float.fromInt64(0)),
        M.equals(T.bool(true)),
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
        isPositiveZero(Float.fromInt(0)),
        M.equals(T.bool(true)),
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
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.fromInt(-3 ** 7777),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
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
        Float.equal(positiveInfinity, positiveInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity",
        Float.equal(negativeInfinity, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "mixed infinity signs",
        Float.equal(positiveInfinity, negativeInfinity),
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
        Float.equal(positiveNaN, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.equal(positiveNaN, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.equal(positiveInfinity, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.equal(negativeInfinity, positiveNaN),
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
        Float.notEqual(positiveInfinity, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity",
        Float.notEqual(negativeInfinity, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "mixed infinity signs",
        Float.notEqual(positiveInfinity, negativeInfinity),
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
        Float.notEqual(positiveNaN, positiveInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "NaN and negative infinity",
        Float.notEqual(positiveNaN, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity and NaN",
        Float.notEqual(positiveInfinity, positiveNaN),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity and NaN",
        Float.notEqual(negativeInfinity, positiveNaN),
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
        Float.less(1.23, positiveInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity and number",
        Float.less(positiveInfinity, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "number and negative infinity",
        Float.less(1.23, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and number",
        Float.less(negativeInfinity, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "double positive infinity",
        Float.less(positiveInfinity, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive and negative infinity",
        Float.less(positiveInfinity, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "double negative infinity",
        Float.less(negativeInfinity, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "negative and positive infinity",
        Float.less(negativeInfinity, positiveInfinity),
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
        Float.less(positiveNaN, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.less(positiveNaN, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.less(positiveInfinity, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.less(negativeInfinity, positiveNaN),
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
        Float.lessOrEqual(1.23, positiveInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity and number",
        Float.lessOrEqual(positiveInfinity, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "number and negative infinity",
        Float.lessOrEqual(1.23, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and number",
        Float.lessOrEqual(negativeInfinity, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "double positive infinity",
        Float.lessOrEqual(positiveInfinity, positiveInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "positive and negative infinity",
        Float.lessOrEqual(positiveInfinity, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "double negative infinity",
        Float.lessOrEqual(negativeInfinity, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "negative and positive infinity",
        Float.lessOrEqual(negativeInfinity, positiveInfinity),
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
        Float.lessOrEqual(positiveNaN, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.lessOrEqual(positiveNaN, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.lessOrEqual(positiveInfinity, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.lessOrEqual(negativeInfinity, positiveNaN),
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
        Float.greater(1.23, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and number",
        Float.greater(positiveInfinity, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "number and negative infinity",
        Float.greater(1.23, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity and number",
        Float.greater(negativeInfinity, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "double positive infinity",
        Float.greater(positiveInfinity, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive and negative infinity",
        Float.greater(positiveInfinity, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "double negative infinity",
        Float.greater(negativeInfinity, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "negative and positive infinity",
        Float.greater(negativeInfinity, positiveInfinity),
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
        Float.greater(positiveNaN, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.greater(positiveNaN, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.greater(positiveInfinity, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.greater(negativeInfinity, positiveNaN),
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
        Float.greaterOrEqual(1.23, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and number",
        Float.greaterOrEqual(positiveInfinity, 1.23),
        M.equals(T.bool(true)),
      ),
      test(
        "number and negative infinity",
        Float.greaterOrEqual(1.23, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity and number",
        Float.greaterOrEqual(negativeInfinity, 1.23),
        M.equals(T.bool(false)),
      ),
      test(
        "double positive infinity",
        Float.greaterOrEqual(positiveInfinity, positiveInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "positive and negative infinity",
        Float.greaterOrEqual(positiveInfinity, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "double negative infinity",
        Float.greaterOrEqual(negativeInfinity, negativeInfinity),
        M.equals(T.bool(true)),
      ),
      test(
        "negative and positive infinity",
        Float.greaterOrEqual(negativeInfinity, positiveInfinity),
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
        Float.greaterOrEqual(positiveNaN, positiveInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "NaN and negative infinity",
        Float.greaterOrEqual(positiveNaN, negativeInfinity),
        M.equals(T.bool(false)),
      ),
      test(
        "positive infinity and NaN",
        Float.greaterOrEqual(positiveInfinity, positiveNaN),
        M.equals(T.bool(false)),
      ),
      test(
        "negative infinity and NaN",
        Float.greaterOrEqual(negativeInfinity, positiveNaN),
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
    x == y
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
        Float.compare(1.23, positiveInfinity),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "positive infinity and number",
        Float.compare(positiveInfinity, 1.23),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "number and negative infinity",
        Float.compare(1.23, negativeInfinity),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "negative infinity and number",
        Float.compare(negativeInfinity, 1.23),
        M.equals(OrderTestable(#less)),
      ),
      test(
        "double positive infinity",
        Float.compare(positiveInfinity, positiveInfinity),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "positive and negative infinity",
        Float.compare(positiveInfinity, negativeInfinity),
        M.equals(OrderTestable(#greater)),
      ),
      test(
        "double negative infinity",
        Float.compare(negativeInfinity, negativeInfinity),
        M.equals(OrderTestable(#equal)),
      ),
      test(
        "negative and positive infinity",
        Float.compare(negativeInfinity, positiveInfinity),
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
        Float.compare(positiveNaN, positiveInfinity),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "NaN and negative infinity",
        Float.compare(positiveNaN, negativeInfinity),
        M.equals(OrderTestable(#greater)), // Conceptually wrong, needs to be fixed
      ),
      test(
        "positive infinity and NaN",
        Float.compare(positiveInfinity, positiveNaN),
        M.equals(OrderTestable(#greater)), // Inconsistent, needs to be fixed
      ),
      test(
        "negative infinity and NaN",
        Float.compare(negativeInfinity, positiveNaN),
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
        Float.neq(1.1),
        M.equals(FloatTestable(-1.1, noEpsilon)),
      ),
      test(
        "negative number",
        Float.neq(-1.1),
        M.equals(FloatTestable(1.1, noEpsilon)),
      ),
      test(
        "zero",
        Float.neq(0.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      // fails due to issue, probably related to https://github.com/dfinity/motoko/issues/3646
      // test(
      //   "positive zero",
      //   isNegativeZero(Float.neq(positiveZero)), 
      //   holds,
      // ),
      test(
        "negative zero",
        isPositiveZero(Float.neq(negativeZero)), 
        holds,
      ),
      test(
        "positive infinity",
        Float.neq(positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative infinity",
        Float.neq(negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive NaN (provisional test)",
        isNaN(Float.neq(positiveNaN)),
        holds,
      ),
      test(
        "negative NaN (provisional test)",
        isNaN(Float.neq(negativeNaN)),
        holds,
      ),
      // Not working correctly, probably related to https://github.com/dfinity/motoko/issues/3646
      // test(
      //   "positive NaN",
      //   isNegativeNaN(Float.neq(positiveNaN)),
      //   holds,
      // ),
      // test(
      //   "negative NaN",
      //   isPositiveNaN(Float.neq(negativeNaN)),
      //   holds,
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
        Float.add(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and number",
        Float.add(positiveInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "number and negative infinity",
        Float.add(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and number",
        Float.add(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.add(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        isNaN(Float.add(positiveInfinity, negativeInfinity)),
        holds,
      ),
      test(
        "double negative infinity",
        Float.add(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        isNaN(Float.add(negativeInfinity, positiveInfinity)),
        holds,
      ),
      test(
        "two positive NaNs",
        isNaN(Float.add(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "two negative NaNs",
        isNaN(Float.add(negativeNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaNs with mixed signs",
        isNaN(Float.add(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "number and NaN",
        isNaN(Float.add(1.23, positiveNaN)),
        holds,
      ),
      test(
        "NaN and number",
        isNaN(Float.add(positiveNaN, -1.23)),
        holds,
      ),
      test(
        "NaN and NaN",
        isNaN(Float.add(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.add(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.add(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.add(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.add(negativeInfinity, positiveNaN)),
        holds,
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
        Float.sub(1.23, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and number",
        Float.sub(positiveInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "number and negative infinity",
        Float.sub(1.23, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and number",
        Float.sub(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "double positive infinity",
        isNaN(Float.sub(positiveInfinity, positiveInfinity)),
        holds,
      ),
      test(
        "positive and negative infinity",
        Float.sub(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "double negative infinity",
        isNaN(Float.sub(negativeInfinity, negativeInfinity)),
        holds,
      ),
      test(
        "negative and positive infinity",
        Float.sub(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "two positive NaNs",
        isNaN(Float.sub(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "two negative NaNs",
        isNaN(Float.sub(negativeNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaNs with mixed signs",
        isNaN(Float.sub(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "number and NaN",
        isNaN(Float.sub(1.23, positiveNaN)),
        holds,
      ),
      test(
        "NaN and number",
        isNaN(Float.sub(positiveNaN, -1.23)),
        holds,
      ),
      test(
        "NaN and NaN",
        isNaN(Float.sub(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.sub(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.sub(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.sub(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.sub(negativeInfinity, positiveNaN)),
        holds,
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
        Float.mul(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative number and positive infinity",
        Float.mul(-1.23, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "zero and positive infinity",
        isNaN(Float.mul(0.0, positiveInfinity)),
        holds,
      ),
      test(
        "positive infinity and positive number",
        Float.mul(positiveInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and negative number",
        Float.mul(positiveInfinity, -1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and zero",
        isNaN(Float.mul(positiveInfinity, 0.0)),
        holds,
      ),
      test(
        "positive number and negative infinity",
        Float.mul(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative number and negative infinity",
        Float.mul(-1.23, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "zero and negative infinity",
        isNaN(Float.mul(0.0, negativeInfinity)),
        holds,
      ),
      test(
        "negative infinity and positive number",
        Float.mul(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and negative number",
        Float.mul(negativeInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and zero",
        isNaN(Float.mul(negativeInfinity, 0.0)),
        holds,
      ),
      test(
        "double positive infinity",
        Float.mul(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.mul(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.mul(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.mul(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "two positive NaNs",
        isNaN(Float.mul(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "two negative NaNs",
        isNaN(Float.mul(negativeNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaNs with mixed signs",
        isNaN(Float.mul(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "number and NaN",
        isNaN(Float.mul(1.23, positiveNaN)),
        holds,
      ),
      test(
        "zero and NaN",
        isNaN(Float.mul(0.0, positiveNaN)),
        holds,
      ),
      test(
        "NaN and number",
        isNaN(Float.mul(positiveNaN, -1.23)),
        holds,
      ),
      test(
        "NaN and zero",
        isNaN(Float.mul(positiveNaN, 0.0)),
        holds,
      ),
      test(
        "NaN and NaN",
        isNaN(Float.mul(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.mul(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.mul(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.mul(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.mul(negativeInfinity, positiveNaN)),
        holds,
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
        isNaN(Float.div(positiveZero, positiveZero)),
        holds,
      ),
      test(
        "negative zeros",
        isNaN(Float.div(negativeZero, negativeZero)),
        holds,
      ),
      test(
        "positive and negative zero",
        isNegativeNaN(Float.div(positiveZero, negativeZero)),
        holds,
      ),
      test(
        "negative and positive zero",
        isNegativeNaN(Float.div(negativeZero, positiveZero)),
        holds,
      ),
      test(
        "positive number and positive infinity",
        isPositiveZero(Float.div(1.23, positiveInfinity)),
        holds,
      ),
      test(
        "negative number and positive infinity",
        isNegativeZero(Float.div(-1.23, positiveInfinity)),
        holds,
      ),
      test(
        "positive infinity and negative number",
        Float.div(positiveInfinity, -1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and zero",
        Float.div(positiveInfinity, 0.0),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and positive number",
        Float.div(positiveInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive number and negative infinity",
        isNegativeZero(Float.div(1.23, negativeInfinity)),
        holds,
      ),
      test(
        "negative number and negative infinity",
        isPositiveZero(Float.div(-1.23, negativeInfinity)),
        holds,
      ),
      test(
        "negative infinity and positive number",
        Float.div(negativeInfinity, 1.23),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and negative number",
        Float.div(negativeInfinity, -1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and zero",
        Float.div(negativeInfinity, 0.0),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "double positive infinity",
        isNaN(Float.div(positiveInfinity, positiveInfinity)),
        holds,
      ),
      test(
        "positive and negative infinity",
        isNegativeNaN(Float.div(positiveInfinity, negativeInfinity)),
        holds,
      ),
      test(
        "double negative infinity",
        isNaN(Float.div(negativeInfinity, negativeInfinity)),
        holds,
      ),
      test(
        "negative and positive infinity",
        isNegativeNaN(Float.div(negativeInfinity, positiveInfinity)),
        holds,
      ),
      test(
        "two positive NaNs",
        isNaN(Float.div(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "two negative NaNs",
        isNaN(Float.div(negativeNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaNs with mixed signs",
        isNaN(Float.div(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "number and NaN",
        isNaN(Float.div(1.23, positiveNaN)),
        holds,
      ),
      test(
        "NaN and number",
        isNaN(Float.div(positiveNaN, -1.23)),
        holds,
      ),
      test(
        "NaN and NaN",
        isNaN(Float.div(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.div(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.div(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.div(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.div(negativeInfinity, positiveNaN)),
        holds,
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
        isNaN(Float.rem(positiveZero, positiveZero)),
        holds,
      ),
      test(
        "negative zeros",
        isNaN(Float.rem(negativeZero, negativeZero)),
        holds,
      ),
      test(
        "positive and negative zero",
        isNegativeNaN(Float.rem(positiveZero, negativeZero)),
        holds,
      ),
      test(
        "negative and positive zero",
        isNegativeNaN(Float.rem(negativeZero, positiveZero)),
        holds,
      ),
      test(
        "positive number and positive infinity",
        Float.rem(1.23, positiveInfinity),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "negative number and positive infinity",
        Float.rem(-1.23, positiveInfinity),
        M.equals(FloatTestable(-1.23, noEpsilon)),
      ),
      test(
        "zero and positive infinity",
        Float.rem(0.0, positiveInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive infinity and positive number",
        isNaN(Float.rem(positiveInfinity, 1.23)),
        holds,
      ),
      test(
        "positive infinity and negative number",
        isNaN(Float.rem(positiveInfinity, -1.23)),
        holds,
      ),
      test(
        "positive infinity and zero",
        isNaN(Float.rem(positiveInfinity, 0.0)),
        holds,
      ),
      test(
        "positive number and negative infinity",
        Float.rem(1.23, negativeInfinity),
        M.equals(FloatTestable(1.23, noEpsilon)),
      ),
      test(
        "negative number and negative infinity",
        Float.rem(-1.23, negativeInfinity),
        M.equals(FloatTestable(-1.23, noEpsilon)),
      ),
      test(
        "zero and negative infinity",
        Float.rem(0.0, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative infinity and positive number",
        isNaN(Float.rem(negativeInfinity, 1.23)),
        holds,
      ),
      test(
        "negative infinity and negative number",
        isNaN(Float.rem(negativeInfinity, -1.23)),
        holds,
      ),
      test(
        "negative infinity and zero",
        isNaN(Float.rem(negativeInfinity, 0.0)),
        holds,
      ),
      test(
        "double positive infinity",
        isNaN(Float.rem(positiveInfinity, positiveInfinity)),
        holds,
      ),
      test(
        "positive and negative infinity",
        isNegativeNaN(Float.rem(positiveInfinity, negativeInfinity)),
        holds,
      ),
      test(
        "double negative infinity",
        isNaN(Float.rem(negativeInfinity, negativeInfinity)),
        holds,
      ),
      test(
        "negative and positive infinity",
        isNegativeNaN(Float.rem(negativeInfinity, positiveInfinity)),
        holds,
      ),
      test(
        "two positive NaNs",
        isNaN(Float.rem(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "two negative NaNs",
        isNaN(Float.rem(negativeNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaNs with mixed signs",
        isNaN(Float.rem(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "number and NaN",
        isNaN(Float.rem(1.23, positiveNaN)),
        holds,
      ),
      test(
        "NaN and number",
        isNaN(Float.rem(positiveNaN, -1.23)),
        holds,
      ),
      test(
        "NaN and NaN",
        isNaN(Float.rem(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.rem(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative infinity",
        isNaN(Float.rem(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "positive infinity and NaN",
        isNaN(Float.rem(positiveInfinity, positiveNaN)),
        holds,
      ),
      test(
        "negative infinity and NaN",
        isNaN(Float.rem(negativeInfinity, positiveNaN)),
        holds,
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
        isNaN(Float.pow(-7.2, 3.2)),
        holds,
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
        isNaN(Float.pow(-7.2, -3.2)),
        holds,
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
        Float.pow(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "zero and positive infinity",
        Float.pow(0.0, positiveInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative number and positive infinity",
        Float.pow(-1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and positive number",
        Float.pow(positiveInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive infinity and negative number",
        Float.pow(positiveInfinity, -0.1),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "positive infinity and zero",
        Float.pow(positiveInfinity, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "positive number and negative infinity",
        Float.pow(1.23, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative number and negative infinity",
        Float.pow(-1.23, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "zero and negative infinity",
        Float.pow(0.0, negativeInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and positive odd positive number",
        Float.pow(negativeInfinity, 3.0),
        M.equals(FloatTestable(negativeInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and positive odd negative number",
        Float.pow(negativeInfinity, -3.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative infinity and positive even positive number",
        Float.pow(negativeInfinity, 4.0),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and positive even negative number",
        Float.pow(negativeInfinity, -4.0),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative infinity and zero",
        Float.pow(negativeInfinity, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "negative infinity and non-integral positive number",
        Float.pow(negativeInfinity, 1.23),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative infinity and non-integral negative number",
        Float.pow(negativeInfinity, -1.23),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "double positive infinity",
        Float.pow(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive and negative infinity",
        Float.pow(positiveInfinity, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "double negative infinity",
        Float.pow(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(0.0, noEpsilon)),
      ),
      test(
        "negative and positive infinity",
        Float.pow(negativeInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "two positive NaNs",
        isNaN(Float.pow(positiveNaN, positiveNaN)),
        holds,
      ),
      test(
        "two negative NaNs",
        isNaN(Float.pow(negativeNaN, negativeNaN)),
        holds,
      ),
      test(
        "NaNs with mixed signs",
        isNaN(Float.pow(positiveNaN, negativeNaN)),
        holds,
      ),
      test(
        "number and NaN",
        isNaN(Float.pow(1.23, positiveNaN)),
        holds,
      ),
      test(
        "NaN and number",
        isNaN(Float.pow(positiveNaN, 2.0)),
        holds,
      ),
      test(
        "NaN and zero",
        Float.pow(positiveNaN, 0.0),
        M.equals(FloatTestable(1.0, noEpsilon)),
      ),
      test(
        "NaN and positive infinity",
        isNaN(Float.pow(positiveNaN, positiveInfinity)),
        holds,
      ),
      test(
        "NaN and negative Infinity",
        isNaN(Float.pow(positiveNaN, negativeInfinity)),
        holds,
      ),
      test(
        "NaN and NaN",
        isNaN(Float.pow(positiveNaN, positiveNaN)),
        holds,
      ),
    ],
  ),
);
