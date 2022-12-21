import Int16 "mo:base/Int16";
import Order "mo:base/Order";
import Iter "mo:base/Iter";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let maximumInt16 = 32_767 : Int16;
let maximumInt16asInt = 32_767 : Int;
let maximumInt16asNat16 = 32_767 : Nat16;

let minimumInt16 = -32_768 : Int16;
let minimumInt16asInt = -32_768 : Int;

let maximumNat16 = 65_535 : Nat16;

class Int16Testable(number : Int16) : T.TestableItem<Int16> {
    public let item = number;
    public func display(number : Int16) : Text {
        debug_show (number)
    };
    public let equals = func(x : Int16, y : Int16) : Bool {
        x == y
    }
};

class Nat16Testable(number : Nat16) : T.TestableItem<Nat16> {
    public let item = number;
    public func display(number : Nat16) : Text {
        debug_show (number)
    };
    public let equals = func(x : Nat16, y : Nat16) : Bool {
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
                Int16.toInt(maximumInt16),
                M.equals(T.int(maximumInt16asInt))
            ),
            test(
                "minimum number",
                Int16.toInt(minimumInt16),
                M.equals(T.int(minimumInt16asInt))
            ),
            test(
                "one",
                Int16.toInt(1),
                M.equals(T.int(1))
            ),
            test(
                "minus one",
                Int16.toInt(-1),
                M.equals(T.int(-1))
            ),
            test(
                "zero",
                Int16.toInt(0),
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
                Int16.fromInt(maximumInt16asInt),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum number",
                Int16.fromInt(minimumInt16asInt),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "one",
                Int16.fromInt(1),
                M.equals(Int16Testable(1))
            ),
            test(
                "minus one",
                Int16.fromInt(-1),
                M.equals(Int16Testable(-1))
            ),
            test(
                "zero",
                Int16.fromInt(0),
                M.equals(Int16Testable(0))
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
                Int16.fromIntWrap(maximumInt16asInt),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum number",
                Int16.fromIntWrap(minimumInt16asInt),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "one",
                Int16.fromIntWrap(1),
                M.equals(Int16Testable(1))
            ),
            test(
                "minus one",
                Int16.fromIntWrap(-1),
                M.equals(Int16Testable(-1))
            ),
            test(
                "zero",
                Int16.fromIntWrap(0),
                M.equals(Int16Testable(0))
            ),
            test(
                "overflow",
                Int16.fromIntWrap(maximumInt16asInt + 1),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "underflow",
                Int16.fromIntWrap(minimumInt16asInt - 1),
                M.equals(Int16Testable(maximumInt16))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "fromNat16",
        [
            test(
                "maximum number",
                Int16.fromNat16(maximumInt16asNat16),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "one",
                Int16.fromNat16(1),
                M.equals(Int16Testable(1))
            ),
            test(
                "zero",
                Int16.fromNat16(0),
                M.equals(Int16Testable(0))
            ),
            test(
                "overflow",
                Int16.fromNat16(maximumInt16asNat16 + 1),
                M.equals(Int16Testable(minimumInt16))
            )
        ]
    )
);

/* --------------------------------------- */

