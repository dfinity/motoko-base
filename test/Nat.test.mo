import Debug "../src/Debug";
import Nat "../src/Nat";

Debug.print("Nat");

do {
  Debug.print("  add");

  assert (Nat.add(1, Nat.add(2, 3)) == Nat.add(1, Nat.add(2, 3)));
  assert (Nat.add(0, 1) == 1);
  assert (1 == Nat.add(1, 0));
  assert (Nat.add(0, 1) == Nat.add(1, 0));
  assert (Nat.add(1, 2) == Nat.add(2, 1))
};

do {
  Debug.print("  shift");

  assert (Nat.bitshiftLeft(1234567890, 3) == 1234567890 * 8);
  assert (Nat.bitshiftRight(1234567892, 2) == 1234567892 / 4);
};

do {
  Debug.print("  toText");

  assert (Nat.toText(0) == "0");
  assert (Nat.toText(1234) == "1234")
}
