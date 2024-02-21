// @testmode wasi

import Int "../src/Int";
import Order "../src/Order";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let largeNumber = 123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000;
let largeNumberText = "123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000";

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

/* --------------------------------------- */

run(
  suite(
    "abs",
    [
      test(
        "positive number",
        Int.abs(123),
        M.equals(T.int(123))
      ),
      test(
        "negative number",
        Int.abs(-123),
        M.equals(T.int(+123))
      ),
      test(
        "zero",
        Int.abs(0),
        M.equals(T.int(0))
      ),
      test(
        "large positive int",
        Int.abs(largeNumber),
        M.equals(T.int(largeNumber))
      ),
      test(
        "large negative int",
        Int.abs(-largeNumber),
        M.equals(T.int(largeNumber))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "toText",
    [
      test(
        "all digits",
        Int.toText(1234567890),
        M.equals(T.text("1234567890"))
      ),
      test(
        "positive number",
        Int.toText(1234),
        M.equals(T.text("1234"))
      ),
      test(
        "negative number",
        Int.toText(-1234),
        M.equals(T.text("-1234"))
      ),
      test(
        "zero",
        Int.toText(0),
        M.equals(T.text("0"))
      ),
      test(
        "large number",
        Int.toText(largeNumber),
        M.equals(T.text(largeNumberText))
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
        Int.min(2, 3),
        M.equals(T.int(2))
      ),
      test(
        "positive, negative",
        Int.min(+2, -3),
        M.equals(T.int(-3))
      ),
      test(
        "both negative",
        Int.min(-2, -3),
        M.equals(T.int(-3))
      ),
      test(
        "negative, positive",
        Int.min(-2, 3),
        M.equals(T.int(-2))
      ),
      test(
        "equal values",
        Int.min(123, 123),
        M.equals(T.int(123))
      ),
      test(
        "large numbers",
        Int.min(largeNumber, largeNumber + 1),
        M.equals(T.int(largeNumber))
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
        Int.max(2, 3),
        M.equals(T.int(3))
      ),
      test(
        "positive, negative",
        Int.max(2, -3),
        M.equals(T.int(2))
      ),
      test(
        "both negative",
        Int.max(-2, -3),
        M.equals(T.int(-2))
      ),
      test(
        "negative, positive",
        Int.max(-2, 3),
        M.equals(T.int(3))
      ),
      test(
        "equal values",
        Int.max(+123, 123),
        M.equals(T.int(123))
      ),
      test(
        "large numbers",
        Int.max(largeNumber, largeNumber + 1),
        M.equals(T.int(largeNumber + 1))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "equal",
    [
      test(
        "positive equal",
        Int.equal(123, 123),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal",
        Int.equal(-123, -123),
        M.equals(T.bool(true))
      ),
      test(
        "zero",
        Int.equal(0, 0),
        M.equals(T.bool(true))
      ),
      test(
        "positive not equal",
        Int.equal(123, 124),
        M.equals(T.bool(false))
      ),
      test(
        "negative not equal",
        Int.equal(-123, -124),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs",
        Int.equal(123, -123),
        M.equals(T.bool(false))
      ),
      test(
        "large equal",
        Int.equal(largeNumber, largeNumber),
        M.equals(T.bool(true))
      ),
      test(
        "large not equal",
        Int.equal(largeNumber, largeNumber + 1),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "notEqual",
    [
      test(
        "positive equal",
        Int.notEqual(123, 123),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal",
        Int.notEqual(-123, -123),
        M.equals(T.bool(false))
      ),
      test(
        "zero",
        Int.notEqual(0, 0),
        M.equals(T.bool(false))
      ),
      test(
        "positive not equal",
        Int.notEqual(123, 124),
        M.equals(T.bool(true))
      ),
      test(
        "negative not equal",
        Int.notEqual(-123, -124),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs",
        Int.notEqual(123, -123),
        M.equals(T.bool(true))
      ),
      test(
        "large equal",
        Int.notEqual(largeNumber, largeNumber),
        M.equals(T.bool(false))
      ),
      test(
        "large not equal",
        Int.notEqual(largeNumber, largeNumber + 1),
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
        Int.less(123, 123),
        M.equals(T.bool(false))
      ),
      test(
        "positive less",
        Int.less(123, 245),
        M.equals(T.bool(true))
      ),
      test(
        "positive greater",
        Int.less(245, 123),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal",
        Int.less(-123, -123),
        M.equals(T.bool(false))
      ),
      test(
        "negative less",
        Int.less(-245, -123),
        M.equals(T.bool(true))
      ),
      test(
        "negative greater",
        Int.less(-123, -245),
        M.equals(T.bool(false))
      ),
      test(
        "zero",
        Int.less(0, 0),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs less",
        Int.less(-123, 123),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs greater",
        Int.less(123, -123),
        M.equals(T.bool(false))
      ),
      test(
        "large numbers less",
        Int.less(largeNumber, largeNumber + 1),
        M.equals(T.bool(true))
      ),
      test(
        "large numbers equal",
        Int.less(largeNumber, largeNumber),
        M.equals(T.bool(false))
      ),
      test(
        "large numbers greater",
        Int.less(largeNumber + 1, largeNumber),
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
        Int.lessOrEqual(123, 123),
        M.equals(T.bool(true))
      ),
      test(
        "positive less",
        Int.lessOrEqual(123, 245),
        M.equals(T.bool(true))
      ),
      test(
        "positive greater",
        Int.lessOrEqual(245, 123),
        M.equals(T.bool(false))
      ),
      test(
        "negative equal",
        Int.lessOrEqual(-123, -123),
        M.equals(T.bool(true))
      ),
      test(
        "negative less",
        Int.lessOrEqual(-245, -123),
        M.equals(T.bool(true))
      ),
      test(
        "negative greater",
        Int.lessOrEqual(-123, -245),
        M.equals(T.bool(false))
      ),
      test(
        "zero",
        Int.lessOrEqual(0, 0),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs less",
        Int.lessOrEqual(-123, 123),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs greater",
        Int.lessOrEqual(123, -123),
        M.equals(T.bool(false))
      ),
      test(
        "large numbers less",
        Int.lessOrEqual(largeNumber, largeNumber + 1),
        M.equals(T.bool(true))
      ),
      test(
        "large numbers equal",
        Int.lessOrEqual(largeNumber, largeNumber),
        M.equals(T.bool(true))
      ),
      test(
        "large numbers greater",
        Int.lessOrEqual(largeNumber + 1, largeNumber),
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
        Int.greater(123, 123),
        M.equals(T.bool(false))
      ),
      test(
        "positive less",
        Int.greater(123, 245),
        M.equals(T.bool(false))
      ),
      test(
        "positive greater",
        Int.greater(245, 123),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal",
        Int.greater(-123, -123),
        M.equals(T.bool(false))
      ),
      test(
        "negative less",
        Int.greater(-245, -123),
        M.equals(T.bool(false))
      ),
      test(
        "negative greater",
        Int.greater(-123, -245),
        M.equals(T.bool(true))
      ),
      test(
        "zero",
        Int.greater(0, 0),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs less",
        Int.greater(-123, 123),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs greater",
        Int.greater(123, -123),
        M.equals(T.bool(true))
      ),
      test(
        "large numbers less",
        Int.greater(largeNumber, largeNumber + 1),
        M.equals(T.bool(false))
      ),
      test(
        "large numbers equal",
        Int.greater(largeNumber, largeNumber),
        M.equals(T.bool(false))
      ),
      test(
        "large numbers greater",
        Int.greater(largeNumber + 1, largeNumber),
        M.equals(T.bool(true))
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
        Int.greaterOrEqual(123, 123),
        M.equals(T.bool(true))
      ),
      test(
        "positive less",
        Int.greaterOrEqual(123, 245),
        M.equals(T.bool(false))
      ),
      test(
        "positive greater",
        Int.greaterOrEqual(245, 123),
        M.equals(T.bool(true))
      ),
      test(
        "negative equal",
        Int.greaterOrEqual(-123, -123),
        M.equals(T.bool(true))
      ),
      test(
        "negative less",
        Int.greaterOrEqual(-245, -123),
        M.equals(T.bool(false))
      ),
      test(
        "negative greater",
        Int.greaterOrEqual(-123, -245),
        M.equals(T.bool(true))
      ),
      test(
        "zero",
        Int.greaterOrEqual(0, 0),
        M.equals(T.bool(true))
      ),
      test(
        "mixed signs less",
        Int.greaterOrEqual(-123, 123),
        M.equals(T.bool(false))
      ),
      test(
        "mixed signs greater",
        Int.greaterOrEqual(123, -123),
        M.equals(T.bool(true))
      ),
      test(
        "large numbers less",
        Int.greaterOrEqual(largeNumber, largeNumber + 1),
        M.equals(T.bool(false))
      ),
      test(
        "large numbers equal",
        Int.greaterOrEqual(largeNumber, largeNumber),
        M.equals(T.bool(true))
      ),
      test(
        "large numbers greater",
        Int.greaterOrEqual(largeNumber + 1, largeNumber),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "compare",
    [
      test(
        "positive equal",
        Int.compare(123, 123),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "positive less",
        Int.compare(123, 245),
        M.equals(OrderTestable(#less))
      ),
      test(
        "positive greater",
        Int.compare(245, 123),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "negative equal",
        Int.compare(-123, -123),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "negative less",
        Int.compare(-245, -123),
        M.equals(OrderTestable(#less))
      ),
      test(
        "negative greater",
        Int.compare(-123, -245),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "zero",
        Int.compare(0, 0),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "mixed signs less",
        Int.compare(-123, 123),
        M.equals(OrderTestable(#less))
      ),
      test(
        "mixed signs greater",
        Int.compare(123, -123),
        M.equals(OrderTestable(#greater))
      ),
      test(
        "large numbers less",
        Int.compare(largeNumber, largeNumber + 1),
        M.equals(OrderTestable(#less))
      ),
      test(
        "large numbers equal",
        Int.compare(largeNumber, largeNumber),
        M.equals(OrderTestable(#equal))
      ),
      test(
        "large numbers greater",
        Int.compare(largeNumber + 1, largeNumber),
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
        Int.neg(123),
        M.equals(T.int(-123))
      ),
      test(
        "negative number",
        Int.neg(-123),
        M.equals(T.int(123))
      ),
      test(
        "zero",
        Int.neg(0),
        M.equals(T.int(0))
      ),
      test(
        "positive large number",
        Int.neg(largeNumber),
        M.equals(T.int(-largeNumber))
      ),
      test(
        "negative large number",
        Int.neg(-largeNumber),
        M.equals(T.int(largeNumber))
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
        Int.add(123, 123),
        M.equals(T.int(246))
      ),
      test(
        "negative",
        Int.add(-123, -123),
        M.equals(T.int(-246))
      ),
      test(
        "mixed signs",
        Int.add(-123, 223),
        M.equals(T.int(100))
      ),
      test(
        "zero",
        Int.add(0, 0),
        M.equals(T.int(0))
      ),
      test(
        "large addition",
        Int.add(largeNumber, largeNumber),
        M.equals(T.int(2 * largeNumber))
      ),
      test(
        "large subtraction",
        Int.add(largeNumber, -largeNumber),
        M.equals(T.int(0))
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
        Int.sub(123, 123),
        M.equals(T.int(0))
      ),
      test(
        "negative",
        Int.sub(-123, -123),
        M.equals(T.int(0))
      ),
      test(
        "mixed signs",
        Int.sub(-123, 223),
        M.equals(T.int(-346))
      ),
      test(
        "zero",
        Int.sub(0, 0),
        M.equals(T.int(0))
      ),
      test(
        "large addition",
        Int.sub(largeNumber, largeNumber),
        M.equals(T.int(0))
      ),
      test(
        "large subtraction",
        Int.sub(largeNumber, -largeNumber),
        M.equals(T.int(2 * largeNumber))
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
        Int.mul(123, 234),
        M.equals(T.int(28782))
      ),
      test(
        "negative",
        Int.mul(-123, -234),
        M.equals(T.int(28782))
      ),
      test(
        "mixed signs",
        Int.mul(-123, 234),
        M.equals(T.int(-28782))
      ),
      test(
        "zeros",
        Int.mul(0, 0),
        M.equals(T.int(0))
      ),
      test(
        "zero and large number",
        Int.mul(0, largeNumber),
        M.equals(T.int(0))
      ),
      test(
        "large number and zero",
        Int.mul(largeNumber, 0),
        M.equals(T.int(0))
      ),
      test(
        "large numbers",
        Int.mul(largeNumber, largeNumber),
        M.equals(T.int(largeNumber ** 2))
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
        "positive multiple",
        Int.div(156, 13),
        M.equals(T.int(12))
      ),
      test(
        "positive remainder",
        Int.div(1234, 100),
        M.equals(T.int(12))
      ),
      test(
        "negative multiple",
        Int.div(-156, -13),
        M.equals(T.int(12))
      ),
      test(
        "negative remainder",
        Int.div(-1234, -100),
        M.equals(T.int(12))
      ),
      test(
        "mixed signs",
        Int.div(-123, 23),
        M.equals(T.int(-5))
      ),
      test(
        "zero and number",
        Int.div(0, -123),
        M.equals(T.int(0))
      ),
      test(
        "zero and large number",
        Int.div(0, largeNumber),
        M.equals(T.int(0))
      ),
      test(
        "large number and number",
        Int.div(largeNumber, 123),
        M.equals(T.int(largeNumber / 123))
      ),
      test(
        "equal large numbers",
        Int.div(largeNumber, largeNumber),
        M.equals(T.int(1))
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
        "positive multiple",
        Int.rem(156, 13),
        M.equals(T.int(0))
      ),
      test(
        "positive/positive remainder",
        Int.rem(1234, 100),
        M.equals(T.int(34))
      ),
      test(
        "positive/negative remainder",
        Int.rem(1234, -100),
        M.equals(T.int(34))
      ),
      test(
        "negative multiple",
        Int.rem(-156, -13),
        M.equals(T.int(0))
      ),
      test(
        "negative/positive remainder",
        Int.rem(-1234, 100),
        M.equals(T.int(-34))
      ),
      test(
        "negative/negative remainder",
        Int.rem(-1234, -100),
        M.equals(T.int(-34))
      ),
      test(
        "zero and large number",
        Int.rem(0, largeNumber),
        M.equals(T.int(0))
      ),
      test(
        "large number and number",
        Int.rem(largeNumber * 123 + 100, 123),
        M.equals(T.int(100))
      ),
      test(
        "equal large numbers",
        Int.rem(largeNumber, largeNumber),
        M.equals(T.int(0))
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
        "positive base, positive exponent",
        Int.pow(72, 3),
        M.equals(T.int(373248))
      ),
      test(
        "positive base, zero exponent",
        Int.pow(72, 0),
        M.equals(T.int(1))
      ),
      test(
        "negative base, positive exponent",
        Int.pow(-72, 3),
        M.equals(T.int(-373248))
      ),
      test(
        "negative base, zero exponent",
        Int.pow(-72, 0),
        M.equals(T.int(1))
      ),
      test(
        "large number and zero",
        Int.pow(largeNumber, 0),
        M.equals(T.int(1))
      ),
      test(
        "positive large number and small number",
        Int.pow(largeNumber, 3),
        M.equals(T.int(largeNumber * largeNumber * largeNumber))
      ),
      test(
        "negative large number and small number",
        Int.pow(-largeNumber, 2),
        M.equals(T.int(largeNumber * largeNumber))
      ),
      test(
        "one and max Nat",
        Int.pow(1, 2 ** 32 - 1),
        M.equals(T.int(1))
      ),
      test(
        "zero and max Nat",
        Int.pow(0, 2 ** 32 - 1),
        M.equals(T.int(0))
      )
    ]
  )
)
