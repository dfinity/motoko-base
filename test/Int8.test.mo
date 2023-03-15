// @testmode wasi

import Int8 "mo:base/Int8";
import Order "mo:base/Order";
import Iter "mo:base/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let maximumInt8asInt = +2 ** 7 - 1 : Int;
let maximumInt8asNat8 = 2 ** 7 - 1 : Nat8;

let minimumInt8asInt = -2 ** 7 : Int;

let maximumNat8 = 255 : Nat8;

class Int8Testable(number : Int8) : T.TestableItem<Int8> {
    public let item = number;
    public func display(number : Int8) : Text {
        debug_show (number)
    };
    public let equals = func(x : Int8, y : Int8) : Bool {
        x == y
    }
};

class Nat8Testable(number : Nat8) : T.TestableItem<Nat8> {
    public let item = number;
    public func display(number : Nat8) : Text {
        debug_show (number)
    };
    public let equals = func(x : Nat8, y : Nat8) : Bool {
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
                Int8.minimumValue,
                M.equals(Int8Testable(Int8.fromInt(-2 ** 7)))
            ),
            test(
                "maximum value",
                Int8.maximumValue,
                M.equals(Int8Testable(Int8.fromInt(+2 ** 7 - 1)))
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
                Int8.toInt(Int8.maximumValue),
                M.equals(T.int(maximumInt8asInt))
            ),
            test(
                "minimum number",
                Int8.toInt(Int8.minimumValue),
                M.equals(T.int(minimumInt8asInt))
            ),
            test(
                "one",
                Int8.toInt(1),
                M.equals(T.int(1))
            ),
            test(
                "minus one",
                Int8.toInt(-1),
                M.equals(T.int(-1))
            ),
            test(
                "zero",
                Int8.toInt(0),
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
                Int8.fromInt(maximumInt8asInt),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum number",
                Int8.fromInt(minimumInt8asInt),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "one",
                Int8.fromInt(1),
                M.equals(Int8Testable(1))
            ),
            test(
                "minus one",
                Int8.fromInt(-1),
                M.equals(Int8Testable(-1))
            ),
            test(
                "zero",
                Int8.fromInt(0),
                M.equals(Int8Testable(0))
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
                Int8.fromIntWrap(maximumInt8asInt),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum number",
                Int8.fromIntWrap(minimumInt8asInt),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "one",
                Int8.fromIntWrap(1),
                M.equals(Int8Testable(1))
            ),
            test(
                "minus one",
                Int8.fromIntWrap(-1),
                M.equals(Int8Testable(-1))
            ),
            test(
                "zero",
                Int8.fromIntWrap(0),
                M.equals(Int8Testable(0))
            ),
            test(
                "overflow",
                Int8.fromIntWrap(maximumInt8asInt + 1),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "underflow",
                Int8.fromIntWrap(minimumInt8asInt - 1),
                M.equals(Int8Testable(Int8.maximumValue))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "fromNat8",
        [
            test(
                "maximum number",
                Int8.fromNat8(maximumInt8asNat8),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "one",
                Int8.fromNat8(1),
                M.equals(Int8Testable(1))
            ),
            test(
                "zero",
                Int8.fromNat8(0),
                M.equals(Int8Testable(0))
            ),
            test(
                "overflow",
                Int8.fromNat8(maximumInt8asNat8 + 1),
                M.equals(Int8Testable(Int8.minimumValue))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "toNat8",
        [
            test(
                "maximum number",
                Int8.toNat8(Int8.maximumValue),
                M.equals(Nat8Testable(maximumInt8asNat8))
            ),
            test(
                "one",
                Int8.toNat8(1),
                M.equals(Nat8Testable(1))
            ),
            test(
                "zero",
                Int8.toNat8(0),
                M.equals(Nat8Testable(0))
            ),
            test(
                "underflow",
                Int8.toNat8(-1),
                M.equals(Nat8Testable(maximumNat8))
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
                Int8.toText(123),
                M.equals(T.text("123"))
            ),
            test(
                "negative",
                Int8.toText(-123),
                M.equals(T.text("-123"))
            ),
            test(
                "zero",
                Int8.toText(0),
                M.equals(T.text("0"))
            ),
            test(
                "maximum number",
                Int8.toText(Int8.maximumValue),
                M.equals(T.text("127"))
            ),
            test(
                "minimum number",
                Int8.toText(Int8.minimumValue),
                M.equals(T.text("-128"))
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
                Int8.abs(123),
                M.equals(Int8Testable(123))
            ),
            test(
                "negative number",
                Int8.abs(-123),
                M.equals(Int8Testable(123))
            ),
            test(
                "zero",
                Int8.abs(0),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum number",
                Int8.abs(Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "smallest possible",
                Int8.abs(-Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
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
                Int8.min(2, 3),
                M.equals(Int8Testable(2))
            ),
            test(
                "positive, negative",
                Int8.min(2, -3),
                M.equals(Int8Testable(-3))
            ),
            test(
                "both negative",
                Int8.min(-2, -3),
                M.equals(Int8Testable(-3))
            ),
            test(
                "negative, positive",
                Int8.min(-2, 3),
                M.equals(Int8Testable(-2))
            ),
            test(
                "equal values",
                Int8.min(123, 123),
                M.equals(Int8Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int8.min(Int8.maximumValue, Int8.minimumValue),
                M.equals(Int8Testable(Int8.minimumValue))
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
                Int8.max(2, 3),
                M.equals(Int8Testable(3))
            ),
            test(
                "positive, negative",
                Int8.max(2, -3),
                M.equals(Int8Testable(2))
            ),
            test(
                "both negative",
                Int8.max(-2, -3),
                M.equals(Int8Testable(-2))
            ),
            test(
                "negative, positive",
                Int8.max(-2, 3),
                M.equals(Int8Testable(3))
            ),
            test(
                "equal values",
                Int8.max(123, 123),
                M.equals(Int8Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int8.max(Int8.maximumValue, Int8.minimumValue),
                M.equals(Int8Testable(Int8.maximumValue))
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
                Int8.equal(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int8.equal(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int8.equal(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "positive not equal",
                Int8.equal(123, 124),
                M.equals(T.bool(false))
            ),
            test(
                "negative not equal",
                Int8.equal(-123, -124),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs",
                Int8.equal(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "maxmimum equal",
                Int8.equal(Int8.maximumValue, Int8.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum equal",
                Int8.equal(Int8.minimumValue, Int8.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int8.equal(Int8.minimumValue, Int8.maximumValue),
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
                Int8.notEqual(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int8.notEqual(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int8.notEqual(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "positive not equal",
                Int8.notEqual(123, 124),
                M.equals(T.bool(true))
            ),
            test(
                "negative not equal",
                Int8.notEqual(-123, -124),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs",
                Int8.notEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "maxmimum equal",
                Int8.notEqual(Int8.maximumValue, Int8.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum equal",
                Int8.notEqual(Int8.minimumValue, Int8.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int8.notEqual(Int8.minimumValue, Int8.maximumValue),
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
                Int8.less(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int8.less(123, 124),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int8.less(124, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int8.less(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int8.less(-124, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int8.less(-123, -124),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int8.less(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int8.less(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int8.less(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int8.less(Int8.minimumValue, Int8.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int8.less(Int8.maximumValue, Int8.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int8.less(Int8.maximumValue, Int8.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int8.less(Int8.minimumValue, Int8.minimumValue),
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
                Int8.lessOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int8.lessOrEqual(123, 124),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int8.lessOrEqual(124, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int8.lessOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int8.lessOrEqual(-124, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int8.lessOrEqual(-123, -124),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int8.lessOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int8.lessOrEqual(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int8.lessOrEqual(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int8.lessOrEqual(Int8.minimumValue, Int8.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int8.lessOrEqual(Int8.maximumValue, Int8.minimumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int8.lessOrEqual(Int8.maximumValue, Int8.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int8.lessOrEqual(Int8.minimumValue, Int8.minimumValue),
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
                Int8.greater(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int8.greater(123, 124),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int8.greater(124, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int8.greater(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int8.greater(-124, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int8.greater(-123, -124),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int8.greater(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int8.greater(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int8.greater(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int8.greater(Int8.minimumValue, Int8.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int8.greater(Int8.maximumValue, Int8.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int8.greater(Int8.maximumValue, Int8.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int8.greater(Int8.minimumValue, Int8.minimumValue),
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
                Int8.greaterOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int8.greaterOrEqual(123, 124),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int8.greaterOrEqual(124, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int8.greaterOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int8.greaterOrEqual(-124, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int8.greaterOrEqual(-123, -124),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int8.greaterOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int8.greaterOrEqual(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int8.greaterOrEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int8.greaterOrEqual(Int8.minimumValue, Int8.maximumValue),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int8.greaterOrEqual(Int8.maximumValue, Int8.minimumValue),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int8.greaterOrEqual(Int8.maximumValue, Int8.maximumValue),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int8.greaterOrEqual(Int8.minimumValue, Int8.minimumValue),
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
                Int8.compare(123, 123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "positive less",
                Int8.compare(123, 124),
                M.equals(OrderTestable(#less))
            ),
            test(
                "positive greater",
                Int8.compare(124, 123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "negative equal",
                Int8.compare(-123, -123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "negative less",
                Int8.compare(-124, -123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "negative greater",
                Int8.compare(-123, -124),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "zero",
                Int8.compare(0, 0),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "mixed signs less",
                Int8.compare(-123, 123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "mixed signs greater",
                Int8.compare(123, -123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "minimum and maximum",
                Int8.compare(Int8.minimumValue, Int8.maximumValue),
                M.equals(OrderTestable(#less))
            ),
            test(
                "maximum and minimum",
                Int8.compare(Int8.maximumValue, Int8.minimumValue),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "maximum and maximum",
                Int8.compare(Int8.maximumValue, Int8.maximumValue),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "minimum and minimum",
                Int8.compare(Int8.minimumValue, Int8.minimumValue),
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
                Int8.neg(123),
                M.equals(Int8Testable(-123))
            ),
            test(
                "negative number",
                Int8.neg(-123),
                M.equals(Int8Testable(123))
            ),
            test(
                "zero",
                Int8.neg(0),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum number",
                Int8.neg(Int8.maximumValue),
                M.equals(Int8Testable(-Int8.maximumValue))
            ),
            test(
                "smallest possible",
                Int8.neg(-Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
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
                Int8.add(100, 23),
                M.equals(Int8Testable(123))
            ),
            test(
                "negative",
                Int8.add(-100, -23),
                M.equals(Int8Testable(-123))
            ),
            test(
                "mixed signs",
                Int8.add(-123, 23),
                M.equals(Int8Testable(-100))
            ),
            test(
                "zero",
                Int8.add(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and maximum",
                Int8.add(Int8.minimumValue, Int8.maximumValue),
                M.equals(Int8Testable(-1))
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
                Int8.sub(123, 123),
                M.equals(Int8Testable(0))
            ),
            test(
                "negative",
                Int8.sub(-123, -123),
                M.equals(Int8Testable(0))
            ),
            test(
                "mixed signs",
                Int8.sub(-100, 23),
                M.equals(Int8Testable(-123))
            ),
            test(
                "zero",
                Int8.sub(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum and maximum",
                Int8.sub(Int8.maximumValue, Int8.maximumValue),
                M.equals(Int8Testable(0))
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
                Int8.mul(7, 15),
                M.equals(Int8Testable(105))
            ),
            test(
                "negative",
                Int8.mul(-7, -15),
                M.equals(Int8Testable(105))
            ),
            test(
                "mixed signs",
                Int8.mul(-7, 15),
                M.equals(Int8Testable(-105))
            ),
            test(
                "zeros",
                Int8.mul(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and maximum",
                Int8.mul(0, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and zero",
                Int8.mul(Int8.minimumValue, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "one and maximum",
                Int8.mul(1, Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum and one",
                Int8.mul(Int8.minimumValue, 1),
                M.equals(Int8Testable(Int8.minimumValue))
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
                Int8.div(121, 11),
                M.equals(Int8Testable(11))
            ),
            test(
                "positive remainder",
                Int8.div(121, 13),
                M.equals(Int8Testable(9))
            ),
            test(
                "negative multiple",
                Int8.div(-121, -11),
                M.equals(Int8Testable(11))
            ),
            test(
                "negative remainder",
                Int8.div(-121, -13),
                M.equals(Int8Testable(9))
            ),
            test(
                "mixed signs",
                Int8.div(-121, 13),
                M.equals(Int8Testable(-9))
            ),
            test(
                "zero and number",
                Int8.div(0, -123),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and maximum",
                Int8.div(0, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and minimum",
                Int8.div(0, Int8.minimumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum and maximum",
                Int8.div(Int8.maximumValue, Int8.maximumValue),
                M.equals(Int8Testable(1))
            ),
            test(
                "minimum and minimum",
                Int8.div(Int8.minimumValue, Int8.minimumValue),
                M.equals(Int8Testable(1))
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
                Int8.rem(121, 11),
                M.equals(Int8Testable(0))
            ),
            test(
                "positive/positive remainder",
                Int8.rem(121, 13),
                M.equals(Int8Testable(4))
            ),
            test(
                "positive/negative remainder",
                Int8.rem(121, -13),
                M.equals(Int8Testable(4))
            ),
            test(
                "negative multiple",
                Int8.rem(-121, -11),
                M.equals(Int8Testable(0))
            ),
            test(
                "negative/positive remainder",
                Int8.rem(-121, 13),
                M.equals(Int8Testable(-4))
            ),
            test(
                "negative/negative remainder",
                Int8.rem(-121, -13),
                M.equals(Int8Testable(-4))
            ),
            test(
                "zero and maximum",
                Int8.rem(0, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and minimum",
                Int8.rem(0, Int8.minimumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum and maximum",
                Int8.rem(Int8.maximumValue, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and minimum",
                Int8.rem(Int8.minimumValue, Int8.minimumValue),
                M.equals(Int8Testable(0))
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
                Int8.pow(3, 4),
                M.equals(Int8Testable(81))
            ),
            test(
                "positive base, zero exponent",
                Int8.pow(2, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "negative base, odd exponent",
                Int8.pow(-3, 3),
                M.equals(Int8Testable(-27))
            ),
            test(
                "negative base, even exponent",
                Int8.pow(-3, 4),
                M.equals(Int8Testable(81))
            ),
            test(
                "negative base, zero exponent",
                Int8.pow(-3, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "maximum and zero",
                Int8.pow(Int8.maximumValue, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "minimum and zero",
                Int8.pow(Int8.minimumValue, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "plus one and maximum",
                Int8.pow(1, Int8.maximumValue),
                M.equals(Int8Testable(1))
            ),
            test(
                "minus one and maximum",
                Int8.pow(-1, Int8.maximumValue),
                M.equals(Int8Testable(-1))
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
                Int8.bitnot(0),
                M.equals(Int8Testable(-1))
            ),
            test(
                "minus 1",
                Int8.bitnot(-1),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum",
                Int8.bitnot(Int8.maximumValue),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "minimum",
                Int8.bitnot(Int8.minimumValue),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "arbitrary",
                Int8.bitnot(123),
                M.equals(Int8Testable(-124))
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
                Int8.bitand(0x70, 0x0f),
                M.equals(Int8Testable(0))
            ),
            test(
                "overlap",
                Int8.bitand(0x50, 0x7f),
                M.equals(Int8Testable(0x50))
            ),
            test(
                "arbitrary",
                Int8.bitand(0x12, 0x76),
                M.equals(Int8Testable(0x12))
            ),
            test(
                "negative",
                Int8.bitand(-123, -123),
                M.equals(Int8Testable(-123))
            ),
            test(
                "mixed signs",
                Int8.bitand(-64, 63),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero",
                Int8.bitand(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and maximum",
                Int8.bitand(0, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and zero",
                Int8.bitand(Int8.minimumValue, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and maximum",
                Int8.bitand(Int8.minimumValue, Int8.maximumValue),
                M.equals(Int8Testable(0))
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
                Int8.bitor(0x70, 0x0f),
                M.equals(Int8Testable(0x7f))
            ),
            test(
                "overlap",
                Int8.bitor(0x0f, 0x7f),
                M.equals(Int8Testable(0x7f))
            ),
            test(
                "arbitrary",
                Int8.bitor(0x12, 0x76),
                M.equals(Int8Testable(0x76))
            ),
            test(
                "negative",
                Int8.bitor(-123, -123),
                M.equals(Int8Testable(-123))
            ),
            test(
                "mixed signs",
                Int8.bitor(-128, 127),
                M.equals(Int8Testable(-1))
            ),
            test(
                "zero",
                Int8.bitor(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and maximum",
                Int8.bitor(0, Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum and zero",
                Int8.bitor(Int8.minimumValue, 0),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "minimum and maximum",
                Int8.bitor(Int8.minimumValue, Int8.maximumValue),
                M.equals(Int8Testable(-1))
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
                Int8.bitxor(0x70, 0x0f),
                M.equals(Int8Testable(0x7f))
            ),
            test(
                "overlap",
                Int8.bitxor(0x0f, 0x7f),
                M.equals(Int8Testable(0x70))
            ),
            test(
                "arbitrary",
                Int8.bitxor(0x12, 0x76),
                M.equals(Int8Testable(0x64))
            ),
            test(
                "negative",
                Int8.bitxor(-123, -123),
                M.equals(Int8Testable(0))
            ),
            test(
                "mixed signs",
                Int8.bitxor(-128, 127),
                M.equals(Int8Testable(-1))
            ),
            test(
                "zero",
                Int8.bitxor(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and maximum",
                Int8.bitxor(0, Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum and zero",
                Int8.bitxor(Int8.minimumValue, 0),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "minimum and maximum",
                Int8.bitxor(Int8.minimumValue, Int8.maximumValue),
                M.equals(Int8Testable(-1))
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
                Int8.bitshiftLeft(0x71, 4),
                M.equals(Int8Testable(0x10))
            ),
            test(
                "negative number",
                Int8.bitshiftLeft(-32, 2),
                M.equals(Int8Testable(-128))
            ),
            test(
                "arbitrary",
                Int8.bitshiftLeft(100, 3),
                M.equals(Int8Testable(32))
            ),
            test(
                "zero shift",
                Int8.bitshiftLeft(123, 0),
                M.equals(Int8Testable(123))
            ),
            test(
                "one maximum shift",
                Int8.bitshiftLeft(1, 7),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "minimum number",
                Int8.bitshiftLeft(-1, 7),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "discard overflow",
                Int8.bitshiftLeft(0x7f, 4),
                M.equals(Int8Testable(-16))
            ),
            test(
                "beyond bit length positive",
                Int8.bitshiftLeft(0x12, 16 + 7),
                M.equals(Int8Testable(Int8.bitshiftLeft(0x12, 7)))
            ),
            test(
                "beyond bit length negative",
                Int8.bitshiftLeft(-0x12, 8 + 7),
                M.equals(Int8Testable(Int8.bitshiftLeft(-0x12, 7)))
            ),
            test(
                "negative shift argument",
                Int8.bitshiftLeft(0x12, -7),
                M.equals(Int8Testable(Int8.bitshiftLeft(0x12, 8 - 7)))
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
                Int8.bitshiftRight(0x71, 4),
                M.equals(Int8Testable(0x07))
            ),
            test(
                "negative number",
                Int8.bitshiftRight(-32, 2),
                M.equals(Int8Testable(-8))
            ),
            test(
                "arbitrary",
                Int8.bitshiftRight(100, 3),
                M.equals(Int8Testable(12))
            ),
            test(
                "zero shift",
                Int8.bitshiftRight(123, 0),
                M.equals(Int8Testable(123))
            ),
            test(
                "minus one maximum shift",
                Int8.bitshiftRight(-1, 7),
                M.equals(Int8Testable(-1))
            ),
            test(
                "minimum number",
                Int8.bitshiftRight(Int8.minimumValue, 7),
                M.equals(Int8Testable(-1))
            ),
            test(
                "discard underflow",
                Int8.bitshiftRight(0x0f, 4),
                M.equals(Int8Testable(0))
            ),
            test(
                "beyond bit length positive",
                Int8.bitshiftRight(0x12, 16 + 3),
                M.equals(Int8Testable(Int8.bitshiftRight(0x12, 3)))
            ),
            test(
                "beyond bit length negative",
                Int8.bitshiftRight(-0x12, 8 + 3),
                M.equals(Int8Testable(Int8.bitshiftRight(-0x12, 3)))
            ),
            test(
                "negative shift argument",
                Int8.bitshiftRight(0x12, -3),
                M.equals(Int8Testable(Int8.bitshiftRight(0x12, 8 - 3)))
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
                Int8.bitrotLeft(0x07, 4),
                M.equals(Int8Testable(0x70))
            ),
            test(
                "positive number overflow",
                Int8.bitrotLeft(0x12, 4),
                M.equals(Int8Testable(0x21))
            ),
            test(
                "negative number",
                Int8.bitrotLeft(-128, 2),
                M.equals(Int8Testable(2))
            ),
            test(
                "arbitrary",
                Int8.bitrotLeft(123, 3),
                M.equals(Int8Testable(-37))
            ),
            test(
                "zero shift",
                Int8.bitrotLeft(123, 0),
                M.equals(Int8Testable(123))
            ),
            test(
                "minus one maximum rotate",
                Int8.bitrotLeft(-1, 7),
                M.equals(Int8Testable(-1))
            ),
            test(
                "maximum number",
                Int8.bitrotLeft(Int8.maximumValue, 1),
                M.equals(Int8Testable(-2))
            ),
            test(
                "minimum number",
                Int8.bitrotLeft(1, 7),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "opposite rotation",
                Int8.bitrotLeft(64, -2),
                M.equals(Int8Testable(16))
            ),
            test(
                "rotate beyond bit length",
                Int8.bitrotLeft(64, 10),
                M.equals(Int8Testable(1))
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
                Int8.bitrotRight(0x70, 4),
                M.equals(Int8Testable(0x07))
            ),
            test(
                "positive number underflow",
                Int8.bitrotRight(0x12, 4),
                M.equals(Int8Testable(0x21))
            ),
            test(
                "negative number",
                Int8.bitrotRight(-128, 2),
                M.equals(Int8Testable(32))
            ),
            test(
                "arbitrary",
                Int8.bitrotRight(123, 3),
                M.equals(Int8Testable(111))
            ),
            test(
                "zero shift",
                Int8.bitrotRight(123, 0),
                M.equals(Int8Testable(123))
            ),
            test(
                "minus one maximum rotate",
                Int8.bitrotRight(-1, 7),
                M.equals(Int8Testable(-1))
            ),
            test(
                "maximum number",
                Int8.bitrotRight(-2, 1),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum number",
                Int8.bitrotRight(Int8.minimumValue, 7),
                M.equals(Int8Testable(1))
            ),
            test(
                "opposite rotation",
                Int8.bitrotRight(16, -2),
                M.equals(Int8Testable(64))
            ),
            test(
                "rotate beyond bit length",
                Int8.bitrotRight(64, 10),
                M.equals(Int8Testable(16))
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
                Int8.bittest(64, 6),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit",
                Int8.bittest(-65, 6),
                M.equals(T.bool(false))
            ),
            test(
                "all zero",
                do {
                    let number = 0 : Int8;
                    var count = 0;
                    for (index in Iter.range(0, 7)) {
                        if (Int8.bittest(number, index)) {
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
                    let number = -1 : Int8;
                    var count = 0;
                    for (index in Iter.range(0, 7)) {
                        if (Int8.bittest(number, index)) {
                            count += 1
                        }
                    };
                    count
                },
                M.equals(T.int(8))
            ),
            test(
                "set bit beyond bit length",
                Int8.bittest(64, 8 + 6),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit beyond bit length",
                Int8.bittest(-65, 16 + 6),
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
                Int8.bitset(0, 6),
                M.equals(Int8Testable(64))
            ),
            test(
                "minus one",
                Int8.bitset(-65, 6),
                M.equals(Int8Testable(-1))
            ),
            test(
                "no effect",
                Int8.bitset(64, 6),
                M.equals(Int8Testable(64))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int8;
                    for (index in Iter.range(0, 7)) {
                        number := Int8.bitset(number, index)
                    };
                    number
                },
                M.equals(Int8Testable(-1))
            ),
            test(
                "all no effect",
                do {
                    var number = -1 : Int8;
                    for (index in Iter.range(0, 7)) {
                        number := Int8.bitset(number, index)
                    };
                    number
                },
                M.equals(Int8Testable(-1))
            ),
            test(
                "set bit beyond bit length",
                Int8.bitset(0, 8 + 6),
                M.equals(Int8Testable(64))
            ),
            test(
                "minus one beyond bit length",
                Int8.bitset(-65, 16 + 6),
                M.equals(Int8Testable(-1))
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
                Int8.bitclear(64, 6),
                M.equals(Int8Testable(0))
            ),
            test(
                "minus one",
                Int8.bitclear(-1, 6),
                M.equals(Int8Testable(-65))
            ),
            test(
                "no effect",
                Int8.bitclear(0, 6),
                M.equals(Int8Testable(0))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int8;
                    for (index in Iter.range(0, 7)) {
                        number := Int8.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int8Testable(0))
            ),
            test(
                "all no effect",
                do {
                    var number = 0 : Int8;
                    for (index in Iter.range(0, 7)) {
                        number := Int8.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int8Testable(0))
            ),
            test(
                "clear bit beyond bit length",
                Int8.bitclear(64, 8 + 6),
                M.equals(Int8Testable(0))
            ),
            test(
                "minus one beyond bit length",
                Int8.bitclear(-1, 16 + 6),
                M.equals(Int8Testable(-65))
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
                Int8.bitflip(127, 6),
                M.equals(Int8Testable(63))
            ),
            test(
                "set bit",
                Int8.bitflip(63, 6),
                M.equals(Int8Testable(127))
            ),
            test(
                "double flip",
                Int8.bitflip(Int8.bitflip(0x12, 5), 5),
                M.equals(Int8Testable(0x12))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int8;
                    for (index in Iter.range(0, 7)) {
                        number := Int8.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int8Testable(0))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int8;
                    for (index in Iter.range(0, 7)) {
                        number := Int8.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int8Testable(-1))
            ),
            test(
                "clear bit beyond bit length",
                Int8.bitflip(127, 8 + 6),
                M.equals(Int8Testable(63))
            ),
            test(
                "set bit beyond bit length",
                Int8.bitflip(63, 16 + 6),
                M.equals(Int8Testable(127))
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
                Int8.bitcountNonZero(0),
                M.equals(Int8Testable(0))
            ),
            test(
                "minus one",
                Int8.bitcountNonZero(-1),
                M.equals(Int8Testable(8))
            ),
            test(
                "minus two",
                Int8.bitcountNonZero(-2),
                M.equals(Int8Testable(7))
            ),
            test(
                "one",
                Int8.bitcountNonZero(1),
                M.equals(Int8Testable(1))
            ),
            test(
                "minimum value",
                Int8.bitcountNonZero(Int8.minimumValue),
                M.equals(Int8Testable(1))
            ),
            test(
                "maximum value",
                Int8.bitcountNonZero(Int8.maximumValue),
                M.equals(Int8Testable(7))
            ),
            test(
                "alternating bits positive",
                Int8.bitcountNonZero(0x55),
                M.equals(Int8Testable(4))
            ),
            test(
                "alternating bits negative",
                Int8.bitcountNonZero(-0x56),
                M.equals(Int8Testable(4))
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
                Int8.bitcountLeadingZero(0),
                M.equals(Int8Testable(8))
            ),
            test(
                "minus one",
                Int8.bitcountLeadingZero(-1),
                M.equals(Int8Testable(0))
            ),
            test(
                "minus two",
                Int8.bitcountLeadingZero(-2),
                M.equals(Int8Testable(0))
            ),
            test(
                "one",
                Int8.bitcountLeadingZero(1),
                M.equals(Int8Testable(7))
            ),
            test(
                "two",
                Int8.bitcountLeadingZero(2),
                M.equals(Int8Testable(6))
            ),
            test(
                "arbitrary",
                Int8.bitcountLeadingZero(0x10),
                M.equals(Int8Testable(3))
            ),
            test(
                "minimum value",
                Int8.bitcountLeadingZero(Int8.minimumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum value",
                Int8.bitcountLeadingZero(Int8.maximumValue),
                M.equals(Int8Testable(1))
            ),
            test(
                "alternating bits positive",
                Int8.bitcountLeadingZero(0x55),
                M.equals(Int8Testable(1))
            ),
            test(
                "alternating bits negative",
                Int8.bitcountLeadingZero(-0x56),
                M.equals(Int8Testable(0))
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
                Int8.bitcountTrailingZero(0),
                M.equals(Int8Testable(8))
            ),
            test(
                "minus one",
                Int8.bitcountTrailingZero(-1),
                M.equals(Int8Testable(0))
            ),
            test(
                "minus two",
                Int8.bitcountTrailingZero(-2),
                M.equals(Int8Testable(1))
            ),
            test(
                "one",
                Int8.bitcountTrailingZero(1),
                M.equals(Int8Testable(0))
            ),
            test(
                "two",
                Int8.bitcountTrailingZero(2),
                M.equals(Int8Testable(1))
            ),
            test(
                "arbitrary",
                Int8.bitcountTrailingZero(0x60),
                M.equals(Int8Testable(5))
            ),
            test(
                "minimum value",
                Int8.bitcountTrailingZero(Int8.minimumValue),
                M.equals(Int8Testable(7))
            ),
            test(
                "maximum value",
                Int8.bitcountTrailingZero(Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "alternating bits positive",
                Int8.bitcountTrailingZero(0x55),
                M.equals(Int8Testable(0))
            ),
            test(
                "alternating bits negative",
                Int8.bitcountTrailingZero(-0x56),
                M.equals(Int8Testable(1))
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
                Int8.addWrap(100, 23),
                M.equals(Int8Testable(123))
            ),
            test(
                "negative",
                Int8.addWrap(-100, -23),
                M.equals(Int8Testable(-123))
            ),
            test(
                "mixed signs",
                Int8.addWrap(-123, 23),
                M.equals(Int8Testable(-100))
            ),
            test(
                "zero",
                Int8.addWrap(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and maximum",
                Int8.addWrap(Int8.minimumValue, Int8.maximumValue),
                M.equals(Int8Testable(-1))
            ),
            test(
                "small overflow",
                Int8.addWrap(Int8.maximumValue, 1),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "large overflow",
                Int8.addWrap(Int8.maximumValue, Int8.maximumValue),
                M.equals(Int8Testable(-2))
            ),
            test(
                "small underflow",
                Int8.addWrap(Int8.minimumValue, -1),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "large underflow",
                Int8.addWrap(Int8.minimumValue, Int8.minimumValue),
                M.equals(Int8Testable(0))
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
                Int8.subWrap(123, 23),
                M.equals(Int8Testable(100))
            ),
            test(
                "negative",
                Int8.subWrap(-123, -23),
                M.equals(Int8Testable(-100))
            ),
            test(
                "mixed signs",
                Int8.subWrap(-100, 23),
                M.equals(Int8Testable(-123))
            ),
            test(
                "zero",
                Int8.subWrap(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "maximum and maximum",
                Int8.subWrap(Int8.maximumValue, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "small overflow",
                Int8.subWrap(Int8.maximumValue, -1),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "large overflow",
                Int8.subWrap(Int8.maximumValue, Int8.minimumValue),
                M.equals(Int8Testable(-1))
            ),
            test(
                "small underflow",
                Int8.subWrap(Int8.minimumValue, 1),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "large underflow",
                Int8.subWrap(Int8.minimumValue, Int8.maximumValue),
                M.equals(Int8Testable(1))
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
                Int8.mulWrap(12, 10),
                M.equals(Int8Testable(120))
            ),
            test(
                "negative",
                Int8.mulWrap(-12, -10),
                M.equals(Int8Testable(120))
            ),
            test(
                "mixed signs",
                Int8.mulWrap(-12, 10),
                M.equals(Int8Testable(-120))
            ),
            test(
                "zeros",
                Int8.mulWrap(0, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "zero and maximum",
                Int8.mulWrap(0, Int8.maximumValue),
                M.equals(Int8Testable(0))
            ),
            test(
                "minimum and zero",
                Int8.mulWrap(Int8.minimumValue, 0),
                M.equals(Int8Testable(0))
            ),
            test(
                "one and maximum",
                Int8.mulWrap(1, Int8.maximumValue),
                M.equals(Int8Testable(Int8.maximumValue))
            ),
            test(
                "minimum and one",
                Int8.mulWrap(Int8.minimumValue, 1),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "small overflow",
                Int8.mulWrap(2, Int8.maximumValue),
                M.equals(Int8Testable(-2))
            ),
            test(
                "large overflow",
                Int8.mulWrap(Int8.maximumValue, Int8.maximumValue),
                M.equals(Int8Testable(1))
            ),
            test(
                "small underflow",
                Int8.mulWrap(Int8.minimumValue, 2),
                M.equals(Int8Testable(0))
            ),
            test(
                "large underflow",
                Int8.mulWrap(Int8.minimumValue, Int8.minimumValue),
                M.equals(Int8Testable(0))
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
                Int8.powWrap(4, 3),
                M.equals(Int8Testable(64))
            ),
            test(
                "positive base, zero exponent",
                Int8.powWrap(12, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "negative base, positive exponent",
                Int8.powWrap(-4, 3),
                M.equals(Int8Testable(-64))
            ),
            test(
                "negative base, zero exponent",
                Int8.powWrap(-12, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "maximum and zero",
                Int8.powWrap(Int8.maximumValue, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "minimum and zero",
                Int8.powWrap(Int8.minimumValue, 0),
                M.equals(Int8Testable(1))
            ),
            test(
                "plus one and maximum",
                Int8.powWrap(1, Int8.maximumValue),
                M.equals(Int8Testable(1))
            ),
            test(
                "minus one and maximum",
                Int8.powWrap(-1, Int8.maximumValue),
                M.equals(Int8Testable(-1))
            ),
            test(
                "minimum value",
                Int8.powWrap(-2, 7),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "small overflow",
                Int8.powWrap(2, 7),
                M.equals(Int8Testable(Int8.minimumValue))
            ),
            test(
                "large overflow",
                Int8.powWrap(Int8.maximumValue, 2),
                M.equals(Int8Testable(1))
            ),
            test(
                "small underflow",
                Int8.powWrap(-2, 9),
                M.equals(Int8Testable(0))
            ),
            test(
                "large underflow",
                Int8.powWrap(Int8.minimumValue, 2),
                M.equals(Int8Testable(0))
            ),
        ]
    )
)
