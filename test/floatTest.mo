import Debug "mo:base/Debug";
import Float "mo:base/Float";

Debug.print("Float");

{
  Debug.print("  abs");

  assert(Float.abs(1.1) == 1.1);
  assert(Float.abs(-1.1) == 1.1);
};

{
  Debug.print("  ceil");

  assert(Float.ceil(1.1) == 2.0);
};

{
  Debug.print("  floor");

  assert(Float.floor(1.1) == 1.0);
};

{
  Debug.print("  trunc");

  assert(Float.trunc(1.0012345789) == 1.0);
};

{
  Debug.print("  nearest");

  assert(Float.nearest(1.00001) == 1.0);
  assert(Float.nearest(1.99999) == 2.0);
};

{
  Debug.print("  min");

  assert(Float.min(1.1, 2.2) == 1.1);
};

{
  Debug.print("  max");

  assert(Float.max(1.1, 2.2) == 2.2);
};

{
  Debug.print("  sin");

  assert(Float.sin(0.0) == 0.0);
};

{
  Debug.print("  cos");

  assert(Float.cos(0.0) == 1.0);
};

{
  Debug.print("  toFloat64");

  assert(Float.toInt64(1e10) == (10000000000 : Int64));
  assert(Float.toInt64(-1e10) == (-10000000000 : Int64));
};

{
  Debug.print("  ofFloat64");

  assert(Float.fromInt64(10000000000) == 1e10);
  assert(Float.fromInt64(-10000000000) == -1e10);
};


{
  Debug.print("  format");

  assert(Float.format(#exact, 20.12345678901) == "20.12345678901");
  assert(Float.format(#fix 6, 20.12345678901) == "20.123457");
  assert(Float.format(#exp 9, 20.12345678901) == "2.012345679e+01");
  assert(Float.format(#gen 12, 20.12345678901) == "20.123456789");
  assert(Float.format(#hex 10, 20.12345678901) == "0x1.41f9add374p+4");
};


{
  Debug.print("  Pi: " # Float.toText(Float.pi));
  Debug.print("  arccos(-1.0): " # Float.toText(Float.arccos(-1.)));

  assert(Float.pi == Float.arccos(-1.));
};

{
  Debug.print("  e: " # debug_show(Float.toText(Float.e)));
  Debug.print("  exp(1): " # debug_show(Float.toText(Float.exp(1))));

  assert(Float.e == Float.exp(1));
};
