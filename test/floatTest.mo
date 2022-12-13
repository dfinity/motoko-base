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

func isNaN(number: Float): Bool {
  number != number
};

let positiveInfinity = 1.0/0.0;
let negativeInfinity = -1.0/0.0;
let negativeNaN = 0.0/0.0;
let positiveNaN = Float.copySign(negativeNaN, 1.0); // Compiler issue, NaN are represented negative by default. https://github.com/dfinity/motoko/issues/3647
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

// Some tests are adopted from Motoko compiler test `float-ops.mo`.

let ninetyDegrees = Float.pi / 2.0;
let fortyFiveDegrees = Float.pi / 4.0;
let arbitraryAngle = 0.123;
let sqrt2over2 = Float.sqrt(2) / 2;

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
        M.equals(T.bool(true)),
      ),
      test(
        "negative zero",
        isPositiveZero(Float.abs(negativeZero)), 
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.abs(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative zero",
        isNegativeZero(Float.sqrt(negativeZero)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity",
        Float.sqrt(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "negative",
        isNaN(Float.sqrt(-16.0)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive NaN",
        isNaN(Float.sqrt(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.sqrt(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative zero",
        isNegativeZero(Float.ceil(negativeZero)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.ceil(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative zero",
        isNegativeZero(Float.floor(negativeZero)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.floor(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative zero",
        isNegativeZero(Float.trunc(negativeZero)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.trunc(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.nearest(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "keep positive zero",
        isPositiveZero(Float.copySign(0.0, 1)),
        M.equals(T.bool(true)),
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
        debug_show(Float.copySign(positiveNaN, 1.0)),
        M.equals(T.text("nan")),
      ),
      test(
        "negate positive NaN",
        debug_show(Float.copySign(positiveNaN, -1.0)),
        M.equals(T.text("-nan")),
      ),
      test(
        "keep negative NaN",
        debug_show(Float.copySign(negativeNaN, -1.0)),
        M.equals(T.text("-nan")),
      ),
      test(
        "negate negative NaN",
        debug_show(Float.copySign(negativeNaN, 1.0)),
        M.equals(T.text("nan")),
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
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "right NaN",
        isNaN(Float.min(-1.0, positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "both NaN",
        isNaN(Float.min(negativeNaN, positiveNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "right NaN",
        isNaN(Float.max(-1.0, positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "both NaN",
        isNaN(Float.max(negativeNaN, positiveNaN)),
        M.equals(T.bool(true)),
      ),
    ],
  ),
);


/* --------------------------------------- */

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
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity",
        isNaN(Float.sin(negativeInfinity)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive NaN",
        isNaN(Float.sin(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.sin(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity",
        isNaN(Float.cos(negativeInfinity)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive NaN",
        isNaN(Float.cos(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.cos(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative infinity",
        isNaN(Float.tan(negativeInfinity)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive NaN",
        isNaN(Float.tan(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.tan(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "below 1",
        isNaN(Float.arcsin(-1.01)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive NaN",
        isNaN(Float.arcsin(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.arcsin(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "below 1",
        isNaN(Float.arccos(-1.01)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive NaN",
        isNaN(Float.arccos(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.arccos(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.arctan(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "left negative NaN",
        isNaN(Float.arctan2(negativeNaN, 0.0)),
        M.equals(T.bool(true)),
      ),
      test(
        "right positive NaN",
        isNaN(Float.arctan2(0.0, positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "left negative NaN",
        isNaN(Float.arctan2(0.0, negativeNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "two NaNs",
        isNaN(Float.arctan2(positiveNaN, negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.exp(negativeNaN)),
        M.equals(T.bool(true)),
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
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity",
        Float.log(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity, noEpsilon)),
      ),
      test(
        "positive NaN",
        isNaN(Float.log(positiveNaN)),
        M.equals(T.bool(true)),
      ),
      test(
        "negative NaN",
        isNaN(Float.log(negativeNaN)),
        M.equals(T.bool(true)),
      ),
    ],
  ),
);


do {
  Debug.print("  toFloat64");

  assert (Float.toInt64(1e10) == (10000000000 : Int64));
  assert (Float.toInt64(-1e10) == (-10000000000 : Int64));
};

do {
  Debug.print("  ofFloat64");

  assert (Float.fromInt64(10000000000) == 1e10);
  assert (Float.fromInt64(-10000000000) == -1e10);
};

do {
  Debug.print("  format");

  assert (Float.format(#exact, 20.12345678901) == "20.12345678901");
  assert (Float.format(#fix 6, 20.12345678901) == "20.123457");
  assert (Float.format(#exp 9, 20.12345678901) == "2.012345679e+01");
  assert (Float.format(#gen 12, 20.12345678901) == "20.123456789");
  assert (Float.format(#hex 10, 20.12345678901) == "0x1.41f9add374p+4");
};

do {
  Debug.print("  Pi: " # Float.toText(Float.pi));
  Debug.print("  arccos(-1.0): " # Float.toText(Float.arccos(-1.)));

  assert (Float.pi == Float.arccos(-1.));
};

do {
  Debug.print("  e: " # debug_show (Float.toText(Float.e)));
  Debug.print("  exp(1): " # debug_show (Float.toText(Float.exp(1))));

  assert (Float.e == Float.exp(1));
};
