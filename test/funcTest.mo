import Function "mo:base/Func";
import Debug "mo:base/Debug";
import Text "mo:base/Text";

import { run; test; suite } "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

Debug.print("Function");

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

do {
  Debug.print("  const");

  assert (Function.const<Bool, Text>(true)("abc"));
  assert (Function.const<Bool, Text>(false)("abc") == false);
  assert (Function.const<Bool, (Text, Text)>(false)("abc", "abc") == false)
}
