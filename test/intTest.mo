import Debug "mo:base/Debug";
import Int "mo:base/Int";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let largeNumber = +123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000_123_456_789_000;
let largeNumberText = "123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000123456789000";

/* --------------------------------------- */

run(
  suite(
    "abs",
    [
      test(
        "positive number",
        Int.abs(+123),
        M.equals(T.int(+123))
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
        Int.toText(+1234567890),
        M.equals(T.text("1234567890"))
      ),
      test(
        "positive number",
        Int.toText(+1234),
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
        Int.min(+2, +3),
        M.equals(T.int(+2))
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
        Int.min(-2, +3),
        M.equals(T.int(-2))
      ),
      test(
        "equal values",
        Int.min(+123, +123),
        M.equals(T.int(+123))
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
        Int.max(+2, +3),
        M.equals(T.int(+3))
      ),
      test(
        "positive, negative",
        Int.max(+2, -3),
        M.equals(T.int(+2))
      ),
      test(
        "both negative",
        Int.max(-2, -3),
        M.equals(T.int(-2))
      ),
      test(
        "negative, positive",
        Int.max(-2, +3),
        M.equals(T.int(+3))
      ),
      test(
        "equal values",
        Int.max(+123, +123),
        M.equals(T.int(+123))
      ),
      test(
        "large numbers",
        Int.max(largeNumber, largeNumber + 1),
        M.equals(T.int(largeNumber + 1))
      )
    ]
  )
);

// Debug.print("Int");

// do {
//   Debug.print("  add");

//   assert (Int.add(1, Int.add(2, 3)) == Int.add(1, Int.add(2, 3)));
//   assert (Int.add(0, 1) == 1);
//   assert (1 == Int.add(1, 0));
//   assert (Int.add(0, 1) == Int.add(1, 0));
//   assert (Int.add(1, 2) == Int.add(2, 1))
// };

// do {
//   Debug.print("  toText");

//   assert (Int.toText(0) == "0");
//   assert (Int.toText(-0) == "0");
//   assert (Int.toText(1234) == "1234");
//   assert (Int.toText(-1234) == "-1234")
// }
