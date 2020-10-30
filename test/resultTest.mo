import Result "mo:base/Result";
import Int "mo:base/Int";
import Array "mo:base/Array";
import List "mo:base/List";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

func makeNatural(x : Int) : Result.Result<Nat, Text> =
  if (x >= 0) { #ok(Int.abs(x)) } else { #err(Int.toText(x) # " is not a natural number.") };

func largerThan10(x : Nat) : Result.Result<Nat, Text> =
  if (x > 10) { #ok(x) } else { #err(Int.toText(x) # " is not larger than 10.") };

let chain = Suite.suite("chain", [
  Suite.test("ok -> ok",
    Result.chain<Nat, Nat, Text>(makeNatural(11), largerThan10),
    M.equals(T.result(T.natTestable, T.textTestable, #ok(11)))
  ),
  Suite.test("ok -> err",
    Result.chain<Nat, Nat, Text>(makeNatural(5), largerThan10),
    M.equals(T.result(T.natTestable, T.textTestable, #err("5 is not larger than 10.")))
  ),
  Suite.test("err",
    Result.chain<Nat, Nat, Text>(makeNatural(-5), largerThan10),
    M.equals(T.result(T.natTestable, T.textTestable, #err("-5 is not a natural number.")))
  ),
]);

let flatten = Suite.suite("flatten", [
  Suite.test("ok -> ok",
    Result.flatten<Nat, Text>(#ok(#ok(10))),
    M.equals(T.result(T.natTestable, T.textTestable, #ok(10)))
  ),
  Suite.test("err",
    Result.flatten<Nat, Text>(#err("wrong")),
    M.equals(T.result(T.natTestable, T.textTestable, #err("wrong")))
  ),
  Suite.test("ok -> err",
    Result.flatten<Nat, Text>(#ok(#err("wrong"))),
    M.equals(T.result(T.natTestable, T.textTestable, #err("wrong")))
  ),
]);

let iterate = Suite.suite("iterate", {
  var tests : [Suite.Suite] = [];
  var counter : Nat = 0;
  Result.iterate(makeNatural(5), func (x : Nat) { counter += x });
  tests := Array.append(tests, [Suite.test("ok", counter, M.equals(T.nat(5)))]);
  Result.iterate(makeNatural(-10), func (x : Nat) { counter += x });
  tests := Array.append(tests, [Suite.test("err", counter, M.equals(T.nat(5)))]);
  tests
});

func arrayRes(itm : Result.Result<[Nat], Text>) : T.TestableItem<Result.Result<[Nat], Text>> {
  let resT = T.resultTestable(T.arrayTestable<Nat>(T.intTestable), T.textTestable);
  { display = resT.display; equals = resT.equals; item = itm }
};

let traverseArray = Suite.suite("traverseArray", [
  Suite.test("empty array",
    Result.traverseArray<Int, Nat, Text>([], makeNatural), 
    M.equals(arrayRes(#ok([])))
  ),

  Suite.test("success",
    Result.traverseArray<Int, Nat, Text>([ 1, 2, 3 ], makeNatural), 
    M.equals(arrayRes(#ok([1, 2, 3])))
  ),

  Suite.test("fail fast",
    Result.traverseArray<Int, Nat, Text>([ -1, 2, 3 ], makeNatural), 
    M.equals(arrayRes(#err("-1 is not a natural number.")))
  ),

  Suite.test("fail last",
    Result.traverseArray<Int, Nat, Text>([ 1, 2, -3 ], makeNatural), 
    M.equals(arrayRes(#err("-3 is not a natural number.")))
  ),
]);

func listRes(itm : Result.Result<List.List<Nat>, Text>) : T.TestableItem<Result.Result<List.List<Nat>, Text>> {
  let resT = T.resultTestable(T.listTestable<Nat>(T.intTestable), T.textTestable);
  { display = resT.display; equals = resT.equals; item = itm }
};

let traverseList = Suite.suite("traverseList", [
  Suite.test("empty list",
    Result.traverseList<Int, Nat, Text>(List.nil(), makeNatural),
    M.equals(listRes(#ok(List.nil())))
  ),
  Suite.test("success",
    Result.traverseList<Int, Nat, Text>(?(1, ?(2, ?(3, null))), makeNatural),
    M.equals(listRes(#ok(?(1, ?(2, ?(3, null))))))
  ),
  Suite.test("fail fast",
    Result.traverseList<Int, Nat, Text>(?(-1, ?(2, ?(3, null))), makeNatural),
    M.equals(listRes(#err("-1 is not a natural number.")))
  ),
  Suite.test("fail last",
    Result.traverseList<Int, Nat, Text>(?(1, ?(2, ?(-3, null))), makeNatural),
    M.equals(listRes(#err("-3 is not a natural number.")))
  ),
]);

let suite = Suite.suite("Result", [
  chain,
  flatten,
  iterate,
  traverseArray,
  traverseList
]);

Suite.run(suite);
