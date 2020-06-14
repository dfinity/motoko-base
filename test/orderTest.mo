import Order "mo:base/Order";
import Prelude "mo:base/Prelude";

Prelude.debugPrintLine("Order");

{
  Prelude.debugPrintLine("  isLess");

  assert(Order.isLess(#less));
  assert(not Order.isLess(#equal));
  assert(not Order.isLess(#greater));
};

{
  Prelude.debugPrintLine("  isEqual");

  assert(not Order.isEqual(#less));
  assert(Order.isEqual(#equal));
  assert(not Order.isEqual(#greater));
};

{
  Prelude.debugPrintLine("  isGreater");

  assert(not Order.isGreater(#less));
  assert(not Order.isGreater(#equal));
  assert(Order.isGreater(#greater));
};
