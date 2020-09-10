import Debug "mo:base/Debug";
import I "mo:base/Iter";
import Random "mo:base/Random";

Debug.print("Random");

func testRandomByte () : async Bool = async {
  Debug.print("  byte");

  let b = await Random.byte();
  for (i in I.range(0, 1000)) {
      let bi = await Random.byte();
      if (bi != b) { return true }
  };
  return false
};

func testRandomCoin () : async Bool = async {
  Debug.print("  coin");

  let c = await Random.coin();
  for (i in I.range(0, 1000)) {
      let ci = await Random.coin();
      if (ci != c) { return true }
  };
  return false
};
