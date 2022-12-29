import Function "mo:base/Func";
import { print } = "mo:base/Debug";
import Text "mo:base/Text";

import { run; test; suite } "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

print("Function");

func isEven(x : Int) : Bool { x % 2 == 0 };
func not_(x : Bool) : Bool { not x };
let isOdd = Function.compose<Int, Bool, Bool>(not_, isEven);

/* --------------------------------------- */

run(
  suite(
    "compose",
    [
      test(
        "not even is odd",
        isOdd(0),
        M.equals(T.bool(false))
      ),
      test(
        "one is odd",
        isOdd(1),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

run(
  suite(
    "const",
    [
      test(
        "abc is ignored",
        Function.const<Bool, Text>(true)("abc"),
        M.equals(T.bool(true))
      ),
      test(
        "same for flipped const",
        Function.const<Bool, Text>(false)("abc"),
        M.equals(T.bool(false))
      ),
      test(
        "same for structured ignoree",
        Function.const<Bool, (Text, Text)>(false)("abc", "abc"),
        M.equals(T.bool(false))
      )
    ]
  )
);

/* --------------------------------------- */
