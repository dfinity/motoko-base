// @testmode wasi

import Int64 "../src/Int64";
import Order "../src/Order";
import Iter "../src/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let maximumInt64asInt = +2 ** 63 - 1 : Int;
let maximumInt64asNat64 = 2 ** 63 - 1 : Nat64;

let minimumInt64asInt = -2 ** 63 : Int;

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
        "constants",
        [
            test(
                "minimum value",
                Int64.minimumValue,
                M.equals(Int64Testable(Int64.fromInt(-2 ** 63)))
            ),
            test(
                "maximum value",
                Int64.maximumValue,
                M.equals(Int64Testable(Int64.fromInt(+2 ** 63 - 1)))
            ),
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "toInt",
        [
            test(
                "maximum number",
                Int64.toInt(Int64.maximumValue),
                M.equals(T.int(maximumInt64asInt))
            ),
            test(
                "minimum number",
                Int64.toInt(Int64.minimumValue),
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
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum number",
                Int64.fromInt(minimumInt64asInt),
                M.equals(Int64Testable(Int64.minimumValue))
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
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum number",
                Int64.fromIntWrap(minimumInt64asInt),
                M.equals(Int64Testable(Int64.minimumValue))
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
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "underflow",
                Int64.fromIntWrap(minimumInt64asInt - 1),
                M.equals(Int64Testable(Int64.maximumValue))
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
                M.equals(Int64Testable(Int64.maximumValue))
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
                M.equals(Int64Testable(Int64.minimumValue))
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
                Int64.toNat64(Int64.maximumValue),
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
                Int64.toText(Int64.maximumValue),
                M.equals(T.text("9223372036854775807"))
            ),
            test(
                "minimum number",
                Int64.toText(Int64.minimumValue),
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
                Int64.abs(Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "smallest possible",
                Int64.abs(-Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
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
                Int64.min(Int64.maximumValue, Int64.minimumValue),
                M.equals(Int64Testable(Int64.minimumValue))
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
                Int64.max(Int64.maximumValue, Int64.minimumValue),
                M.equals(Int64Testable(Int64.maximumValue))
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
                Int64.equal(Int64.maximumValue, Int64.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum equal",
                Int64.equal(Int64.minimumValue, Int64.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int64.equal(Int64.minimumValue, Int64.maximumValue),
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
                Int64.notEqual(Int64.maximumValue, Int64.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum equal",
                Int64.notEqual(Int64.minimumValue, Int64.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int64.notEqual(Int64.minimumValue, Int64.maximumValue),
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
                Int64.less(Int64.minimumValue, Int64.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int64.less(Int64.maximumValue, Int64.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int64.less(Int64.maximumValue, Int64.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int64.less(Int64.minimumValue, Int64.minimumValue),
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
                Int64.lessOrEqual(Int64.minimumValue, Int64.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int64.lessOrEqual(Int64.maximumValue, Int64.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int64.lessOrEqual(Int64.maximumValue, Int64.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int64.lessOrEqual(Int64.minimumValue, Int64.minimumValue),
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
                Int64.greater(Int64.minimumValue, Int64.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int64.greater(Int64.maximumValue, Int64.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int64.greater(Int64.maximumValue, Int64.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int64.greater(Int64.minimumValue, Int64.minimumValue),
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
                Int64.greaterOrEqual(Int64.minimumValue, Int64.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int64.greaterOrEqual(Int64.maximumValue, Int64.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int64.greaterOrEqual(Int64.maximumValue, Int64.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int64.greaterOrEqual(Int64.minimumValue, Int64.minimumValue),
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
                Int64.compare(Int64.minimumValue, Int64.maximumValue),
                M.equals(OrderTestable(#less))
            ),
            test(
                "maximum and minimum",
                Int64.compare(Int64.maximumValue, Int64.minimumValue),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "maximum and maximum",
                Int64.compare(Int64.maximumValue, Int64.maximumValue),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "minimum and minimum",
                Int64.compare(Int64.minimumValue, Int64.minimumValue),
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
                Int64.neg(Int64.maximumValue),
                M.equals(Int64Testable(-Int64.maximumValue))
            ),
            test(
                "smallest possible",
                Int64.neg(-Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
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
                Int64.add(Int64.minimumValue, Int64.maximumValue),
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
                Int64.sub(Int64.maximumValue, Int64.maximumValue),
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
                Int64.mul(0, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and zero",
                Int64.mul(Int64.minimumValue, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "one and maximum",
                Int64.mul(1, Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum and one",
                Int64.mul(Int64.minimumValue, 1),
                M.equals(Int64Testable(Int64.minimumValue))
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
                Int64.div(0, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and minimum",
                Int64.div(0, Int64.minimumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum and maximum",
                Int64.div(Int64.maximumValue, Int64.maximumValue),
                M.equals(Int64Testable(1))
            ),
            test(
                "minimum and minimum",
                Int64.div(Int64.minimumValue, Int64.minimumValue),
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
                Int64.rem(0, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and minimum",
                Int64.rem(0, Int64.minimumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum and maximum",
                Int64.rem(Int64.maximumValue, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and minimum",
                Int64.rem(Int64.minimumValue, Int64.minimumValue),
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
                "negative base, odd exponent",
                Int64.pow(-72, 3),
                M.equals(Int64Testable(-373248))
            ),
            test(
                "negative base, even exponent",
                Int64.pow(-72, 4),
                M.equals(Int64Testable(26_873_856))
            ),
            test(
                "negative base, zero exponent",
                Int64.pow(-72, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "maximum and zero",
                Int64.pow(Int64.maximumValue, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "minimum and zero",
                Int64.pow(Int64.minimumValue, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "plus one and maximum",
                Int64.pow(1, Int64.maximumValue),
                M.equals(Int64Testable(1))
            ),
            test(
                "minus one and maximum",
                Int64.pow(-1, Int64.maximumValue),
                M.equals(Int64Testable(-1))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitnot",
        [
            test(
                "zero",
                Int64.bitnot(0),
                M.equals(Int64Testable(-1))
            ),
            test(
                "minus 1",
                Int64.bitnot(-1),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum",
                Int64.bitnot(Int64.maximumValue),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "minimum",
                Int64.bitnot(Int64.minimumValue),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "arbitrary",
                Int64.bitnot(1234),
                M.equals(Int64Testable(-1235))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitand",
        [
            test(
                "inverted",
                Int64.bitand(0xf0f0, 0x0f0f),
                M.equals(Int64Testable(0))
            ),
            test(
                "overlap",
                Int64.bitand(0x0ff0, 0xffff),
                M.equals(Int64Testable(0xff0))
            ),
            test(
                "arbitrary",
                Int64.bitand(0x1234_5678_90ab_cdef, 0x7654_3210_fedc_ba98),
                M.equals(Int64Testable(0x1214_1210_9088_8888))
            ),
            test(
                "negative",
                Int64.bitand(-123, -123),
                M.equals(Int64Testable(-123))
            ),
            test(
                "mixed signs",
                Int64.bitand(-256, 255),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero",
                Int64.bitand(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and maximum",
                Int64.bitand(0, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and zero",
                Int64.bitand(Int64.minimumValue, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and maximum",
                Int64.bitand(Int64.minimumValue, Int64.maximumValue),
                M.equals(Int64Testable(0))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitor",
        [
            test(
                "inverted",
                Int64.bitor(0xf0f0, 0x0f0f),
                M.equals(Int64Testable(0xffff))
            ),
            test(
                "overlap",
                Int64.bitor(0x0ff0, 0xffff),
                M.equals(Int64Testable(0xffff))
            ),
            test(
                "arbitrary",
                Int64.bitor(0x1234_5678_90ab_cdef, 0x7654_3210_fedc_ba98),
                M.equals(Int64Testable(0x7674_7678_feff_ffff))
            ),
            test(
                "negative",
                Int64.bitor(-123, -123),
                M.equals(Int64Testable(-123))
            ),
            test(
                "mixed signs",
                Int64.bitor(-256, 255),
                M.equals(Int64Testable(-1))
            ),
            test(
                "zero",
                Int64.bitor(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and maximum",
                Int64.bitor(0, Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum and zero",
                Int64.bitor(Int64.minimumValue, 0),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "minimum and maximum",
                Int64.bitor(Int64.minimumValue, Int64.maximumValue),
                M.equals(Int64Testable(-1))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitxor",
        [
            test(
                "inverted",
                Int64.bitxor(0xf0f0, 0x0f0f),
                M.equals(Int64Testable(0xffff))
            ),
            test(
                "overlap",
                Int64.bitxor(0x0ff0, 0xffff),
                M.equals(Int64Testable(0xf00f))
            ),
            test(
                "arbitrary",
                Int64.bitxor(0x1234_5678_90ab_cdef, 0x7654_3210_fedc_ba98),
                M.equals(Int64Testable(0x6460_6468_6e77_7777))
            ),
            test(
                "negative",
                Int64.bitxor(-123, -123),
                M.equals(Int64Testable(0))
            ),
            test(
                "mixed signs",
                Int64.bitxor(-256, 255),
                M.equals(Int64Testable(-1))
            ),
            test(
                "zero",
                Int64.bitxor(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and maximum",
                Int64.bitxor(0, Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum and zero",
                Int64.bitxor(Int64.minimumValue, 0),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "minimum and maximum",
                Int64.bitxor(Int64.minimumValue, Int64.maximumValue),
                M.equals(Int64Testable(-1))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitshiftLeft",
        [
            test(
                "positive number",
                Int64.bitshiftLeft(0xf0f0, 4),
                M.equals(Int64Testable(0xf_0f00))
            ),
            test(
                "negative number",
                Int64.bitshiftLeft(-256, 4),
                M.equals(Int64Testable(-4096))
            ),
            test(
                "arbitrary",
                Int64.bitshiftLeft(1234_5678, 7),
                M.equals(Int64Testable(1_580_246_784))
            ),
            test(
                "zero shift",
                Int64.bitshiftLeft(1234, 0),
                M.equals(Int64Testable(1234))
            ),
            test(
                "one maximum shift",
                Int64.bitshiftLeft(1, 63),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "minimum number",
                Int64.bitshiftLeft(-1, 63),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "discard overflow",
                Int64.bitshiftLeft(0x7fff_ffff_0000_0000, 32),
                M.equals(Int64Testable(0))
            ),
            test(
                "beyond bit length positive",
                Int64.bitshiftLeft(0x1234_5678_90ab_cdef, 128 + 7),
                M.equals(Int64Testable(Int64.bitshiftLeft(0x1234_5678_90ab_cdef, 7)))
            ),
            test(
                "beyond bit length negative",
                Int64.bitshiftLeft(-0x1234_5678_90ab_cdef, 64 + 7),
                M.equals(Int64Testable(Int64.bitshiftLeft(-0x1234_5678_90ab_cdef, 7)))
            ),
            test(
                "negative shift argument",
                Int64.bitshiftLeft(0x1234_5678_90ab_cdef, -7),
                M.equals(Int64Testable(Int64.bitshiftLeft(0x1234_5678_90ab_cdef, 64 - 7)))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitshiftRight",
        [
            test(
                "positive number",
                Int64.bitshiftRight(0xf0f0, 4),
                M.equals(Int64Testable(0x0f0f))
            ),
            test(
                "negative number",
                Int64.bitshiftRight(-256, 4),
                M.equals(Int64Testable(-16))
            ),
            test(
                "arbitrary",
                Int64.bitshiftRight(1234_5678, 7),
                M.equals(Int64Testable(96_450))
            ),
            test(
                "zero shift",
                Int64.bitshiftRight(1234, 0),
                M.equals(Int64Testable(1234))
            ),
            test(
                "minus one maximum shift",
                Int64.bitshiftRight(-1, 63),
                M.equals(Int64Testable(-1))
            ),
            test(
                "minimum number",
                Int64.bitshiftRight(Int64.minimumValue, 63),
                M.equals(Int64Testable(-1))
            ),
            test(
                "discard underflow",
                Int64.bitshiftRight(0x0000_0000_ffff_ffff, 32),
                M.equals(Int64Testable(0))
            ),
            test(
                "beyond bit length positive",
                Int64.bitshiftRight(0x1234_5678_90ab_cdef, 128 + 7),
                M.equals(Int64Testable(Int64.bitshiftRight(0x1234_5678_90ab_cdef, 7)))
            ),
            test(
                "beyond bit length negative",
                Int64.bitshiftRight(-0x1234_5678_90ab_cdef, 64 + 7),
                M.equals(Int64Testable(Int64.bitshiftRight(-0x1234_5678_90ab_cdef, 7)))
            ),
            test(
                "negative shift argument",
                Int64.bitshiftRight(0x1234_5678_90ab_cdef, -7),
                M.equals(Int64Testable(Int64.bitshiftRight(0x1234_5678_90ab_cdef, 64 - 7)))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitrotLeft",
        [
            test(
                "positive number non-overflow",
                Int64.bitrotLeft(0xf0f0, 4),
                M.equals(Int64Testable(0xf_0f00))
            ),
            test(
                "positive number overflow",
                Int64.bitrotLeft(0x5600_0000_0000_1234, 8),
                M.equals(Int64Testable(0x12_3456))
            ),
            test(
                "negative number",
                Int64.bitrotLeft(-256, 4),
                M.equals(Int64Testable(-4081))
            ),
            test(
                "arbitrary",
                Int64.bitrotLeft(123_4567_8901_2345_6789, 7),
                M.equals(Int64Testable(-799_6006_7275_8349_5544))
            ),
            test(
                "zero shift",
                Int64.bitrotLeft(1234, 0),
                M.equals(Int64Testable(1234))
            ),
            test(
                "minus one maximum rotate",
                Int64.bitrotLeft(-1, 63),
                M.equals(Int64Testable(-1))
            ),
            test(
                "maximum number",
                Int64.bitrotLeft(Int64.maximumValue, 1),
                M.equals(Int64Testable(-2))
            ),
            test(
                "minimum number",
                Int64.bitrotLeft(1, 63),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "opposite rotation",
                Int64.bitrotLeft(256, -2),
                M.equals(Int64Testable(64))
            ),
            test(
                "rotate beyond bit length",
                Int64.bitrotLeft(128, 66),
                M.equals(Int64Testable(512))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitrotRight",
        [
            test(
                "positive number non-underflow",
                Int64.bitrotRight(0xf0f0, 4),
                M.equals(Int64Testable(0x0f0f))
            ),
            test(
                "positive number underflow",
                Int64.bitrotRight(0x5600_0000_0000_1234, 8),
                M.equals(Int64Testable(0x3456_0000_0000_0012))
            ),
            test(
                "negative number",
                Int64.bitrotRight(-256, 8),
                M.equals(Int64Testable(0x00ff_ffff_ffff_ffff))
            ),
            test(
                "arbitrary",
                Int64.bitrotRight(123_4567_8901_2345_6789, 7),
                M.equals(Int64Testable(303_6064_0112_3456_2818))
            ),
            test(
                "zero shift",
                Int64.bitrotRight(1234, 0),
                M.equals(Int64Testable(1234))
            ),
            test(
                "minus one maximum rotate",
                Int64.bitrotRight(-1, 63),
                M.equals(Int64Testable(-1))
            ),
            test(
                "maximum number",
                Int64.bitrotRight(-2, 1),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum number",
                Int64.bitrotRight(Int64.minimumValue, 63),
                M.equals(Int64Testable(1))
            ),
            test(
                "opposite rotation",
                Int64.bitrotRight(256, -2),
                M.equals(Int64Testable(1024))
            ),
            test(
                "rotate beyond bit length",
                Int64.bitrotRight(128, 66),
                M.equals(Int64Testable(32))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bittest",
        [
            test(
                "set bit",
                Int64.bittest(128, 7),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit",
                Int64.bittest(-129, 7),
                M.equals(T.bool(false))
            ),
            test(
                "all zero",
                do {
                    let number = 0 : Int64;
                    var count = 0;
                    for (index in Iter.range(0, 63)) {
                        if (Int64.bittest(number, index)) {
                            count += 1
                        }
                    };
                    count
                },
                M.equals(T.int(0))
            ),
            test(
                "all one",
                do {
                    let number = -1 : Int64;
                    var count = 0;
                    for (index in Iter.range(0, 63)) {
                        if (Int64.bittest(number, index)) {
                            count += 1
                        }
                    };
                    count
                },
                M.equals(T.int(64))
            ),
            test(
                "set bit beyond bit length",
                Int64.bittest(128, 64 + 7),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit beyond bit length",
                Int64.bittest(-129, 128 + 7),
                M.equals(T.bool(false))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitset",
        [
            test(
                "set bit",
                Int64.bitset(0, 7),
                M.equals(Int64Testable(128))
            ),
            test(
                "minus one",
                Int64.bitset(-129, 7),
                M.equals(Int64Testable(-1))
            ),
            test(
                "no effect",
                Int64.bitset(128, 7),
                M.equals(Int64Testable(128))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int64;
                    for (index in Iter.range(0, 63)) {
                        number := Int64.bitset(number, index)
                    };
                    number
                },
                M.equals(Int64Testable(-1))
            ),
            test(
                "all no effect",
                do {
                    var number = -1 : Int64;
                    for (index in Iter.range(0, 63)) {
                        number := Int64.bitset(number, index)
                    };
                    number
                },
                M.equals(Int64Testable(-1))
            ),
            test(
                "set bit beyond bit length",
                Int64.bitset(0, 64 + 7),
                M.equals(Int64Testable(128))
            ),
            test(
                "minus one beyond bit length",
                Int64.bitset(-129, 128 + 7),
                M.equals(Int64Testable(-1))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitclear",
        [
            test(
                "clear bit",
                Int64.bitclear(128, 7),
                M.equals(Int64Testable(0))
            ),
            test(
                "minus one",
                Int64.bitclear(-1, 7),
                M.equals(Int64Testable(-129))
            ),
            test(
                "no effect",
                Int64.bitclear(0, 7),
                M.equals(Int64Testable(0))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int64;
                    for (index in Iter.range(0, 63)) {
                        number := Int64.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int64Testable(0))
            ),
            test(
                "all no effect",
                do {
                    var number = 0 : Int64;
                    for (index in Iter.range(0, 63)) {
                        number := Int64.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int64Testable(0))
            ),
            test(
                "clear bit beyond bit length",
                Int64.bitclear(128, 64 + 7),
                M.equals(Int64Testable(0))
            ),
            test(
                "minus one beyond bit length",
                Int64.bitclear(-1, 128 + 7),
                M.equals(Int64Testable(-129))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitflip",
        [
            test(
                "clear bit",
                Int64.bitflip(255, 7),
                M.equals(Int64Testable(127))
            ),
            test(
                "set bit",
                Int64.bitflip(127, 7),
                M.equals(Int64Testable(255))
            ),
            test(
                "double flip",
                Int64.bitflip(Int64.bitflip(0x1234_5678_90ab_cdef, 13), 13),
                M.equals(Int64Testable(0x1234_5678_90ab_cdef))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int64;
                    for (index in Iter.range(0, 63)) {
                        number := Int64.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int64Testable(0))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int64;
                    for (index in Iter.range(0, 63)) {
                        number := Int64.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int64Testable(-1))
            ),
            test(
                "clear bit beyond bit length",
                Int64.bitflip(255, 64 + 7),
                M.equals(Int64Testable(127))
            ),
            test(
                "set bit beyond bit length",
                Int64.bitflip(127, 128 + 7),
                M.equals(Int64Testable(255))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitcountNonZero",
        [
            test(
                "zero",
                Int64.bitcountNonZero(0),
                M.equals(Int64Testable(0))
            ),
            test(
                "minus one",
                Int64.bitcountNonZero(-1),
                M.equals(Int64Testable(64))
            ),
            test(
                "minus two",
                Int64.bitcountNonZero(-2),
                M.equals(Int64Testable(63))
            ),
            test(
                "one",
                Int64.bitcountNonZero(1),
                M.equals(Int64Testable(1))
            ),
            test(
                "minimum value",
                Int64.bitcountNonZero(Int64.minimumValue),
                M.equals(Int64Testable(1))
            ),
            test(
                "maximum value",
                Int64.bitcountNonZero(Int64.maximumValue),
                M.equals(Int64Testable(63))
            ),
            test(
                "alternating bits positive",
                Int64.bitcountNonZero(0x5555_5555_5555_5555),
                M.equals(Int64Testable(32))
            ),
            test(
                "alternating bits negative",
                Int64.bitcountNonZero(-0x5555_5555_5555_5556),
                M.equals(Int64Testable(32))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitcountLeadingZero",
        [
            test(
                "zero",
                Int64.bitcountLeadingZero(0),
                M.equals(Int64Testable(64))
            ),
            test(
                "minus one",
                Int64.bitcountLeadingZero(-1),
                M.equals(Int64Testable(0))
            ),
            test(
                "minus two",
                Int64.bitcountLeadingZero(-2),
                M.equals(Int64Testable(0))
            ),
            test(
                "one",
                Int64.bitcountLeadingZero(1),
                M.equals(Int64Testable(63))
            ),
            test(
                "two",
                Int64.bitcountLeadingZero(2),
                M.equals(Int64Testable(62))
            ),
            test(
                "arbitrary",
                Int64.bitcountLeadingZero(0x0000_1020_3040_5060),
                M.equals(Int64Testable(19))
            ),
            test(
                "minimum value",
                Int64.bitcountLeadingZero(Int64.minimumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum value",
                Int64.bitcountLeadingZero(Int64.maximumValue),
                M.equals(Int64Testable(1))
            ),
            test(
                "alternating bits positive",
                Int64.bitcountLeadingZero(0x5555_5555_5555_5555),
                M.equals(Int64Testable(1))
            ),
            test(
                "alternating bits negative",
                Int64.bitcountLeadingZero(-0x5555_5555_5555_5556),
                M.equals(Int64Testable(0))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "bitcountTrailingZero",
        [
            test(
                "zero",
                Int64.bitcountTrailingZero(0),
                M.equals(Int64Testable(64))
            ),
            test(
                "minus one",
                Int64.bitcountTrailingZero(-1),
                M.equals(Int64Testable(0))
            ),
            test(
                "minus two",
                Int64.bitcountTrailingZero(-2),
                M.equals(Int64Testable(1))
            ),
            test(
                "one",
                Int64.bitcountTrailingZero(1),
                M.equals(Int64Testable(0))
            ),
            test(
                "two",
                Int64.bitcountTrailingZero(2),
                M.equals(Int64Testable(1))
            ),
            test(
                "arbitrary",
                Int64.bitcountTrailingZero(0x1020_3040_5060_0000),
                M.equals(Int64Testable(21))
            ),
            test(
                "minimum value",
                Int64.bitcountTrailingZero(Int64.minimumValue),
                M.equals(Int64Testable(63))
            ),
            test(
                "maximum value",
                Int64.bitcountTrailingZero(Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "alternating bits positive",
                Int64.bitcountTrailingZero(0x5555_5555_5555_5555),
                M.equals(Int64Testable(0))
            ),
            test(
                "alternating bits negative",
                Int64.bitcountTrailingZero(-0x5555_5555_5555_5556),
                M.equals(Int64Testable(1))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "addWrap",
        [
            test(
                "positive",
                Int64.addWrap(123, 123),
                M.equals(Int64Testable(246))
            ),
            test(
                "negative",
                Int64.addWrap(-123, -123),
                M.equals(Int64Testable(-246))
            ),
            test(
                "mixed signs",
                Int64.addWrap(-123, 223),
                M.equals(Int64Testable(100))
            ),
            test(
                "zero",
                Int64.addWrap(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and maximum",
                Int64.addWrap(Int64.minimumValue, Int64.maximumValue),
                M.equals(Int64Testable(-1))
            ),
            test(
                "small overflow",
                Int64.addWrap(Int64.maximumValue, 1),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "large overflow",
                Int64.addWrap(Int64.maximumValue, Int64.maximumValue),
                M.equals(Int64Testable(-2))
            ),
            test(
                "small underflow",
                Int64.addWrap(Int64.minimumValue, -1),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "large underflow",
                Int64.addWrap(Int64.minimumValue, Int64.minimumValue),
                M.equals(Int64Testable(0))
            ),
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "subWrap",
        [
            test(
                "positive",
                Int64.subWrap(123, 123),
                M.equals(Int64Testable(0))
            ),
            test(
                "negative",
                Int64.subWrap(-123, -123),
                M.equals(Int64Testable(0))
            ),
            test(
                "mixed signs",
                Int64.subWrap(-123, 223),
                M.equals(Int64Testable(-346))
            ),
            test(
                "zero",
                Int64.subWrap(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "maximum and maximum",
                Int64.subWrap(Int64.maximumValue, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "small overflow",
                Int64.subWrap(Int64.maximumValue, -1),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "large overflow",
                Int64.subWrap(Int64.maximumValue, Int64.minimumValue),
                M.equals(Int64Testable(-1))
            ),
            test(
                "small underflow",
                Int64.subWrap(Int64.minimumValue, 1),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "large underflow",
                Int64.subWrap(Int64.minimumValue, Int64.maximumValue),
                M.equals(Int64Testable(1))
            ),
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "mulWrap",
        [
            test(
                "positive",
                Int64.mulWrap(123, 234),
                M.equals(Int64Testable(28782))
            ),
            test(
                "negative",
                Int64.mulWrap(-123, -234),
                M.equals(Int64Testable(28782))
            ),
            test(
                "mixed signs",
                Int64.mulWrap(-123, 234),
                M.equals(Int64Testable(-28782))
            ),
            test(
                "zeros",
                Int64.mulWrap(0, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "zero and maximum",
                Int64.mulWrap(0, Int64.maximumValue),
                M.equals(Int64Testable(0))
            ),
            test(
                "minimum and zero",
                Int64.mulWrap(Int64.minimumValue, 0),
                M.equals(Int64Testable(0))
            ),
            test(
                "one and maximum",
                Int64.mulWrap(1, Int64.maximumValue),
                M.equals(Int64Testable(Int64.maximumValue))
            ),
            test(
                "minimum and one",
                Int64.mulWrap(Int64.minimumValue, 1),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "small overflow",
                Int64.mulWrap(2, Int64.maximumValue),
                M.equals(Int64Testable(-2))
            ),
            test(
                "large overflow",
                Int64.mulWrap(Int64.maximumValue, Int64.maximumValue),
                M.equals(Int64Testable(1))
            ),
            test(
                "small underflow",
                Int64.mulWrap(Int64.minimumValue, 2),
                M.equals(Int64Testable(0))
            ),
            test(
                "large underflow",
                Int64.mulWrap(Int64.minimumValue, Int64.minimumValue),
                M.equals(Int64Testable(0))
            ),
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "powWrap",
        [
            test(
                "positive base, positive exponent",
                Int64.powWrap(72, 3),
                M.equals(Int64Testable(373248))
            ),
            test(
                "positive base, zero exponent",
                Int64.powWrap(72, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "negative base, positive exponent",
                Int64.powWrap(-72, 3),
                M.equals(Int64Testable(-373248))
            ),
            test(
                "negative base, zero exponent",
                Int64.powWrap(-72, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "maximum and zero",
                Int64.powWrap(Int64.maximumValue, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "minimum and zero",
                Int64.powWrap(Int64.minimumValue, 0),
                M.equals(Int64Testable(1))
            ),
            test(
                "plus one and maximum",
                Int64.powWrap(1, Int64.maximumValue),
                M.equals(Int64Testable(1))
            ),
            test(
                "minus one and maximum",
                Int64.powWrap(-1, Int64.maximumValue),
                M.equals(Int64Testable(-1))
            ),
            test(
                "minimum value",
                Int64.powWrap(-2, 63),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "small overflow",
                Int64.powWrap(2, 63),
                M.equals(Int64Testable(Int64.minimumValue))
            ),
            test(
                "large overflow",
                Int64.powWrap(Int64.maximumValue, 10),
                M.equals(Int64Testable(1))
            ),
            test(
                "small underflow",
                Int64.powWrap(-2, 65),
                M.equals(Int64Testable(0))
            ),
            test(
                "large underflow",
                Int64.powWrap(Int64.minimumValue, 10),
                M.equals(Int64Testable(0))
            ),
        ]
    )
)
