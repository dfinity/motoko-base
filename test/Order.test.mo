import Order "../src/Order";
import Debug "../src/Debug";

Debug.print("Order");

do {
  Debug.print("  isLess");

  assert (Order.isLess(#less));
  assert (not Order.isLess(#equal));
  assert (not Order.isLess(#greater))
};

do {
  Debug.print("  isEqual");

  assert (not Order.isEqual(#less));
  assert (Order.isEqual(#equal));
  assert (not Order.isEqual(#greater))
};

do {
  Debug.print("  isGreater");

  assert (not Order.isGreater(#less));
  assert (not Order.isGreater(#equal));
  assert (Order.isGreater(#greater))
}
