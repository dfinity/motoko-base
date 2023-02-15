// @testmode wasmer

import Int32 "mo:base/Int32";
import Order "mo:base/Order";
import Iter "mo:base/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let maximumInt32asInt = +2 ** 31 - 1 : Int;
let maximumInt32asNat32 = 2 ** 31 - 1 : Nat32;

let minimumInt32asInt = -2 ** 31 : Int;

let maximumNat32 = 4_294_967_295 : Nat32;

class Int32Testable(number : Int32) : T.TestableItem<Int32> {
    public let item = number;
    public func display(number : Int32) : Text {
        debug_show (number)
    };
    public let equals = func(x : Int32, y : Int32) : Bool {
        x == y
    }
};

class Nat32Testable(number : Nat32) : T.TestableItem<Nat32> {
    public let item = number;
    public func display(number : Nat32) : Text {
        debug_show (number)
    };
    public let equals = func(x : Nat32, y : Nat32) : Bool {
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
                Int32.minimumValue,
                M.equals(Int32Testable(Int32.fromInt(-2 ** 31)))
            ),
            test(
                "maximum value",
                Int32.maximumValue,
                M.equals(Int32Testable(Int32.fromInt(+2 ** 31 - 1)))
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
                Int32.toInt(Int32.maximumValue),
                M.equals(T.int(maximumInt32asInt))
            ),
            test(
                "minimum number",
                Int32.toInt(Int32.minimumValue),
                M.equals(T.int(minimumInt32asInt))
            ),
            test(
                "one",
                Int32.toInt(1),
                M.equals(T.int(1))
            ),
            test(
                "minus one",
                Int32.toInt(-1),
                M.equals(T.int(-1))
            ),
            test(
                "zero",
                Int32.toInt(0),
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
                Int32.fromInt(maximumInt32asInt),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum number",
                Int32.fromInt(minimumInt32asInt),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "one",
                Int32.fromInt(1),
                M.equals(Int32Testable(1))
            ),
            test(
                "minus one",
                Int32.fromInt(-1),
                M.equals(Int32Testable(-1))
            ),
            test(
                "zero",
                Int32.fromInt(0),
                M.equals(Int32Testable(0))
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
                Int32.fromIntWrap(maximumInt32asInt),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum number",
                Int32.fromIntWrap(minimumInt32asInt),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "one",
                Int32.fromIntWrap(1),
                M.equals(Int32Testable(1))
            ),
            test(
                "minus one",
                Int32.fromIntWrap(-1),
                M.equals(Int32Testable(-1))
            ),
            test(
                "zero",
                Int32.fromIntWrap(0),
                M.equals(Int32Testable(0))
            ),
            test(
                "overflow",
                Int32.fromIntWrap(maximumInt32asInt + 1),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "underflow",
                Int32.fromIntWrap(minimumInt32asInt - 1),
                M.equals(Int32Testable(Int32.maximumValue))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "fromNat32",
        [
            test(
                "maximum number",
                Int32.fromNat32(maximumInt32asNat32),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "one",
                Int32.fromNat32(1),
                M.equals(Int32Testable(1))
            ),
            test(
                "zero",
                Int32.fromNat32(0),
                M.equals(Int32Testable(0))
            ),
            test(
                "overflow",
                Int32.fromNat32(maximumInt32asNat32 + 1),
                M.equals(Int32Testable(Int32.minimumValue))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "toNat32",
        [
            test(
                "maximum number",
                Int32.toNat32(Int32.maximumValue),
                M.equals(Nat32Testable(maximumInt32asNat32))
            ),
            test(
                "one",
                Int32.toNat32(1),
                M.equals(Nat32Testable(1))
            ),
            test(
                "zero",
                Int32.toNat32(0),
                M.equals(Nat32Testable(0))
            ),
            test(
                "underflow",
                Int32.toNat32(-1),
                M.equals(Nat32Testable(maximumNat32))
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
                Int32.toText(123456),
                M.equals(T.text("123456"))
            ),
            test(
                "negative",
                Int32.toText(-123456),
                M.equals(T.text("-123456"))
            ),
            test(
                "zero",
                Int32.toText(0),
                M.equals(T.text("0"))
            ),
            test(
                "maximum number",
                Int32.toText(Int32.maximumValue),
                M.equals(T.text("2147483647"))
            ),
            test(
                "minimum number",
                Int32.toText(Int32.minimumValue),
                M.equals(T.text("-2147483648"))
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
                Int32.abs(123),
                M.equals(Int32Testable(123))
            ),
            test(
                "negative number",
                Int32.abs(-123),
                M.equals(Int32Testable(123))
            ),
            test(
                "zero",
                Int32.abs(0),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum number",
                Int32.abs(Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "smallest possible",
                Int32.abs(-Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
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
                Int32.min(2, 3),
                M.equals(Int32Testable(2))
            ),
            test(
                "positive, negative",
                Int32.min(2, -3),
                M.equals(Int32Testable(-3))
            ),
            test(
                "both negative",
                Int32.min(-2, -3),
                M.equals(Int32Testable(-3))
            ),
            test(
                "negative, positive",
                Int32.min(-2, 3),
                M.equals(Int32Testable(-2))
            ),
            test(
                "equal values",
                Int32.min(123, 123),
                M.equals(Int32Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int32.min(Int32.maximumValue, Int32.minimumValue),
                M.equals(Int32Testable(Int32.minimumValue))
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
                Int32.max(2, 3),
                M.equals(Int32Testable(3))
            ),
            test(
                "positive, negative",
                Int32.max(2, -3),
                M.equals(Int32Testable(2))
            ),
            test(
                "both negative",
                Int32.max(-2, -3),
                M.equals(Int32Testable(-2))
            ),
            test(
                "negative, positive",
                Int32.max(-2, 3),
                M.equals(Int32Testable(3))
            ),
            test(
                "equal values",
                Int32.max(123, 123),
                M.equals(Int32Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int32.max(Int32.maximumValue, Int32.minimumValue),
                M.equals(Int32Testable(Int32.maximumValue))
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
                Int32.equal(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int32.equal(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int32.equal(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "positive not equal",
                Int32.equal(123, 124),
                M.equals(T.bool(false))
            ),
            test(
                "negative not equal",
                Int32.equal(-123, -124),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs",
                Int32.equal(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "maxmimum equal",
                Int32.equal(Int32.maximumValue, Int32.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum equal",
                Int32.equal(Int32.minimumValue, Int32.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int32.equal(Int32.minimumValue, Int32.maximumValue),
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
                Int32.notEqual(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int32.notEqual(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int32.notEqual(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "positive not equal",
                Int32.notEqual(123, 124),
                M.equals(T.bool(true))
            ),
            test(
                "negative not equal",
                Int32.notEqual(-123, -124),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs",
                Int32.notEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "maxmimum equal",
                Int32.notEqual(Int32.maximumValue, Int32.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum equal",
                Int32.notEqual(Int32.minimumValue, Int32.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int32.notEqual(Int32.minimumValue, Int32.maximumValue),
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
                Int32.less(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int32.less(123, 245),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int32.less(245, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int32.less(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int32.less(-245, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int32.less(-123, -245),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int32.less(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int32.less(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int32.less(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int32.less(Int32.minimumValue, Int32.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int32.less(Int32.maximumValue, Int32.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int32.less(Int32.maximumValue, Int32.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int32.less(Int32.minimumValue, Int32.minimumValue),
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
                Int32.lessOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int32.lessOrEqual(123, 245),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int32.lessOrEqual(245, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int32.lessOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int32.lessOrEqual(-245, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int32.lessOrEqual(-123, -245),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int32.lessOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int32.lessOrEqual(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int32.lessOrEqual(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int32.lessOrEqual(Int32.minimumValue, Int32.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int32.lessOrEqual(Int32.maximumValue, Int32.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int32.lessOrEqual(Int32.maximumValue, Int32.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int32.lessOrEqual(Int32.minimumValue, Int32.minimumValue),
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
                Int32.greater(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int32.greater(123, 245),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int32.greater(245, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int32.greater(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int32.greater(-245, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int32.greater(-123, -245),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int32.greater(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int32.greater(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int32.greater(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int32.greater(Int32.minimumValue, Int32.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int32.greater(Int32.maximumValue, Int32.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int32.greater(Int32.maximumValue, Int32.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int32.greater(Int32.minimumValue, Int32.minimumValue),
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
                Int32.greaterOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int32.greaterOrEqual(123, 245),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int32.greaterOrEqual(245, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int32.greaterOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int32.greaterOrEqual(-245, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int32.greaterOrEqual(-123, -245),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int32.greaterOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int32.greaterOrEqual(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int32.greaterOrEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int32.greaterOrEqual(Int32.minimumValue, Int32.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int32.greaterOrEqual(Int32.maximumValue, Int32.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int32.greaterOrEqual(Int32.maximumValue, Int32.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int32.greaterOrEqual(Int32.minimumValue, Int32.minimumValue),
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
                Int32.compare(123, 123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "positive less",
                Int32.compare(123, 245),
                M.equals(OrderTestable(#less))
            ),
            test(
                "positive greater",
                Int32.compare(245, 123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "negative equal",
                Int32.compare(-123, -123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "negative less",
                Int32.compare(-245, -123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "negative greater",
                Int32.compare(-123, -245),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "zero",
                Int32.compare(0, 0),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "mixed signs less",
                Int32.compare(-123, 123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "mixed signs greater",
                Int32.compare(123, -123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "minimum and maximum",
                Int32.compare(Int32.minimumValue, Int32.maximumValue),
                M.equals(OrderTestable(#less))
            ),
            test(
                "maximum and minimum",
                Int32.compare(Int32.maximumValue, Int32.minimumValue),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "maximum and maximum",
                Int32.compare(Int32.maximumValue, Int32.maximumValue),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "minimum and minimum",
                Int32.compare(Int32.minimumValue, Int32.minimumValue),
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
                Int32.neg(123),
                M.equals(Int32Testable(-123))
            ),
            test(
                "negative number",
                Int32.neg(-123),
                M.equals(Int32Testable(123))
            ),
            test(
                "zero",
                Int32.neg(0),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum number",
                Int32.neg(Int32.maximumValue),
                M.equals(Int32Testable(-Int32.maximumValue))
            ),
            test(
                "smallest possible",
                Int32.neg(-Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
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
                Int32.add(123, 123),
                M.equals(Int32Testable(246))
            ),
            test(
                "negative",
                Int32.add(-123, -123),
                M.equals(Int32Testable(-246))
            ),
            test(
                "mixed signs",
                Int32.add(-123, 223),
                M.equals(Int32Testable(100))
            ),
            test(
                "zero",
                Int32.add(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and maximum",
                Int32.add(Int32.minimumValue, Int32.maximumValue),
                M.equals(Int32Testable(-1))
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
                Int32.sub(123, 123),
                M.equals(Int32Testable(0))
            ),
            test(
                "negative",
                Int32.sub(-123, -123),
                M.equals(Int32Testable(0))
            ),
            test(
                "mixed signs",
                Int32.sub(-123, 223),
                M.equals(Int32Testable(-346))
            ),
            test(
                "zero",
                Int32.sub(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum and maximum",
                Int32.sub(Int32.maximumValue, Int32.maximumValue),
                M.equals(Int32Testable(0))
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
                Int32.mul(123, 234),
                M.equals(Int32Testable(28782))
            ),
            test(
                "negative",
                Int32.mul(-123, -234),
                M.equals(Int32Testable(28782))
            ),
            test(
                "mixed signs",
                Int32.mul(-123, 234),
                M.equals(Int32Testable(-28782))
            ),
            test(
                "zeros",
                Int32.mul(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and maximum",
                Int32.mul(0, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and zero",
                Int32.mul(Int32.minimumValue, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "one and maximum",
                Int32.mul(1, Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum and one",
                Int32.mul(Int32.minimumValue, 1),
                M.equals(Int32Testable(Int32.minimumValue))
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
                Int32.div(156, 13),
                M.equals(Int32Testable(12))
            ),
            test(
                "positive remainder",
                Int32.div(1234, 100),
                M.equals(Int32Testable(12))
            ),
            test(
                "negative multiple",
                Int32.div(-156, -13),
                M.equals(Int32Testable(12))
            ),
            test(
                "negative remainder",
                Int32.div(-1234, -100),
                M.equals(Int32Testable(12))
            ),
            test(
                "mixed signs",
                Int32.div(-123, 23),
                M.equals(Int32Testable(-5))
            ),
            test(
                "zero and number",
                Int32.div(0, -123),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and maximum",
                Int32.div(0, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and minimum",
                Int32.div(0, Int32.minimumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum and maximum",
                Int32.div(Int32.maximumValue, Int32.maximumValue),
                M.equals(Int32Testable(1))
            ),
            test(
                "minimum and minimum",
                Int32.div(Int32.minimumValue, Int32.minimumValue),
                M.equals(Int32Testable(1))
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
                Int32.rem(156, 13),
                M.equals(Int32Testable(0))
            ),
            test(
                "positive/positive remainder",
                Int32.rem(1234, 100),
                M.equals(Int32Testable(34))
            ),
            test(
                "positive/negative remainder",
                Int32.rem(1234, -100),
                M.equals(Int32Testable(34))
            ),
            test(
                "negative multiple",
                Int32.rem(-156, -13),
                M.equals(Int32Testable(0))
            ),
            test(
                "negative/positive remainder",
                Int32.rem(-1234, 100),
                M.equals(Int32Testable(-34))
            ),
            test(
                "negative/negative remainder",
                Int32.rem(-1234, -100),
                M.equals(Int32Testable(-34))
            ),
            test(
                "zero and maximum",
                Int32.rem(0, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and minimum",
                Int32.rem(0, Int32.minimumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum and maximum",
                Int32.rem(Int32.maximumValue, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and minimum",
                Int32.rem(Int32.minimumValue, Int32.minimumValue),
                M.equals(Int32Testable(0))
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
                Int32.pow(72, 3),
                M.equals(Int32Testable(373248))
            ),
            test(
                "positive base, zero exponent",
                Int32.pow(72, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "negative base, odd exponent",
                Int32.pow(-72, 3),
                M.equals(Int32Testable(-373248))
            ),
            test(
                "negative base, even exponent",
                Int32.pow(-72, 2),
                M.equals(Int32Testable(5184))
            ),
            test(
                "negative base, zero exponent",
                Int32.pow(-72, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "maximum and zero",
                Int32.pow(Int32.maximumValue, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "minimum and zero",
                Int32.pow(Int32.minimumValue, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "plus one and maximum",
                Int32.pow(1, Int32.maximumValue),
                M.equals(Int32Testable(1))
            ),
            test(
                "minus one and maximum",
                Int32.pow(-1, Int32.maximumValue),
                M.equals(Int32Testable(-1))
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
                Int32.bitnot(0),
                M.equals(Int32Testable(-1))
            ),
            test(
                "minus 1",
                Int32.bitnot(-1),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum",
                Int32.bitnot(Int32.maximumValue),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "minimum",
                Int32.bitnot(Int32.minimumValue),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "arbitrary",
                Int32.bitnot(1234),
                M.equals(Int32Testable(-1235))
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
                Int32.bitand(0xf0f0, 0x0f0f),
                M.equals(Int32Testable(0))
            ),
            test(
                "overlap",
                Int32.bitand(0x0ff0, 0xffff),
                M.equals(Int32Testable(0xff0))
            ),
            test(
                "arbitrary",
                Int32.bitand(0x1234_5678, 0x7654_3210),
                M.equals(Int32Testable(0x1214_1210))
            ),
            test(
                "negative",
                Int32.bitand(-123, -123),
                M.equals(Int32Testable(-123))
            ),
            test(
                "mixed signs",
                Int32.bitand(-256, 255),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero",
                Int32.bitand(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and maximum",
                Int32.bitand(0, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and zero",
                Int32.bitand(Int32.minimumValue, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and maximum",
                Int32.bitand(Int32.minimumValue, Int32.maximumValue),
                M.equals(Int32Testable(0))
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
                Int32.bitor(0xf0f0, 0x0f0f),
                M.equals(Int32Testable(0xffff))
            ),
            test(
                "overlap",
                Int32.bitor(0x0ff0, 0xffff),
                M.equals(Int32Testable(0xffff))
            ),
            test(
                "arbitrary",
                Int32.bitor(0x1234_5678, 0x7654_3210),
                M.equals(Int32Testable(0x7674_7678))
            ),
            test(
                "negative",
                Int32.bitor(-123, -123),
                M.equals(Int32Testable(-123))
            ),
            test(
                "mixed signs",
                Int32.bitor(-256, 255),
                M.equals(Int32Testable(-1))
            ),
            test(
                "zero",
                Int32.bitor(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and maximum",
                Int32.bitor(0, Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum and zero",
                Int32.bitor(Int32.minimumValue, 0),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "minimum and maximum",
                Int32.bitor(Int32.minimumValue, Int32.maximumValue),
                M.equals(Int32Testable(-1))
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
                Int32.bitxor(0xf0f0, 0x0f0f),
                M.equals(Int32Testable(0xffff))
            ),
            test(
                "overlap",
                Int32.bitxor(0x0ff0, 0xffff),
                M.equals(Int32Testable(0xf00f))
            ),
            test(
                "arbitrary",
                Int32.bitxor(0x1234_5678, 0x7654_3210),
                M.equals(Int32Testable(0x6460_6468))
            ),
            test(
                "negative",
                Int32.bitxor(-123, -123),
                M.equals(Int32Testable(0))
            ),
            test(
                "mixed signs",
                Int32.bitxor(-256, 255),
                M.equals(Int32Testable(-1))
            ),
            test(
                "zero",
                Int32.bitxor(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and maximum",
                Int32.bitxor(0, Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum and zero",
                Int32.bitxor(Int32.minimumValue, 0),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "minimum and maximum",
                Int32.bitxor(Int32.minimumValue, Int32.maximumValue),
                M.equals(Int32Testable(-1))
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
                Int32.bitshiftLeft(0xf0f0, 4),
                M.equals(Int32Testable(0xf_0f00))
            ),
            test(
                "negative number",
                Int32.bitshiftLeft(-256, 4),
                M.equals(Int32Testable(-4096))
            ),
            test(
                "arbitrary",
                Int32.bitshiftLeft(1234_5678, 7),
                M.equals(Int32Testable(1_580_246_784))
            ),
            test(
                "zero shift",
                Int32.bitshiftLeft(1234, 0),
                M.equals(Int32Testable(1234))
            ),
            test(
                "one maximum shift",
                Int32.bitshiftLeft(1, 31),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "minimum number",
                Int32.bitshiftLeft(-1, 31),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "discard overflow",
                Int32.bitshiftLeft(0x7fff_0000, 16),
                M.equals(Int32Testable(0))
            ),
            test(
                "beyond bit length positive",
                Int32.bitshiftLeft(0x1234_5678, 64 + 7),
                M.equals(Int32Testable(Int32.bitshiftLeft(0x1234_5678, 7)))
            ),
            test(
                "beyond bit length negative",
                Int32.bitshiftLeft(-0x1234_5678, 32 + 7),
                M.equals(Int32Testable(Int32.bitshiftLeft(-0x1234_5678, 7)))
            ),
            test(
                "negative shift argument",
                Int32.bitshiftLeft(0x1234_5678, -7),
                M.equals(Int32Testable(Int32.bitshiftLeft(0x1234_5678, 32 - 7)))
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
                Int32.bitshiftRight(0xf0f0, 4),
                M.equals(Int32Testable(0x0f0f))
            ),
            test(
                "negative number",
                Int32.bitshiftRight(-256, 4),
                M.equals(Int32Testable(-16))
            ),
            test(
                "arbitrary",
                Int32.bitshiftRight(1234_5678, 7),
                M.equals(Int32Testable(96_450))
            ),
            test(
                "zero shift",
                Int32.bitshiftRight(1234, 0),
                M.equals(Int32Testable(1234))
            ),
            test(
                "minus one maximum shift",
                Int32.bitshiftRight(-1, 31),
                M.equals(Int32Testable(-1))
            ),
            test(
                "minimum number",
                Int32.bitshiftRight(Int32.minimumValue, 31),
                M.equals(Int32Testable(-1))
            ),
            test(
                "discard underflow",
                Int32.bitshiftRight(0x0000_ffff, 16),
                M.equals(Int32Testable(0))
            ),
            test(
                "beyond bit length positive",
                Int32.bitshiftRight(0x1234_5678, 64 + 7),
                M.equals(Int32Testable(Int32.bitshiftRight(0x1234_5678, 7)))
            ),
            test(
                "beyond bit length negative",
                Int32.bitshiftRight(-0x1234_5678, 32 + 7),
                M.equals(Int32Testable(Int32.bitshiftRight(-0x1234_5678, 7)))
            ),
            test(
                "negative shift argument",
                Int32.bitshiftRight(0x1234_5678, -7),
                M.equals(Int32Testable(Int32.bitshiftRight(0x1234_5678, 32 - 7)))
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
                Int32.bitrotLeft(0xf0f0, 4),
                M.equals(Int32Testable(0xf_0f00))
            ),
            test(
                "positive number overflow",
                Int32.bitrotLeft(0x5600_1234, 8),
                M.equals(Int32Testable(0x12_3456))
            ),
            test(
                "negative number",
                Int32.bitrotLeft(-256, 4),
                M.equals(Int32Testable(-4081))
            ),
            test(
                "arbitrary",
                Int32.bitrotLeft(1_234_567_890, 7),
                M.equals(Int32Testable(-889_099_996))
            ),
            test(
                "zero shift",
                Int32.bitrotLeft(1234, 0),
                M.equals(Int32Testable(1234))
            ),
            test(
                "minus one maximum rotate",
                Int32.bitrotLeft(-1, 31),
                M.equals(Int32Testable(-1))
            ),
            test(
                "maximum number",
                Int32.bitrotLeft(Int32.maximumValue, 1),
                M.equals(Int32Testable(-2))
            ),
            test(
                "minimum number",
                Int32.bitrotLeft(1, 31),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "opposite rotation",
                Int32.bitrotLeft(256, -2),
                M.equals(Int32Testable(64))
            ),
            test(
                "rotate beyond bit length",
                Int32.bitrotLeft(128, 34),
                M.equals(Int32Testable(512))
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
                Int32.bitrotRight(0xf0f0, 4),
                M.equals(Int32Testable(0x0f0f))
            ),
            test(
                "positive number underflow",
                Int32.bitrotRight(0x5600_1234, 8),
                M.equals(Int32Testable(0x3456_0012))
            ),
            test(
                "negative number",
                Int32.bitrotRight(-256, 8),
                M.equals(Int32Testable(0x00ff_ffff))
            ),
            test(
                "arbitrary",
                Int32.bitrotRight(1_234_567_890, 7),
                M.equals(Int32Testable(-1_533_858_811))
            ),
            test(
                "zero shift",
                Int32.bitrotRight(1234, 0),
                M.equals(Int32Testable(1234))
            ),
            test(
                "minus one maximum rotate",
                Int32.bitrotRight(-1, 31),
                M.equals(Int32Testable(-1))
            ),
            test(
                "maximum number",
                Int32.bitrotRight(-2, 1),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum number",
                Int32.bitrotRight(Int32.minimumValue, 31),
                M.equals(Int32Testable(1))
            ),
            test(
                "opposite rotation",
                Int32.bitrotRight(256, -2),
                M.equals(Int32Testable(1024))
            ),
            test(
                "rotate beyond bit length",
                Int32.bitrotRight(128, 34),
                M.equals(Int32Testable(32))
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
                Int32.bittest(128, 7),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit",
                Int32.bittest(-129, 7),
                M.equals(T.bool(false))
            ),
            test(
                "all zero",
                do {
                    let number = 0 : Int32;
                    var count = 0;
                    for (index in Iter.range(0, 31)) {
                        if (Int32.bittest(number, index)) {
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
                    let number = -1 : Int32;
                    var count = 0;
                    for (index in Iter.range(0, 31)) {
                        if (Int32.bittest(number, index)) {
                            count += 1
                        }
                    };
                    count
                },
                M.equals(T.int(32))
            ),
            test(
                "set bit beyond bit length",
                Int32.bittest(128, 32 + 7),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit beyond bit length",
                Int32.bittest(-129, 64 + 7),
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
                Int32.bitset(0, 7),
                M.equals(Int32Testable(128))
            ),
            test(
                "minus one",
                Int32.bitset(-129, 7),
                M.equals(Int32Testable(-1))
            ),
            test(
                "no effect",
                Int32.bitset(128, 7),
                M.equals(Int32Testable(128))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int32;
                    for (index in Iter.range(0, 31)) {
                        number := Int32.bitset(number, index)
                    };
                    number
                },
                M.equals(Int32Testable(-1))
            ),
            test(
                "all no effect",
                do {
                    var number = -1 : Int32;
                    for (index in Iter.range(0, 31)) {
                        number := Int32.bitset(number, index)
                    };
                    number
                },
                M.equals(Int32Testable(-1))
            ),
            test(
                "set bit beyond bit length",
                Int32.bitset(0, 32 + 7),
                M.equals(Int32Testable(128))
            ),
            test(
                "minus one beyond bit length",
                Int32.bitset(-129, 64 + 7),
                M.equals(Int32Testable(-1))
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
                Int32.bitclear(128, 7),
                M.equals(Int32Testable(0))
            ),
            test(
                "minus one",
                Int32.bitclear(-1, 7),
                M.equals(Int32Testable(-129))
            ),
            test(
                "no effect",
                Int32.bitclear(0, 7),
                M.equals(Int32Testable(0))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int32;
                    for (index in Iter.range(0, 31)) {
                        number := Int32.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int32Testable(0))
            ),
            test(
                "all no effect",
                do {
                    var number = 0 : Int32;
                    for (index in Iter.range(0, 31)) {
                        number := Int32.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int32Testable(0))
            ),
            test(
                "clear bit beyond bit length",
                Int32.bitclear(128, 32 + 7),
                M.equals(Int32Testable(0))
            ),
            test(
                "minus one beyond bit length",
                Int32.bitclear(-1, 64 + 7),
                M.equals(Int32Testable(-129))
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
                Int32.bitflip(255, 7),
                M.equals(Int32Testable(127))
            ),
            test(
                "set bit",
                Int32.bitflip(127, 7),
                M.equals(Int32Testable(255))
            ),
            test(
                "double flip",
                Int32.bitflip(Int32.bitflip(0x1234_5678, 13), 13),
                M.equals(Int32Testable(0x1234_5678))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int32;
                    for (index in Iter.range(0, 31)) {
                        number := Int32.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int32Testable(0))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int32;
                    for (index in Iter.range(0, 31)) {
                        number := Int32.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int32Testable(-1))
            ),
            test(
                "clear bit beyond bit length",
                Int32.bitflip(255, 32 + 7),
                M.equals(Int32Testable(127))
            ),
            test(
                "set bit beyond bit length",
                Int32.bitflip(127, 64 + 7),
                M.equals(Int32Testable(255))
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
                Int32.bitcountNonZero(0),
                M.equals(Int32Testable(0))
            ),
            test(
                "minus one",
                Int32.bitcountNonZero(-1),
                M.equals(Int32Testable(32))
            ),
            test(
                "minus two",
                Int32.bitcountNonZero(-2),
                M.equals(Int32Testable(31))
            ),
            test(
                "one",
                Int32.bitcountNonZero(1),
                M.equals(Int32Testable(1))
            ),
            test(
                "minimum value",
                Int32.bitcountNonZero(Int32.minimumValue),
                M.equals(Int32Testable(1))
            ),
            test(
                "maximum value",
                Int32.bitcountNonZero(Int32.maximumValue),
                M.equals(Int32Testable(31))
            ),
            test(
                "alternating bits positive",
                Int32.bitcountNonZero(0x5555_5555),
                M.equals(Int32Testable(16))
            ),
            test(
                "alternating bits negative",
                Int32.bitcountNonZero(-0x5555_5556),
                M.equals(Int32Testable(16))
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
                Int32.bitcountLeadingZero(0),
                M.equals(Int32Testable(32))
            ),
            test(
                "minus one",
                Int32.bitcountLeadingZero(-1),
                M.equals(Int32Testable(0))
            ),
            test(
                "minus two",
                Int32.bitcountLeadingZero(-2),
                M.equals(Int32Testable(0))
            ),
            test(
                "one",
                Int32.bitcountLeadingZero(1),
                M.equals(Int32Testable(31))
            ),
            test(
                "two",
                Int32.bitcountLeadingZero(2),
                M.equals(Int32Testable(30))
            ),
            test(
                "arbitrary",
                Int32.bitcountLeadingZero(0x0000_1020),
                M.equals(Int32Testable(19))
            ),
            test(
                "minimum value",
                Int32.bitcountLeadingZero(Int32.minimumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum value",
                Int32.bitcountLeadingZero(Int32.maximumValue),
                M.equals(Int32Testable(1))
            ),
            test(
                "alternating bits positive",
                Int32.bitcountLeadingZero(0x5555_5555),
                M.equals(Int32Testable(1))
            ),
            test(
                "alternating bits negative",
                Int32.bitcountLeadingZero(-0x5555_5556),
                M.equals(Int32Testable(0))
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
                Int32.bitcountTrailingZero(0),
                M.equals(Int32Testable(32))
            ),
            test(
                "minus one",
                Int32.bitcountTrailingZero(-1),
                M.equals(Int32Testable(0))
            ),
            test(
                "minus two",
                Int32.bitcountTrailingZero(-2),
                M.equals(Int32Testable(1))
            ),
            test(
                "one",
                Int32.bitcountTrailingZero(1),
                M.equals(Int32Testable(0))
            ),
            test(
                "two",
                Int32.bitcountTrailingZero(2),
                M.equals(Int32Testable(1))
            ),
            test(
                "arbitrary",
                Int32.bitcountTrailingZero(0x5060_0000),
                M.equals(Int32Testable(21))
            ),
            test(
                "minimum value",
                Int32.bitcountTrailingZero(Int32.minimumValue),
                M.equals(Int32Testable(31))
            ),
            test(
                "maximum value",
                Int32.bitcountTrailingZero(Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "alternating bits positive",
                Int32.bitcountTrailingZero(0x5555_5555),
                M.equals(Int32Testable(0))
            ),
            test(
                "alternating bits negative",
                Int32.bitcountTrailingZero(-0x5555_5556),
                M.equals(Int32Testable(1))
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
                Int32.addWrap(123, 123),
                M.equals(Int32Testable(246))
            ),
            test(
                "negative",
                Int32.addWrap(-123, -123),
                M.equals(Int32Testable(-246))
            ),
            test(
                "mixed signs",
                Int32.addWrap(-123, 223),
                M.equals(Int32Testable(100))
            ),
            test(
                "zero",
                Int32.addWrap(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and maximum",
                Int32.addWrap(Int32.minimumValue, Int32.maximumValue),
                M.equals(Int32Testable(-1))
            ),
            test(
                "small overflow",
                Int32.addWrap(Int32.maximumValue, 1),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "large overflow",
                Int32.addWrap(Int32.maximumValue, Int32.maximumValue),
                M.equals(Int32Testable(-2))
            ),
            test(
                "small underflow",
                Int32.addWrap(Int32.minimumValue, -1),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "large underflow",
                Int32.addWrap(Int32.minimumValue, Int32.minimumValue),
                M.equals(Int32Testable(0))
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
                Int32.subWrap(123, 123),
                M.equals(Int32Testable(0))
            ),
            test(
                "negative",
                Int32.subWrap(-123, -123),
                M.equals(Int32Testable(0))
            ),
            test(
                "mixed signs",
                Int32.subWrap(-123, 223),
                M.equals(Int32Testable(-346))
            ),
            test(
                "zero",
                Int32.subWrap(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "maximum and maximum",
                Int32.subWrap(Int32.maximumValue, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "small overflow",
                Int32.subWrap(Int32.maximumValue, -1),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "large overflow",
                Int32.subWrap(Int32.maximumValue, Int32.minimumValue),
                M.equals(Int32Testable(-1))
            ),
            test(
                "small underflow",
                Int32.subWrap(Int32.minimumValue, 1),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "large underflow",
                Int32.subWrap(Int32.minimumValue, Int32.maximumValue),
                M.equals(Int32Testable(1))
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
                Int32.mulWrap(123, 234),
                M.equals(Int32Testable(28782))
            ),
            test(
                "negative",
                Int32.mulWrap(-123, -234),
                M.equals(Int32Testable(28782))
            ),
            test(
                "mixed signs",
                Int32.mulWrap(-123, 234),
                M.equals(Int32Testable(-28782))
            ),
            test(
                "zeros",
                Int32.mulWrap(0, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "zero and maximum",
                Int32.mulWrap(0, Int32.maximumValue),
                M.equals(Int32Testable(0))
            ),
            test(
                "minimum and zero",
                Int32.mulWrap(Int32.minimumValue, 0),
                M.equals(Int32Testable(0))
            ),
            test(
                "one and maximum",
                Int32.mulWrap(1, Int32.maximumValue),
                M.equals(Int32Testable(Int32.maximumValue))
            ),
            test(
                "minimum and one",
                Int32.mulWrap(Int32.minimumValue, 1),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "small overflow",
                Int32.mulWrap(2, Int32.maximumValue),
                M.equals(Int32Testable(-2))
            ),
            test(
                "large overflow",
                Int32.mulWrap(Int32.maximumValue, Int32.maximumValue),
                M.equals(Int32Testable(1))
            ),
            test(
                "small underflow",
                Int32.mulWrap(Int32.minimumValue, 2),
                M.equals(Int32Testable(0))
            ),
            test(
                "large underflow",
                Int32.mulWrap(Int32.minimumValue, Int32.minimumValue),
                M.equals(Int32Testable(0))
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
                Int32.powWrap(72, 3),
                M.equals(Int32Testable(373248))
            ),
            test(
                "positive base, zero exponent",
                Int32.powWrap(72, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "negative base, positive exponent",
                Int32.powWrap(-72, 3),
                M.equals(Int32Testable(-373248))
            ),
            test(
                "negative base, zero exponent",
                Int32.powWrap(-72, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "maximum and zero",
                Int32.powWrap(Int32.maximumValue, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "minimum and zero",
                Int32.powWrap(Int32.minimumValue, 0),
                M.equals(Int32Testable(1))
            ),
            test(
                "plus one and maximum",
                Int32.powWrap(1, Int32.maximumValue),
                M.equals(Int32Testable(1))
            ),
            test(
                "minus one and maximum",
                Int32.powWrap(-1, Int32.maximumValue),
                M.equals(Int32Testable(-1))
            ),
            test(
                "minimum value",
                Int32.powWrap(-2, 31),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "small overflow",
                Int32.powWrap(2, 31),
                M.equals(Int32Testable(Int32.minimumValue))
            ),
            test(
                "large overflow",
                Int32.powWrap(Int32.maximumValue, 10),
                M.equals(Int32Testable(1))
            ),
            test(
                "small underflow",
                Int32.powWrap(-2, 33),
                M.equals(Int32Testable(0))
            ),
            test(
                "large underflow",
                Int32.powWrap(Int32.minimumValue, 10),
                M.equals(Int32Testable(0))
            ),
        ]
    )
)
