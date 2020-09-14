import Debug "mo:base/Debug";
import I "mo:base/Iter";
import Random "mo:base/Random";

import Suite "mo:matchers/Suite";
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let {run;test;suite} = Suite;

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

actor R {
    let it = C.Tester({ batchSize = 8 });
    public shared func test() : async Text {

      it.should("see a coin head", func () : async C.TestResult = async {
        let c = await testRandomCoin();
        M.attempt(c, M.equals(T.bool(true)))
      });

      await it.runAll()
    }
};


let s = suite("My test suite", [
    suite("Nat tests", [
        test("10 is 10", 10, M.equals(T.nat(10))),
        test("5 is greater than three", 5, M.greaterThan<Nat>(3)),
    ])
]);
run(s)
