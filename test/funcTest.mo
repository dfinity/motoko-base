import Function "mo:base/Func";
import Debug "mo:base/Debug";
import Text "mo:base/Text";

Debug.print("Function");

do {
  Debug.print("  compose");

  func isEven(x : Int) : Bool { x % 2 == 0; };
  func not_(x : Bool) : Bool { not x; };
  let isOdd = Function.compose<Int, Bool, Bool>(not_, isEven);

  assert(isOdd(0) == false);
  assert(isOdd(1));
};

do {
  Debug.print("  const");

  assert(Function.const<Bool, Text>(true)("abc"));
  assert(Function.const<Bool, Text>(false)("abc") == false);
  assert(Function.const<Bool, (Text, Text)>(false)("abc", "abc") == false);
};