run(
    suite(
        "toNat16",
        [
            test(
                "maximum number",
                Int16.toNat16(maximumInt16),
                M.equals(Nat16Testable(maximumInt16asNat16))
            ),
            test(
                "one",
                Int16.toNat16(1),
                M.equals(Nat16Testable(1))
            ),
            test(
                "zero",
                Int16.toNat16(0),
                M.equals(Nat16Testable(0))
            ),
            test(
                "underflow",
                Int16.toNat16(-1),
                M.equals(Nat16Testable(maximumNat16))
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
                Int16.toText(12345),
                M.equals(T.text("12345"))
            ),
            test(
                "negative",
                Int16.toText(-12345),
                M.equals(T.text("-12345"))
            ),
            test(
                "zero",
                Int16.toText(0),
                M.equals(T.text("0"))
            ),
            test(
                "maximum number",
                Int16.toText(maximumInt16),
                M.equals(T.text("32767"))
            ),
            test(
                "minimum number",
                Int16.toText(minimumInt16),
                M.equals(T.text("-32768"))
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
                Int16.abs(123),
                M.equals(Int16Testable(123))
            ),
            test(
                "negative number",
                Int16.abs(-123),
                M.equals(Int16Testable(123))
            ),
            test(
                "zero",
                Int16.abs(0),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum number",
                Int16.abs(maximumInt16),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "smallest possible",
                Int16.abs(-maximumInt16),
                M.equals(Int16Testable(maximumInt16))
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
                Int16.min(2, 3),
                M.equals(Int16Testable(2))
            ),
            test(
                "positive, negative",
                Int16.min(2, -3),
                M.equals(Int16Testable(-3))
            ),
            test(
                "both negative",
                Int16.min(-2, -3),
                M.equals(Int16Testable(-3))
            ),
            test(
                "negative, positive",
                Int16.min(-2, 3),
                M.equals(Int16Testable(-2))
            ),
            test(
                "equal values",
                Int16.min(123, 123),
                M.equals(Int16Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int16.min(maximumInt16, minimumInt16),
                M.equals(Int16Testable(minimumInt16))
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
                Int16.max(2, 3),
                M.equals(Int16Testable(3))
            ),
            test(
                "positive, negative",
                Int16.max(2, -3),
                M.equals(Int16Testable(2))
            ),
            test(
                "both negative",
                Int16.max(-2, -3),
                M.equals(Int16Testable(-2))
            ),
            test(
                "negative, positive",
                Int16.max(-2, 3),
                M.equals(Int16Testable(3))
            ),
            test(
                "equal values",
                Int16.max(123, 123),
                M.equals(Int16Testable(123))
            ),
            test(
                "maximum and minimum number",
                Int16.max(maximumInt16, minimumInt16),
                M.equals(Int16Testable(maximumInt16))
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
                Int16.equal(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int16.equal(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int16.equal(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "positive not equal",
                Int16.equal(123, 124),
                M.equals(T.bool(false))
            ),
            test(
                "negative not equal",
                Int16.equal(-123, -124),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs",
                Int16.equal(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "maxmimum equal",
                Int16.equal(maximumInt16, maximumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "minimum equal",
                Int16.equal(minimumInt16, minimumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int16.equal(minimumInt16, maximumInt16),
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
                Int16.notEqual(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int16.notEqual(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int16.notEqual(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "positive not equal",
                Int16.notEqual(123, 124),
                M.equals(T.bool(true))
            ),
            test(
                "negative not equal",
                Int16.notEqual(-123, -124),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs",
                Int16.notEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "maxmimum equal",
                Int16.notEqual(maximumInt16, maximumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "minimum equal",
                Int16.notEqual(minimumInt16, minimumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int16.notEqual(minimumInt16, maximumInt16),
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
                Int16.less(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int16.less(123, 245),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int16.less(245, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int16.less(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int16.less(-245, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int16.less(-123, -245),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int16.less(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int16.less(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int16.less(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int16.less(minimumInt16, maximumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int16.less(maximumInt16, minimumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int16.less(maximumInt16, maximumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int16.less(minimumInt16, minimumInt16),
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
                Int16.lessOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int16.lessOrEqual(123, 245),
                M.equals(T.bool(true))
            ),
            test(
                "positive greater",
                Int16.lessOrEqual(245, 123),
                M.equals(T.bool(false))
            ),
            test(
                "negative equal",
                Int16.lessOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int16.lessOrEqual(-245, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative greater",
                Int16.lessOrEqual(-123, -245),
                M.equals(T.bool(false))
            ),
            test(
                "zero",
                Int16.lessOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int16.lessOrEqual(-123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs greater",
                Int16.lessOrEqual(123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and maximum",
                Int16.lessOrEqual(minimumInt16, maximumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and minimum",
                Int16.lessOrEqual(maximumInt16, minimumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and maximum",
                Int16.lessOrEqual(maximumInt16, maximumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int16.lessOrEqual(minimumInt16, minimumInt16),
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
                Int16.greater(123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "positive less",
                Int16.greater(123, 245),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int16.greater(245, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int16.greater(-123, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative less",
                Int16.greater(-245, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int16.greater(-123, -245),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int16.greater(0, 0),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs less",
                Int16.greater(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int16.greater(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int16.greater(minimumInt16, maximumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int16.greater(maximumInt16, minimumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int16.greater(maximumInt16, maximumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "minimum and minimum",
                Int16.greater(minimumInt16, minimumInt16),
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
                Int16.greaterOrEqual(123, 123),
                M.equals(T.bool(true))
            ),
            test(
                "positive less",
                Int16.greaterOrEqual(123, 245),
                M.equals(T.bool(false))
            ),
            test(
                "positive greater",
                Int16.greaterOrEqual(245, 123),
                M.equals(T.bool(true))
            ),
            test(
                "negative equal",
                Int16.greaterOrEqual(-123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "negative less",
                Int16.greaterOrEqual(-245, -123),
                M.equals(T.bool(false))
            ),
            test(
                "negative greater",
                Int16.greaterOrEqual(-123, -245),
                M.equals(T.bool(true))
            ),
            test(
                "zero",
                Int16.greaterOrEqual(0, 0),
                M.equals(T.bool(true))
            ),
            test(
                "mixed signs less",
                Int16.greaterOrEqual(-123, 123),
                M.equals(T.bool(false))
            ),
            test(
                "mixed signs greater",
                Int16.greaterOrEqual(123, -123),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and maximum",
                Int16.greaterOrEqual(minimumInt16, maximumInt16),
                M.equals(T.bool(false))
            ),
            test(
                "maximum and minimum",
                Int16.greaterOrEqual(maximumInt16, minimumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "maximum and maximum",
                Int16.greaterOrEqual(maximumInt16, maximumInt16),
                M.equals(T.bool(true))
            ),
            test(
                "minimum and minimum",
                Int16.greaterOrEqual(minimumInt16, minimumInt16),
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
                Int16.compare(123, 123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "positive less",
                Int16.compare(123, 245),
                M.equals(OrderTestable(#less))
            ),
            test(
                "positive greater",
                Int16.compare(245, 123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "negative equal",
                Int16.compare(-123, -123),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "negative less",
                Int16.compare(-245, -123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "negative greater",
                Int16.compare(-123, -245),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "zero",
                Int16.compare(0, 0),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "mixed signs less",
                Int16.compare(-123, 123),
                M.equals(OrderTestable(#less))
            ),
            test(
                "mixed signs greater",
                Int16.compare(123, -123),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "minimum and maximum",
                Int16.compare(minimumInt16, maximumInt16),
                M.equals(OrderTestable(#less))
            ),
            test(
                "maximum and minimum",
                Int16.compare(maximumInt16, minimumInt16),
                M.equals(OrderTestable(#greater))
            ),
            test(
                "maximum and maximum",
                Int16.compare(maximumInt16, maximumInt16),
                M.equals(OrderTestable(#equal))
            ),
            test(
                "minimum and minimum",
                Int16.compare(minimumInt16, minimumInt16),
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
                Int16.neg(123),
                M.equals(Int16Testable(-123))
            ),
            test(
                "negative number",
                Int16.neg(-123),
                M.equals(Int16Testable(123))
            ),
            test(
                "zero",
                Int16.neg(0),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum number",
                Int16.neg(maximumInt16),
                M.equals(Int16Testable(-maximumInt16))
            ),
            test(
                "smallest possible",
                Int16.neg(-maximumInt16),
                M.equals(Int16Testable(maximumInt16))
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
                Int16.add(123, 123),
                M.equals(Int16Testable(246))
            ),
            test(
                "negative",
                Int16.add(-123, -123),
                M.equals(Int16Testable(-246))
            ),
            test(
                "mixed signs",
                Int16.add(-123, 223),
                M.equals(Int16Testable(100))
            ),
            test(
                "zero",
                Int16.add(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and maximum",
                Int16.add(minimumInt16, maximumInt16),
                M.equals(Int16Testable(-1))
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
                Int16.sub(123, 123),
                M.equals(Int16Testable(0))
            ),
            test(
                "negative",
                Int16.sub(-123, -123),
                M.equals(Int16Testable(0))
            ),
            test(
                "mixed signs",
                Int16.sub(-123, 223),
                M.equals(Int16Testable(-346))
            ),
            test(
                "zero",
                Int16.sub(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum and maximum",
                Int16.sub(maximumInt16, maximumInt16),
                M.equals(Int16Testable(0))
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
                Int16.mul(123, 234),
                M.equals(Int16Testable(28782))
            ),
            test(
                "negative",
                Int16.mul(-123, -234),
                M.equals(Int16Testable(28782))
            ),
            test(
                "mixed signs",
                Int16.mul(-123, 234),
                M.equals(Int16Testable(-28782))
            ),
            test(
                "zeros",
                Int16.mul(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and maximum",
                Int16.mul(0, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and zero",
                Int16.mul(minimumInt16, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "one and maximum",
                Int16.mul(1, maximumInt16),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum and one",
                Int16.mul(minimumInt16, 1),
                M.equals(Int16Testable(minimumInt16))
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
                Int16.div(156, 13),
                M.equals(Int16Testable(12))
            ),
            test(
                "positive remainder",
                Int16.div(1234, 100),
                M.equals(Int16Testable(12))
            ),
            test(
                "negative multiple",
                Int16.div(-156, -13),
                M.equals(Int16Testable(12))
            ),
            test(
                "negative remainder",
                Int16.div(-1234, -100),
                M.equals(Int16Testable(12))
            ),
            test(
                "mixed signs",
                Int16.div(-123, 23),
                M.equals(Int16Testable(-5))
            ),
            test(
                "zero and number",
                Int16.div(0, -123),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and maximum",
                Int16.div(0, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and minimum",
                Int16.div(0, minimumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum and maximum",
                Int16.div(maximumInt16, maximumInt16),
                M.equals(Int16Testable(1))
            ),
            test(
                "minimum and minimum",
                Int16.div(minimumInt16, minimumInt16),
                M.equals(Int16Testable(1))
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
                Int16.rem(156, 13),
                M.equals(Int16Testable(0))
            ),
            test(
                "positive/positive remainder",
                Int16.rem(1234, 100),
                M.equals(Int16Testable(34))
            ),
            test(
                "positive/negative remainder",
                Int16.rem(1234, -100),
                M.equals(Int16Testable(34))
            ),
            test(
                "negative multiple",
                Int16.rem(-156, -13),
                M.equals(Int16Testable(0))
            ),
            test(
                "negative/positive remainder",
                Int16.rem(-1234, 100),
                M.equals(Int16Testable(-34))
            ),
            test(
                "negative/negative remainder",
                Int16.rem(-1234, -100),
                M.equals(Int16Testable(-34))
            ),
            test(
                "zero and maximum",
                Int16.rem(0, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and minimum",
                Int16.rem(0, minimumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum and maximum",
                Int16.rem(maximumInt16, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and minimum",
                Int16.rem(minimumInt16, minimumInt16),
                M.equals(Int16Testable(0))
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
                Int16.pow(24, 3),
                M.equals(Int16Testable(13824))
            ),
            test(
                "positive base, zero exponent",
                Int16.pow(24, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "negative base, positive exponent",
                Int16.pow(-24, 3),
                M.equals(Int16Testable(-13824))
            ),
            test(
                "negative base, zero exponent",
                Int16.pow(-24, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "maximum and zero",
                Int16.pow(maximumInt16, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "minimum and zero",
                Int16.pow(minimumInt16, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "plus one and maximum",
                Int16.pow(1, maximumInt16),
                M.equals(Int16Testable(1))
            ),
            test(
                "minus one and maximum",
                Int16.pow(-1, maximumInt16),
                M.equals(Int16Testable(-1))
            )
        ]
    )
);

/* --------------------------------------- */

let unused = 0 : Int16; // Issue: bitnot has superfluous second argument.

run(
    suite(
        "bitnot",
        [
            test(
                "zero",
                Int16.bitnot(0, unused),
                M.equals(Int16Testable(-1))
            ),
            test(
                "minus 1",
                Int16.bitnot(-1, unused),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum",
                Int16.bitnot(maximumInt16, unused),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "minimum",
                Int16.bitnot(minimumInt16, unused),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "arbitrary",
                Int16.bitnot(1234, 0),
                M.equals(Int16Testable(-1235))
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
                Int16.bitand(0x70f0, 0x0f0f),
                M.equals(Int16Testable(0))
            ),
            test(
                "overlap",
                Int16.bitand(0x0ff0, 0x7fff),
                M.equals(Int16Testable(0xff0))
            ),
            test(
                "arbitrary",
                Int16.bitand(0x1234, 0x7654),
                M.equals(Int16Testable(0x1214))
            ),
            test(
                "negative",
                Int16.bitand(-123, -123),
                M.equals(Int16Testable(-123))
            ),
            test(
                "mixed signs",
                Int16.bitand(-256, 255),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero",
                Int16.bitand(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and maximum",
                Int16.bitand(0, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and zero",
                Int16.bitand(minimumInt16, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and maximum",
                Int16.bitand(minimumInt16, maximumInt16),
                M.equals(Int16Testable(0))
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
                Int16.bitor(0x70f0, 0x0f0f),
                M.equals(Int16Testable(0x7fff))
            ),
            test(
                "overlap",
                Int16.bitor(0x0ff0, 0x7fff),
                M.equals(Int16Testable(0x7fff))
            ),
            test(
                "arbitrary",
                Int16.bitor(0x1234, 0x7654),
                M.equals(Int16Testable(0x7674))
            ),
            test(
                "negative",
                Int16.bitor(-123, -123),
                M.equals(Int16Testable(-123))
            ),
            test(
                "mixed signs",
                Int16.bitor(-256, 255),
                M.equals(Int16Testable(-1))
            ),
            test(
                "zero",
                Int16.bitor(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and maximum",
                Int16.bitor(0, maximumInt16),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum and zero",
                Int16.bitor(minimumInt16, 0),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "minimum and maximum",
                Int16.bitor(minimumInt16, maximumInt16),
                M.equals(Int16Testable(-1))
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
                Int16.bitxor(0x70f0, 0x0f0f),
                M.equals(Int16Testable(0x7fff))
            ),
            test(
                "overlap",
                Int16.bitxor(0x0ff0, 0x7fff),
                M.equals(Int16Testable(0x700f))
            ),
            test(
                "arbitrary",
                Int16.bitxor(0x1234, 0x7654),
                M.equals(Int16Testable(0x6460))
            ),
            test(
                "negative",
                Int16.bitxor(-123, -123),
                M.equals(Int16Testable(0))
            ),
            test(
                "mixed signs",
                Int16.bitxor(-256, 255),
                M.equals(Int16Testable(-1))
            ),
            test(
                "zero",
                Int16.bitxor(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and maximum",
                Int16.bitxor(0, maximumInt16),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum and zero",
                Int16.bitxor(minimumInt16, 0),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "minimum and maximum",
                Int16.bitxor(minimumInt16, maximumInt16),
                M.equals(Int16Testable(-1))
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
                Int16.bitshiftLeft(0x70f1, 4),
                M.equals(Int16Testable(0x0f10))
            ),
            test(
                "negative number",
                Int16.bitshiftLeft(-256, 4),
                M.equals(Int16Testable(-4096))
            ),
            test(
                "arbitrary",
                Int16.bitshiftLeft(1234, 7),
                M.equals(Int16Testable(26_880))
            ),
            test(
                "zero shift",
                Int16.bitshiftLeft(1234, 0),
                M.equals(Int16Testable(1234))
            ),
            test(
                "one maximum shift",
                Int16.bitshiftLeft(1, 15),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "minimum number",
                Int16.bitshiftLeft(-1, 15),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "discard overflow",
                Int16.bitshiftLeft(0x7fff, 8),
                M.equals(Int16Testable(-256))
            ),
            test(
                "beyond bit length positive",
                Int16.bitshiftLeft(0x1234, 32 + 7),
                M.equals(Int16Testable(Int16.bitshiftLeft(0x1234, 7)))
            ),
            test(
                "beyond bit length negative",
                Int16.bitshiftLeft(-0x1234, 16 + 7),
                M.equals(Int16Testable(Int16.bitshiftLeft(-0x1234, 7)))
            ),
            test(
                "negative shift argument",
                Int16.bitshiftLeft(0x1234, -7),
                M.equals(Int16Testable(Int16.bitshiftLeft(0x1234, 16 - 7)))
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
                Int16.bitshiftRight(0x70f1, 4),
                M.equals(Int16Testable(0x070f))
            ),
            test(
                "negative number",
                Int16.bitshiftRight(-256, 4),
                M.equals(Int16Testable(-16))
            ),
            test(
                "arbitrary",
                Int16.bitshiftRight(1234, 7),
                M.equals(Int16Testable(9))
            ),
            test(
                "zero shift",
                Int16.bitshiftRight(1234, 0),
                M.equals(Int16Testable(1234))
            ),
            test(
                "minus one maximum shift",
                Int16.bitshiftRight(-1, 15),
                M.equals(Int16Testable(-1))
            ),
            test(
                "minimum number",
                Int16.bitshiftRight(minimumInt16, 15),
                M.equals(Int16Testable(-1))
            ),
            test(
                "discard underflow",
                Int16.bitshiftRight(0x00ff, 8),
                M.equals(Int16Testable(0))
            ),
            test(
                "beyond bit length positive",
                Int16.bitshiftRight(0x1234, 32 + 7),
                M.equals(Int16Testable(Int16.bitshiftRight(0x1234, 7)))
            ),
            test(
                "beyond bit length negative",
                Int16.bitshiftRight(-0x1234, 16 + 7),
                M.equals(Int16Testable(Int16.bitshiftRight(-0x1234, 7)))
            ),
            test(
                "negative shift argument",
                Int16.bitshiftRight(0x1234, -7),
                M.equals(Int16Testable(Int16.bitshiftRight(0x1234, 16 - 7)))
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
                Int16.bitrotLeft(0x70f0, 4),
                M.equals(Int16Testable(0x0f07))
            ),
            test(
                "positive number overflow",
                Int16.bitrotLeft(0x3412, 8),
                M.equals(Int16Testable(0x1234))
            ),
            test(
                "negative number",
                Int16.bitrotLeft(-256, 4),
                M.equals(Int16Testable(-4081))
            ),
            test(
                "arbitrary",
                Int16.bitrotLeft(12_345, 7),
                M.equals(Int16Testable(7_320))
            ),
            test(
                "zero shift",
                Int16.bitrotLeft(1234, 0),
                M.equals(Int16Testable(1234))
            ),
            test(
                "minus one maximum rotate",
                Int16.bitrotLeft(-1, 15),
                M.equals(Int16Testable(-1))
            ),
            test(
                "maximum number",
                Int16.bitrotLeft(maximumInt16, 1),
                M.equals(Int16Testable(-2))
            ),
            test(
                "minimum number",
                Int16.bitrotLeft(1, 15),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "opposite rotation",
                Int16.bitrotLeft(256, -2),
                M.equals(Int16Testable(64))
            ),
            test(
                "rotate beyond bit length",
                Int16.bitrotLeft(128, 18),
                M.equals(Int16Testable(512))
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
                Int16.bitrotRight(0x70f0, 4),
                M.equals(Int16Testable(0x070f))
            ),
            test(
                "positive number underflow",
                Int16.bitrotRight(0x3412, 8),
                M.equals(Int16Testable(0x1234))
            ),
            test(
                "negative number",
                Int16.bitrotRight(-256, 8),
                M.equals(Int16Testable(255))
            ),
            test(
                "arbitrary",
                Int16.bitrotRight(12_345, 7),
                M.equals(Int16Testable(29_280))
            ),
            test(
                "zero shift",
                Int16.bitrotRight(1234, 0),
                M.equals(Int16Testable(1234))
            ),
            test(
                "minus one maximum rotate",
                Int16.bitrotRight(-1, 15),
                M.equals(Int16Testable(-1))
            ),
            test(
                "maximum number",
                Int16.bitrotRight(-2, 1),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum number",
                Int16.bitrotRight(minimumInt16, 15),
                M.equals(Int16Testable(1))
            ),
            test(
                "opposite rotation",
                Int16.bitrotRight(256, -2),
                M.equals(Int16Testable(1024))
            ),
            test(
                "rotate beyond bit length",
                Int16.bitrotRight(128, 18),
                M.equals(Int16Testable(32))
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
                Int16.bittest(128, 7),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit",
                Int16.bittest(-129, 7),
                M.equals(T.bool(false))
            ),
            test(
                "all zero",
                do {
                    let number = 0 : Int16;
                    var count = 0;
                    for (index in Iter.range(0, 15)) {
                        if (Int16.bittest(number, index)) {
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
                    let number = -1 : Int16;
                    var count = 0;
                    for (index in Iter.range(0, 15)) {
                        if (Int16.bittest(number, index)) {
                            count += 1
                        }
                    };
                    count
                },
                M.equals(T.int(16))
            ),
            test(
                "set bit beyond bit length",
                Int16.bittest(128, 16 + 7),
                M.equals(T.bool(true))
            ),
            test(
                "cleared bit beyond bit length",
                Int16.bittest(-129, 32 + 7),
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
                Int16.bitset(0, 7),
                M.equals(Int16Testable(128))
            ),
            test(
                "minus one",
                Int16.bitset(-129, 7),
                M.equals(Int16Testable(-1))
            ),
            test(
                "no effect",
                Int16.bitset(128, 7),
                M.equals(Int16Testable(128))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int16;
                    for (index in Iter.range(0, 15)) {
                        number := Int16.bitset(number, index)
                    };
                    number
                },
                M.equals(Int16Testable(-1))
            ),
            test(
                "all no effect",
                do {
                    var number = -1 : Int16;
                    for (index in Iter.range(0, 15)) {
                        number := Int16.bitset(number, index)
                    };
                    number
                },
                M.equals(Int16Testable(-1))
            ),
            test(
                "set bit beyond bit length",
                Int16.bitset(0, 16 + 7),
                M.equals(Int16Testable(128))
            ),
            test(
                "minus one beyond bit length",
                Int16.bitset(-129, 32 + 7),
                M.equals(Int16Testable(-1))
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
                Int16.bitclear(128, 7),
                M.equals(Int16Testable(0))
            ),
            test(
                "minus one",
                Int16.bitclear(-1, 7),
                M.equals(Int16Testable(-129))
            ),
            test(
                "no effect",
                Int16.bitclear(0, 7),
                M.equals(Int16Testable(0))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int16;
                    for (index in Iter.range(0, 15)) {
                        number := Int16.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int16Testable(0))
            ),
            test(
                "all no effect",
                do {
                    var number = 0 : Int16;
                    for (index in Iter.range(0, 15)) {
                        number := Int16.bitclear(number, index)
                    };
                    number
                },
                M.equals(Int16Testable(0))
            ),
            test(
                "clear bit beyond bit length",
                Int16.bitclear(128, 16 + 7),
                M.equals(Int16Testable(0))
            ),
            test(
                "minus one beyond bit length",
                Int16.bitclear(-1, 32 + 7),
                M.equals(Int16Testable(-129))
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
                Int16.bitflip(255, 7),
                M.equals(Int16Testable(127))
            ),
            test(
                "set bit",
                Int16.bitflip(127, 7),
                M.equals(Int16Testable(255))
            ),
            test(
                "double flip",
                Int16.bitflip(Int16.bitflip(0x1234, 13), 13),
                M.equals(Int16Testable(0x1234))
            ),
            test(
                "clear all",
                do {
                    var number = -1 : Int16;
                    for (index in Iter.range(0, 15)) {
                        number := Int16.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int16Testable(0))
            ),
            test(
                "set all",
                do {
                    var number = 0 : Int16;
                    for (index in Iter.range(0, 15)) {
                        number := Int16.bitflip(number, index)
                    };
                    number
                },
                M.equals(Int16Testable(-1))
            ),
            test(
                "clear bit beyond bit length",
                Int16.bitflip(255, 16 + 7),
                M.equals(Int16Testable(127))
            ),
            test(
                "set bit beyond bit length",
                Int16.bitflip(127, 32 + 7),
                M.equals(Int16Testable(255))
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
                Int16.bitcountNonZero(0),
                M.equals(Int16Testable(0))
            ),
            test(
                "minus one",
                Int16.bitcountNonZero(-1),
                M.equals(Int16Testable(16))
            ),
            test(
                "minus two",
                Int16.bitcountNonZero(-2),
                M.equals(Int16Testable(15))
            ),
            test(
                "one",
                Int16.bitcountNonZero(1),
                M.equals(Int16Testable(1))
            ),
            test(
                "minimum value",
                Int16.bitcountNonZero(minimumInt16),
                M.equals(Int16Testable(1))
            ),
            test(
                "maximum value",
                Int16.bitcountNonZero(maximumInt16),
                M.equals(Int16Testable(15))
            ),
            test(
                "alternating bits positive",
                Int16.bitcountNonZero(0x5555),
                M.equals(Int16Testable(8))
            ),
            test(
                "alternating bits negative",
                Int16.bitcountNonZero(-0x5556),
                M.equals(Int16Testable(8))
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
                Int16.bitcountLeadingZero(0),
                M.equals(Int16Testable(16))
            ),
            test(
                "minus one",
                Int16.bitcountLeadingZero(-1),
                M.equals(Int16Testable(0))
            ),
            test(
                "minus two",
                Int16.bitcountLeadingZero(-2),
                M.equals(Int16Testable(0))
            ),
            test(
                "one",
                Int16.bitcountLeadingZero(1),
                M.equals(Int16Testable(15))
            ),
            test(
                "two",
                Int16.bitcountLeadingZero(2),
                M.equals(Int16Testable(14))
            ),
            test(
                "arbitrary",
                Int16.bitcountLeadingZero(0x0010),
                M.equals(Int16Testable(11))
            ),
            test(
                "minimum value",
                Int16.bitcountLeadingZero(minimumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum value",
                Int16.bitcountLeadingZero(maximumInt16),
                M.equals(Int16Testable(1))
            ),
            test(
                "alternating bits positive",
                Int16.bitcountLeadingZero(0x5555),
                M.equals(Int16Testable(1))
            ),
            test(
                "alternating bits negative",
                Int16.bitcountLeadingZero(-0x5556),
                M.equals(Int16Testable(0))
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
                Int16.bitcountTrailingZero(0),
                M.equals(Int16Testable(16))
            ),
            test(
                "minus one",
                Int16.bitcountTrailingZero(-1),
                M.equals(Int16Testable(0))
            ),
            test(
                "minus two",
                Int16.bitcountTrailingZero(-2),
                M.equals(Int16Testable(1))
            ),
            test(
                "one",
                Int16.bitcountTrailingZero(1),
                M.equals(Int16Testable(0))
            ),
            test(
                "two",
                Int16.bitcountTrailingZero(2),
                M.equals(Int16Testable(1))
            ),
            test(
                "arbitrary",
                Int16.bitcountTrailingZero(0x5060),
                M.equals(Int16Testable(5))
            ),
            test(
                "minimum value",
                Int16.bitcountTrailingZero(minimumInt16),
                M.equals(Int16Testable(15))
            ),
            test(
                "maximum value",
                Int16.bitcountTrailingZero(maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "alternating bits positive",
                Int16.bitcountTrailingZero(0x5555),
                M.equals(Int16Testable(0))
            ),
            test(
                "alternating bits negative",
                Int16.bitcountTrailingZero(-0x5556),
                M.equals(Int16Testable(1))
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
                Int16.addWrap(123, 123),
                M.equals(Int16Testable(246))
            ),
            test(
                "negative",
                Int16.addWrap(-123, -123),
                M.equals(Int16Testable(-246))
            ),
            test(
                "mixed signs",
                Int16.addWrap(-123, 223),
                M.equals(Int16Testable(100))
            ),
            test(
                "zero",
                Int16.addWrap(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and maximum",
                Int16.addWrap(minimumInt16, maximumInt16),
                M.equals(Int16Testable(-1))
            ),
            test(
                "small overflow",
                Int16.addWrap(maximumInt16, 1),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "large overflow",
                Int16.addWrap(maximumInt16, maximumInt16),
                M.equals(Int16Testable(-2))
            ),
            test(
                "small underflow",
                Int16.addWrap(minimumInt16, -1),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "large underflow",
                Int16.addWrap(minimumInt16, minimumInt16),
                M.equals(Int16Testable(0))
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
                Int16.subWrap(123, 123),
                M.equals(Int16Testable(0))
            ),
            test(
                "negative",
                Int16.subWrap(-123, -123),
                M.equals(Int16Testable(0))
            ),
            test(
                "mixed signs",
                Int16.subWrap(-123, 223),
                M.equals(Int16Testable(-346))
            ),
            test(
                "zero",
                Int16.subWrap(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "maximum and maximum",
                Int16.subWrap(maximumInt16, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "small overflow",
                Int16.subWrap(maximumInt16, -1),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "large overflow",
                Int16.subWrap(maximumInt16, minimumInt16),
                M.equals(Int16Testable(-1))
            ),
            test(
                "small underflow",
                Int16.subWrap(minimumInt16, 1),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "large underflow",
                Int16.subWrap(minimumInt16, maximumInt16),
                M.equals(Int16Testable(1))
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
                Int16.mulWrap(123, 234),
                M.equals(Int16Testable(28782))
            ),
            test(
                "negative",
                Int16.mulWrap(-123, -234),
                M.equals(Int16Testable(28782))
            ),
            test(
                "mixed signs",
                Int16.mulWrap(-123, 234),
                M.equals(Int16Testable(-28782))
            ),
            test(
                "zeros",
                Int16.mulWrap(0, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "zero and maximum",
                Int16.mulWrap(0, maximumInt16),
                M.equals(Int16Testable(0))
            ),
            test(
                "minimum and zero",
                Int16.mulWrap(minimumInt16, 0),
                M.equals(Int16Testable(0))
            ),
            test(
                "one and maximum",
                Int16.mulWrap(1, maximumInt16),
                M.equals(Int16Testable(maximumInt16))
            ),
            test(
                "minimum and one",
                Int16.mulWrap(minimumInt16, 1),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "small overflow",
                Int16.mulWrap(2, maximumInt16),
                M.equals(Int16Testable(-2))
            ),
            test(
                "large overflow",
                Int16.mulWrap(maximumInt16, maximumInt16),
                M.equals(Int16Testable(1))
            ),
            test(
                "small underflow",
                Int16.mulWrap(minimumInt16, 2),
                M.equals(Int16Testable(0))
            ),
            test(
                "large underflow",
                Int16.mulWrap(minimumInt16, minimumInt16),
                M.equals(Int16Testable(0))
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
                Int16.powWrap(24, 3),
                M.equals(Int16Testable(13824))
            ),
            test(
                "positive base, zero exponent",
                Int16.powWrap(24, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "negative base, positive exponent",
                Int16.powWrap(-24, 3),
                M.equals(Int16Testable(-13824))
            ),
            test(
                "negative base, zero exponent",
                Int16.powWrap(-24, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "maximum and zero",
                Int16.powWrap(maximumInt16, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "minimum and zero",
                Int16.powWrap(minimumInt16, 0),
                M.equals(Int16Testable(1))
            ),
            test(
                "plus one and maximum",
                Int16.powWrap(1, maximumInt16),
                M.equals(Int16Testable(1))
            ),
            test(
                "minus one and maximum",
                Int16.powWrap(-1, maximumInt16),
                M.equals(Int16Testable(-1))
            ),
            test(
                "minimum value",
                Int16.powWrap(-2, 15),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "small overflow",
                Int16.powWrap(2, 15),
                M.equals(Int16Testable(minimumInt16))
            ),
            test(
                "large overflow",
                Int16.powWrap(maximumInt16, 10),
                M.equals(Int16Testable(1))
            ),
            test(
                "small underflow",
                Int16.powWrap(-2, 17),
                M.equals(Int16Testable(0))
            ),
            test(
                "large underflow",
                Int16.powWrap(minimumInt16, 10),
                M.equals(Int16Testable(0))
            ),
        ]
    )
)
