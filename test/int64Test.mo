import Int64 "mo:base/Int64";
import Order "mo:base/Order";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let maximumInt64 = 9_223_372_036_854_775_807 : Int64;
let maximumInt64asInt = 9_223_372_036_854_775_807 : Int;
let maximumInt64asNat64 = 9_223_372_036_854_775_807 : Nat64;

let minimumInt64 = -9_223_372_036_854_775_808 : Int64;
let minimumInt64asInt = -9_223_372_036_854_775_808 : Int;

let maximumNat64 = 18_446_744_073_709_551_615 : Nat64;

class Int64Testable(number : Int64) : T.TestableItem<Int64> {
    public let item = number;
    public func display(number : Int64) : Text {
        debug_show (number)
    };
    public let equals = func(x : Int64, y : Int64) : Bool {
        x == y
    }
};

class Nat64Testable(number : Nat64) : T.TestableItem<Nat64> {
    public let item = number;
    public func display(number : Nat64) : Text {
        debug_show (number)
    };
    public let equals = func(x : Nat64, y : Nat64) : Bool {
        x == y
    }
};

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
        "toInt",
        [
            test(
                "maximum number",
                Int64.toInt(maximumInt64),
                M.equals(T.int(maximumInt64asInt))
            ),
            test(
                "minimum number",
                Int64.toInt(minimumInt64),
                M.equals(T.int(minimumInt64asInt))
            ),
            test(
                "one",
                Int64.toInt(1),
                M.equals(T.int(1))
            ),
            test(
                "minus one",
                Int64.toInt(-1),
                M.equals(T.int(-1))
            ),
            test(
                "zero",
                Int64.toInt(0),
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
                "maximum number",
                Int64.fromInt(maximumInt64asInt),
                M.equals(Int64Testable(maximumInt64))
            ),
            test(
                "minimum number",
                Int64.fromInt(minimumInt64asInt),
                M.equals(Int64Testable(minimumInt64))
            ),
            test(
                "one",
                Int64.fromInt(1),
                M.equals(Int64Testable(1))
            ),
            test(
                "minus one",
                Int64.fromInt(-1),
                M.equals(Int64Testable(-1))
            ),
            test(
                "zero",
                Int64.fromInt(0),
                M.equals(Int64Testable(0))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "fromIntWrap",
        [
            test(
                "maximum number",
                Int64.fromIntWrap(maximumInt64asInt),
                M.equals(Int64Testable(maximumInt64))
            ),
            test(
                "minimum number",
                Int64.fromIntWrap(minimumInt64asInt),
                M.equals(Int64Testable(minimumInt64))
            ),
            test(
                "one",
                Int64.fromIntWrap(1),
                M.equals(Int64Testable(1))
            ),
            test(
                "minus one",
                Int64.fromIntWrap(-1),
                M.equals(Int64Testable(-1))
            ),
            test(
                "zero",
                Int64.fromIntWrap(0),
                M.equals(Int64Testable(0))
            ),
            test(
                "overflow",
                Int64.fromIntWrap(maximumInt64asInt + 1),
                M.equals(Int64Testable(minimumInt64))
            ),
            test(
                "underflow",
                Int64.fromIntWrap(minimumInt64asInt - 1),
                M.equals(Int64Testable(maximumInt64))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "fromNat64",
        [
            test(
                "maximum number",
                Int64.fromNat64(maximumInt64asNat64),
                M.equals(Int64Testable(maximumInt64))
            ),
            test(
                "one",
                Int64.fromNat64(1),
                M.equals(Int64Testable(1))
            ),
            test(
                "zero",
                Int64.fromNat64(0),
                M.equals(Int64Testable(0))
            ),
            test(
                "overflow",
                Int64.fromNat64(maximumInt64asNat64 + 1),
                M.equals(Int64Testable(minimumInt64))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "toNat64",
        [
            test(
                "maximum number",
                Int64.toNat64(maximumInt64),
                M.equals(Nat64Testable(maximumInt64asNat64))
            ),
            test(
                "one",
                Int64.toNat64(1),
                M.equals(Nat64Testable(1))
            ),
            test(
                "zero",
                Int64.toNat64(0),
                M.equals(Nat64Testable(0))
            ),
            test(
                "underflow",
                Int64.toNat64(-1),
                M.equals(Nat64Testable(maximumNat64))
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
                "positive",
                Int64.toText(123456),
                M.equals(T.text("123456"))
            ),
            test(
                "negative",
                Int64.toText(-123456),
                M.equals(T.text("-123456"))
            ),
            test(
                "zero",
                Int64.toText(0),
                M.equals(T.text("0"))
            ),
            test(
                "maximum number",
                Int64.toText(maximumInt64),
                M.equals(T.text("9223372036854775807"))
            ),
            test(
                "minimum number",
                Int64.toText(minimumInt64),
                M.equals(T.text("-9223372036854775808"))
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
                Int64.abs(123),
                M.equals(Int64Testable(123))
            ),
            test(
                "negative number",
                Int64.abs(-123),
                M.equals(Int64Testable(123))
            ),
            test(
                "zero",
                Int64.abs(0),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum number",
                Int64.abs(maximumInt64),
                M.equals(Int64Testable(maximumInt64))
            ),
            test(
                "smallest possible",
                Int64.abs(-maximumInt64),
                M.equals(Int64Testable(maximumInt64))
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
                Int64.min(2, 3),
                M.equals(Int64Testable(2))
            ),
            test(
                "positive, negative",
                Int64.min(2, -3),
                M.equals(Int64Testable(-3))
            ),
            test(
                "both negative",
                Int64.min(-2, -3),
                M.equals(Int64Testable(-3))
            ),
            test(
                "negative, positive",
                Int64.min(-2, 3),
                M.equals(Int64Testable(-2))
            ),
            test(
                "equal values",
                Int64.min(123, 123),
                M.equals(Int64Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int64.min(maximumInt64, minimumInt64),
                M.equals(Int64Testable(minimumInt64))
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
                Int64.max(2, 3),
                M.equals(Int64Testable(3))
            ),
            test(
                "positive, negative",
                Int64.max(2, -3),
                M.equals(Int64Testable(2))
            ),
            test(
                "both negative",
                Int64.max(-2, -3),
                M.equals(Int64Testable(-2))
            ),
            test(
                "negative, positive",
                Int64.max(-2, 3),
                M.equals(Int64Testable(3))
            ),
            test(
                "equal values",
                Int64.max(123, 123),
                M.equals(Int64Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int64.max(maximumInt64, minimumInt64),
                M.equals(Int64Testable(maximumInt64))
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
                Int64.equal(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int64.equal(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int64.equal(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "positive not equal",
                Int64.equal(123, 124),
                M.equals(T.bool(false))
            ),
            test(
                "negative not equal",
                Int64.equal(-123, -124),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs",
                Int64.equal(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "maxmimum equal",
                Int64.equal(maximumInt64, maximumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "minimum equal",
                Int64.equal(minimumInt64, minimumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int64.equal(minimumInt64, maximumInt64),
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
                Int64.notEqual(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int64.notEqual(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int64.notEqual(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "positive not equal",
                Int64.notEqual(123, 124),
                M.equals(T.bool(true))
            ),
            test(
                "negative not equal",
                Int64.notEqual(-123, -124),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs",
                Int64.notEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "maxmimum equal",
                Int64.notEqual(maximumInt64, maximumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "minimum equal",
                Int64.notEqual(minimumInt64, minimumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int64.notEqual(minimumInt64, maximumInt64),
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
                Int64.less(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int64.less(123, 245),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int64.less(245, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int64.less(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int64.less(-245, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int64.less(-123, -245),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int64.less(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int64.less(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int64.less(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int64.less(minimumInt64, maximumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int64.less(maximumInt64, minimumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int64.less(maximumInt64, maximumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int64.less(minimumInt64, minimumInt64),
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
                Int64.lessOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int64.lessOrEqual(123, 245),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int64.lessOrEqual(245, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int64.lessOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int64.lessOrEqual(-245, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int64.lessOrEqual(-123, -245),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int64.lessOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int64.lessOrEqual(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int64.lessOrEqual(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int64.lessOrEqual(minimumInt64, maximumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int64.lessOrEqual(maximumInt64, minimumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int64.lessOrEqual(maximumInt64, maximumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int64.lessOrEqual(minimumInt64, minimumInt64),
                M.equals(T.bool(true))
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
                Int64.greater(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int64.greater(123, 245),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int64.greater(245, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int64.greater(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int64.greater(-245, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int64.greater(-123, -245),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int64.greater(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int64.greater(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int64.greater(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int64.greater(minimumInt64, maximumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int64.greater(maximumInt64, minimumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int64.greater(maximumInt64, maximumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int64.greater(minimumInt64, minimumInt64),
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
                Int64.greaterOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int64.greaterOrEqual(123, 245),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int64.greaterOrEqual(245, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int64.greaterOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int64.greaterOrEqual(-245, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int64.greaterOrEqual(-123, -245),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int64.greaterOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int64.greaterOrEqual(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int64.greaterOrEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int64.greaterOrEqual(minimumInt64, maximumInt64),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int64.greaterOrEqual(maximumInt64, minimumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int64.greaterOrEqual(maximumInt64, maximumInt64),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int64.greaterOrEqual(minimumInt64, minimumInt64),
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
                Int64.compare(123, 123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "positive less",
                Int64.compare(123, 245),
                M.equals(OrderTestable(#less))
            ),
            test(
                "positive greater",
                Int64.compare(245, 123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "negative equal",
                Int64.compare(-123, -123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "negative less",
                Int64.compare(-245, -123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "negative greater",
                Int64.compare(-123, -245),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "zero",
                Int64.compare(0, 0),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "mixed signs less",
                Int64.compare(-123, 123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "mixed signs greater",
                Int64.compare(123, -123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "minimum and maximum",
                Int64.compare(minimumInt64, maximumInt64),
                M.equals(OrderTestable(#less))
            ),
            test(
                "maximum and minimum",
                Int64.compare(maximumInt64, minimumInt64),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "maximum and maximum",
                Int64.compare(maximumInt64, maximumInt64),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "minimum and minimum",
                Int64.compare(minimumInt64, minimumInt64),
                M.equals(OrderTestable(#equal))
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
                Int64.neg(123),
                M.equals(Int64Testable(-123))
            ),
            test(
                "negative number",
                Int64.neg(-123),
                M.equals(Int64Testable(123))
            ),
            test(
                "zero",
                Int64.neg(0),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum number",
                Int64.neg(maximumInt64),
                M.equals(Int64Testable(-maximumInt64))
            ),
            test(
                "smallest possible",
                Int64.neg(-maximumInt64),
                M.equals(Int64Testable(maximumInt64))
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
                Int64.add(123, 123),
                M.equals(Int64Testable(246))
            ),
            test(
                "negative",
                Int64.add(-123, -123),
                M.equals(Int64Testable(-246))
            ),
            test(
                "mixed signs",
                Int64.add(-123, 223),
                M.equals(Int64Testable(100))
            ),
            test(
                "zero",
                Int64.add(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and maximum",
                Int64.add(minimumInt64, maximumInt64),
                M.equals(Int64Testable(-1))
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
                Int64.sub(123, 123),
                M.equals(Int64Testable(0))
            ),
            test(
                "negative",
                Int64.sub(-123, -123),
                M.equals(Int64Testable(0))
            ),
            test(
                "mixed signs",
                Int64.sub(-123, 223),
                M.equals(Int64Testable(-346))
            ),
            test(
                "zero",
                Int64.sub(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum and maximum",
                Int64.sub(maximumInt64, maximumInt64),
                M.equals(Int64Testable(0))
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
                Int64.mul(123, 234),
                M.equals(Int64Testable(28782))
            ),
            test(
                "negative",
                Int64.mul(-123, -234),
                M.equals(Int64Testable(28782))
            ),
            test(
                "mixed signs",
                Int64.mul(-123, 234),
                M.equals(Int64Testable(-28782))
            ),
            test(
                "zeros",
                Int64.mul(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and maximum",
                Int64.mul(0, maximumInt64),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and zero",
                Int64.mul(minimumInt64, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "one and maximum",
                Int64.mul(1, maximumInt64),
                M.equals(Int64Testable(maximumInt64))
            ),
            test(
                "minimum and one",
                Int64.mul(minimumInt64, 1),
                M.equals(Int64Testable(minimumInt64))
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
                Int64.div(156, 13),
                M.equals(Int64Testable(12))
            ),
            test(
                "positive remainder",
                Int64.div(1234, 100),
                M.equals(Int64Testable(12))
            ),
            test(
                "negative multiple",
                Int64.div(-156, -13),
                M.equals(Int64Testable(12))
            ),
            test(
                "negative remainder",
                Int64.div(-1234, -100),
                M.equals(Int64Testable(12))
            ),
            test(
                "mixed signs",
                Int64.div(-123, 23),
                M.equals(Int64Testable(-5))
            ),
            test(
                "zero and number",
                Int64.div(0, -123),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and maximum",
                Int64.div(0, maximumInt64),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and minimum",
                Int64.div(0, minimumInt64),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum and maximum",
                Int64.div(maximumInt64, maximumInt64),
                M.equals(Int64Testable(1))
            ),
            test(
                "minimum and minimum",
                Int64.div(minimumInt64, minimumInt64),
                M.equals(Int64Testable(1))
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
                Int64.rem(156, 13),
                M.equals(Int64Testable(0))
            ),
            test(
                "positive/positive remainder",
                Int64.rem(1234, 100),
                M.equals(Int64Testable(34))
            ),
            test(
                "positive/negative remainder",
                Int64.rem(1234, -100),
                M.equals(Int64Testable(34))
            ),
            test(
                "negative multiple",
                Int64.rem(-156, -13),
                M.equals(Int64Testable(0))
            ),
            test(
                "negative/positive remainder",
                Int64.rem(-1234, 100),
                M.equals(Int64Testable(-34))
            ),
            test(
                "negative/negative remainder",
                Int64.rem(-1234, -100),
                M.equals(Int64Testable(-34))
            ),
            test(
                "zero and maximum",
                Int64.rem(0, maximumInt64),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and minimum",
                Int64.rem(0, minimumInt64),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum and maximum",
                Int64.rem(maximumInt64, maximumInt64),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and minimum",
                Int64.rem(minimumInt64, minimumInt64),
                M.equals(Int64Testable(0))
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
                Int64.pow(72, 3),
                M.equals(Int64Testable(373248))
            ),
            test(
                "positive base, zero exponent",
                Int64.pow(72, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "negative base, positive exponent",
                Int64.pow(-72, 3),
                M.equals(Int64Testable(-373248))
            ),
            test(
                "negative base, zero exponent",
                Int64.pow(-72, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "maximum and zero",
                Int64.pow(maximumInt64, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "minimum and zero",
                Int64.pow(minimumInt64, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "plus one and maximum",
                Int64.pow(1, maximumInt64),
                M.equals(Int64Testable(1))
            ),
            test(
                "minus one and maximum",
                Int64.pow(-1, maximumInt64),
                M.equals(Int64Testable(-1))
            ),
        ]
    )
)
