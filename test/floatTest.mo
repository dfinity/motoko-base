import Debug "mo:base/Debug";
import Float "mo:base/Float";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

class FloatTestable(number : Float) : T.TestableItem<Float> {
  public let item = number;
  public func display(number : Float) : Text {
    debug_show (number);
  };
  public let equals = func(x : Float, y : Float) : Bool { x == y };
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

// Using exact equality below as the results are chosen to be free of numerical errors.

/* --------------------------------------- */

run(
  suite(
    "abs",
    [
      test(
        "positive number",
        Float.abs(1.1),
        M.equals(FloatTestable(1.1)),
      ),
      test(
        "negative number",
        Float.abs(-1.1),
        M.equals(FloatTestable(1.1)),
      ),
      test(
        "zero",
        Float.abs(0.0),
        M.equals(FloatTestable(0.0)),
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
        M.equals(FloatTestable(positiveInfinity)),
      ),
      test(
        "negative infinity",
        Float.abs(negativeInfinity),
        M.equals(FloatTestable(positiveInfinity)),
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
        M.equals(FloatTestable(2.5)),
      ),
      test(
        "zero",
        Float.sqrt(0.0),
        M.equals(FloatTestable(0.0)),
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
        M.equals(FloatTestable(positiveInfinity)),
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
        M.equals(FloatTestable(2.0)),
      ),
      test(
        "negative fraction",
        Float.ceil(-1.2),
        M.equals(FloatTestable(-1.0)),
      ),
      test(
        "integral number",
        Float.ceil(-3.0),
        M.equals(FloatTestable(-3.0)),
      ),
      test(
        "zero",
        Float.ceil(0.0),
        M.equals(FloatTestable(0.0)),
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
        M.equals(FloatTestable(positiveInfinity)),
      ),
      test(
        "negative infinity",
        Float.ceil(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity)),
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
        M.equals(FloatTestable(1.0)),
      ),
      test(
        "negative fraction",
        Float.floor(-1.2),
        M.equals(FloatTestable(-2.0)),
      ),
      test(
        "integral number",
        Float.floor(3.0),
        M.equals(FloatTestable(3.0)),
      ),
      test(
        "zero",
        Float.floor(0.0),
        M.equals(FloatTestable(0.0)),
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
        M.equals(FloatTestable(positiveInfinity)),
      ),
      test(
        "negative infinity",
        Float.floor(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity)),
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
        M.equals(FloatTestable(3.0)),
      ),
      test(
        "negative fraction",
        Float.trunc(-3.9123),
        M.equals(FloatTestable(-3.0)),
      ),
      test(
        "integral number",
        Float.trunc(3.0),
        M.equals(FloatTestable(3.0)),
      ),
      test(
        "zero",
        Float.trunc(0.0),
        M.equals(FloatTestable(0.0)),
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
        M.equals(FloatTestable(positiveInfinity)),
      ),
      test(
        "negative infinity",
        Float.trunc(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity)),
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
        M.equals(FloatTestable(4.0)),
      ),
      test(
        "negative round down",
        Float.nearest(-3.75),
        M.equals(FloatTestable(-4.0)),
      ),
      test(
        "positive round down",
        Float.nearest(3.25),
        M.equals(FloatTestable(3.0)),
      ),
      test(
        "negative round up",
        Float.nearest(-3.25),
        M.equals(FloatTestable(-3.0)),
      ),
      test(
        "positive .5",
        Float.nearest(3.5),
        M.equals(FloatTestable(4.0)),
      ),
      test(
        "negative .5",
        Float.nearest(-3.5),
        M.equals(FloatTestable(-4.0)),
      ),
      test(
        "integral number",
        Float.nearest(3.0),
        M.equals(FloatTestable(3.0)),
      ),
      test(
        "positive infinity",
        Float.nearest(positiveInfinity),
        M.equals(FloatTestable(positiveInfinity)),
      ),
      test(
        "negative infinity",
        Float.nearest(negativeInfinity),
        M.equals(FloatTestable(negativeInfinity)),
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
        M.equals(FloatTestable(1.2)),
      ),
      test(
        "positive, negative",
        Float.copySign(1.2, -2.3),
        M.equals(FloatTestable(-1.2)),
      ),
      test(
        "both negative",
        Float.copySign(-1.2, -2.3),
        M.equals(FloatTestable(-1.2)),
      ),
      test(
        "negative, positive",
        Float.copySign(-1.2, 2.3),
        M.equals(FloatTestable(1.2)),
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
        M.equals(FloatTestable(-2.1)),
      ),
      test(
        "positive infinity",
        Float.copySign(1.2, positiveInfinity),
        M.equals(FloatTestable(1.2)),
      ),
      test(
        "negative infinity",
        Float.copySign(1.2, negativeInfinity),
        M.equals(FloatTestable(-1.2)),
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
        M.equals(FloatTestable(1.2)),
      ),
      test(
        "second argument negative NaN",
        Float.copySign(1.2, negativeNaN),
        M.equals(FloatTestable(-1.2)),
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
        M.equals(FloatTestable(1.2)),
      ),
      test(
        "positive, negative",
        Float.min(1.2, -2.3),
        M.equals(FloatTestable(-2.3)),
      ),
      test(
        "both negative",
        Float.min(-1.2, -2.3),
        M.equals(FloatTestable(-2.3)),
      ),
      test(
        "negative, positive",
        Float.min(-1.2, 2.3),
        M.equals(FloatTestable(-1.2)),
      ),
      test(
        "equal values",
        Float.min(1.23, 1.23),
        M.equals(FloatTestable(1.23)),
      ),
      test(
        "zero with different signs",
        isNegativeZero(Float.min(positiveZero, negativeZero)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity",
        Float.min(1.23, positiveInfinity),
        M.equals(FloatTestable(1.23)),
      ),
      test(
        "negative infinity",
        Float.min(1.23, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity)),
      ),
      test(
        "double negative infinity",
        Float.min(negativeInfinity, negativeInfinity),
        M.equals(FloatTestable(negativeInfinity)),
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
        M.equals(FloatTestable(2.3)),
      ),
      test(
        "positive, negative",
        Float.max(1.2, -2.3),
        M.equals(FloatTestable(1.2)),
      ),
      test(
        "both negative",
        Float.max(-1.2, -2.3),
        M.equals(FloatTestable(-1.2)),
      ),
      test(
        "negative, positive",
        Float.max(-1.2, 2.3),
        M.equals(FloatTestable(2.3)),
      ),
      test(
        "equal values",
        Float.max(1.23, 1.23),
        M.equals(FloatTestable(1.23)),
      ),
      test(
        "zero with different signs",
        isPositiveZero(Float.max(positiveZero, negativeZero)),
        M.equals(T.bool(true)),
      ),
      test(
        "positive infinity",
        Float.max(1.23, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity)),
      ),
      test(
        "negative infinity",
        Float.max(1.23, negativeInfinity),
        M.equals(FloatTestable(1.23)),
      ),
      test(
        "double positive infinity",
        Float.max(positiveInfinity, positiveInfinity),
        M.equals(FloatTestable(positiveInfinity)),
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



do {
  Debug.print("  sin");

  assert (Float.sin(0.0) == 0.0);
};

do {
  Debug.print("  cos");

  assert (Float.cos(0.0) == 1.0);
};

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
