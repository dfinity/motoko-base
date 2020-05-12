import Ord "mo:base/Ord";
import Prelude "mo:base/Prelude";

Prelude.printLn("Ord");

{
  Prelude.printLn("  isLT");

  assert(Ord.isLT(#lt));
  assert(not Ord.isLT(#eq));
  assert(not Ord.isLT(#gt));
};

{
  Prelude.printLn("  isEQ");

  assert(not Ord.isEQ(#lt));
  assert(Ord.isEQ(#eq));
  assert(not Ord.isEQ(#gt));
};

{
  Prelude.printLn("  isGT");

  assert(not Ord.isGT(#lt));
  assert(not Ord.isGT(#eq));
  assert(Ord.isGT(#gt));
};
