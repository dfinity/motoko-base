import Debug "mo:base/Debug";
import I "mo:base/Iter";
import Random "mo:base/Random";

//import R "randomActor";

import Suite "mo:matchers/Suite";
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

let {run;test;suite} = Suite;

Debug.print("Random");


let s = suite("My test suite", [
    suite("Nat tests", [
        test("10 is 10", 10, M.equals(T.nat(10))),
        test("5 is greater than three", 5, M.greaterThan<Nat>(3)),
    ])
]);
run(s)
