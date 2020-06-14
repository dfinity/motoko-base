import Order "mo:base/Order";
import Prelude "mo:base/Prelude";

Prelude.printLn("Order");

{
  Prelude.printLn("  isLess");

  assert(Order.isLess(#less));
  assert(not Order.isLess(#equal));
  assert(not Order.isLess(#greater));
};

{
  Prelude.printLn("  isEqual");

  assert(not Order.isEqual(#less));
  assert(Order.isEqual(#equal));
  assert(not Order.isEqual(#greater));
};

{
  Prelude.printLn("  isGreater");

  assert(not Order.isGreater(#less));
  assert(not Order.isGreater(#equal));
  assert(Order.isGreater(#greater));
};
