// @testmode wasi

import Map "../src/PersistentOrderedMap";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Debug "../src/Debug";
import Array "../src/Array";
import Option "../src/Option";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

import Random2 "mo:base/Random";

let { run; test; suite } = Suite;

class MapMatcher(expected : Map.Map<Nat, Text>) : M.Matcher<Map.Map<Nat, Text>> {
  public func describeMismatch(actual : Map.Map<Nat, Text>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(Map.entries(actual))) # " should be " # debug_show (Iter.toArray(Map.entries(expected))))
  };

  public func matches(actual : Map.Map<Nat, Text>) : Bool {
    Iter.toArray(Map.entries(actual)) == Iter.toArray(Map.entries(expected))
  }
};

object Random {
  var number = 4711;
  public func next() : Nat {
    number := (15485863 * number + 5) % 15485867;
    number
  };

  public func nextNat(range: (Nat, Nat)): Nat {
    let n = next();
    let v = n % (range.1 - range.0 + 1) + range.0;
    v
  };

  public func nextEntries(range: (Nat, Nat), size: Nat): [(Nat, Text)] {
    Array.tabulate<(Nat, Text)>(size, func(_ix) { 
      let key = nextNat(range); (key, debug_show(key)) } )
  }
};

let natMap = Map.MapOps<Nat>(Nat.compare);

func mapGen(samples_number: Nat, size: Nat, range: (Nat, Nat)): Iter.Iter<Map.Map<Nat, Text>> {
  object {
    var n = 0;
    public func next(): ?Map.Map<Nat, Text>  {
      n += 1;
      if (n > samples_number) { 
        null 
      } else {
        ?natMap.fromIter<Text>(Random.nextEntries(range, size).vals())
      }
    }
  }
};


func run_all_props(range: (Nat, Nat), size: Nat, map_samples: Nat, query_samples: Nat) {
  func prop(name: Text, f: Map.Map<Nat, Text> -> Bool): Suite.Suite {
    var error_msg: Text = "";
    test(name, do {
        var error = true;
        label stop for(map in mapGen(map_samples, size, range)) { 
          if (not f(map)) {
            error_msg := "Property \"" # name # "\" failed\n";
            error_msg #= "\n m: " # debug_show(Iter.toArray(Map.entries(map)));
            break stop;
          }
        };
        error_msg
      }, M.describedAs(error_msg, M.equals(T.text(""))))
  };
  func prop_with_key(name: Text, f: (Map.Map<Nat, Text>, Nat) -> Bool): Suite.Suite {
    var error_msg: Text = "";
    test(name, do {
        label stop for(map in mapGen(map_samples, size, range)) {
          for (_query_ix in Iter.range(0, query_samples-1)) {
            let key = Random.nextNat(range);
            if (not f(map, key)) {
              error_msg #= "Property \"" # name # "\" failed";
              error_msg #= "\n m: " # debug_show(Iter.toArray(Map.entries(map)));
              error_msg #= "\n k: " # debug_show(key);
              break stop;
            }
          }
        };
        error_msg
      }, M.describedAs(error_msg, M.equals(T.text(""))))
  };
  run(
    suite("Property tests",
   [ 
      suite("empty", [
        test("get(empty(), k) == null", label res : Bool {
          for (_query_ix in Iter.range(0, query_samples-1)) {
            let k = Random.nextNat(range);
            if(natMap.get(Map.empty<Nat, Text>(), k) != null)
              break res(false);
          };
          true;
        }, M.equals(T.bool(true)))
      ]),

      suite("get & put", [
        prop_with_key("get(put(m, k, v), k) == ?v", func (m, k) {
          natMap.get(natMap.put(m, k, "v"), k) == ?"v"
        }),
        prop_with_key("get(put(put(m, k, v1), k, v2), k) == ?v2", func (m, k) {
          let (v1, v2) = ("V1", "V2");
          natMap.get(natMap.put(natMap.put(m, k, v1), k, v2), k) == v2
        }),
      ]),
      
      suite("replace", [
        prop_with_key("replace(m, k, v).0 == put(m, k, v)", func (m, k) {
          natMap.replace(m, k, "v").0 == natMap.put(m, k, "v")
        }),
        prop_with_key("replace(put(m, k, v1), k, v2).1 == ?v1", func (m, k) {
          natMap.replace(natMap.put(m, k, "v1"), k, "v2").1 == ?"v1"
        }),
        prop_with_key("get(m, k) == null ==> replace(m, k, v).1 == null", func (m, k) {
          if (natMap.get(m, k) == null) {
            natMap.replace(m, k, "v").1 == null
          } else { true }
        }),
      ]),

      suite("delete", [
        prop_with_key("get(m, k) == null ==> delete(m, k) == m", func (m, k) {
          if (natMap.get(m, k) == null) {
            MapMatcher(m).matches(natMap.delete(m, k))
          } else { true }
        }),
        prop_with_key("delete(put(m, k, v), k) == m", func (m, k) {
          if (natMap.get(m, k) == null) {
            MapMatcher(m).matches(natMap.delete(natMap.put(m, k, "v"), k))
          } else { true }
        }),
        prop_with_key("delete(delete(m, k), k)) == delete(m, k)", func (m, k) {
          let m1 = natMap.delete(natMap.delete(m, k), k);
          let m2 = natMap.delete(m, k);
          MapMatcher(m2).matches(m1)
        })
      ]),

      suite("remove", [
        prop_with_key("remove(m, k).0 == delete(m, k)", func (m, k) {
          let m1 = natMap.remove(m, k).0;
          let m2 = natMap.delete(m, k);
          MapMatcher(m2).matches(m1)
        }),
        prop_with_key("remove(put(m, k, v), k).1 == ?v", func (m, k) {
          natMap.remove(natMap.put(m, k, "v"), k).1 == ?"v" 
        }),
        prop_with_key("remove(remove(m, k).0, k).1 == null", func (m, k) {
          natMap.remove(natMap.remove(m, k).0, k).1 == null
        }),
        prop_with_key("put(remove(m, k).0, k, remove(m, k).1) == m", func (m, k) {
          if (natMap.get(m, k) != null) {
            MapMatcher(m).matches(natMap.put(natMap.remove(m, k).0, k, Option.get(natMap.remove(m, k).1, "")))
          } else { true }
        })
      ]),

      suite("size", [
        prop_with_key("size(put(m, k, v)) == size(m) + int(get(m, k) == null)", func (m, k) {
          Map.size(natMap.put(m, k, "v")) == Map.size(m) + (if (natMap.get(m, k) == null) {1} else {0})
        }),
        prop_with_key("size(delete(m, k)) + int(get(m, k) != null) == size(m)", func (m, k) {
          Map.size(natMap.delete(m, k)) + (if (natMap.get(m, k) != null) {1} else {0}) == Map.size(m)
        })
      ]),
      
      suite("iter,keys,vals,entries",  [
        prop("fromIter(iter(m, #fwd)) == m", func (m) {
          MapMatcher(m).matches(natMap.fromIter(Map.iter(m, #fwd)))
        }),
        prop("fromIter(iter(m, #bwd)) == m", func (m) {
          MapMatcher(m).matches(natMap.fromIter(Map.iter(m, #bwd)))
        }),
        prop("iter(m, #fwd) = zip(key(m), vals(m))", func (m) {
          let k = Map.keys<Nat, Text>(m);
          let v = Map.vals(m);
          for (e in Map.iter(m, #fwd)) {
            if (e.0 != k.next() or e.1 != v.next())
              return false;
          };
          return true;
        }),
        prop("entries(m) == iter(m, #fwd)", func (m) {
          let it = Map.iter(m, #fwd);
          for (e in Map.entries(m)) {
            if (it.next() != e)
              return false;
          };
          return true
        })
      ]),
      
      suite("mapFilter", [
        prop_with_key("get(mapFilter(m, (!=k)), k) == null", func (m, k) {
          natMap.get(natMap.mapFilter<Text, Text>(m, 
          func (ki, vi) { if (ki != k) {?vi} else {null}}), k) == null
        }),
        prop_with_key("get(mapFilter(put(m, k, v), (==k)), k) == ?v", func (m, k) {
          natMap.get(natMap.mapFilter<Text, Text>(natMap.put(m, k, "v"), 
          func (ki, vi) { if (ki == k) {?vi} else {null}}), k) == ?"v"
        })
      ]),
      
      suite("map", [
        prop("map(m, id) == m", func (m) {
          MapMatcher(m).matches(Map.map<Nat, Text, Text>(m, func (k, v) {v}))
        })
      ]),
      
      suite("folds", [
        prop("foldLeft as iter(#fwd)", func (m) {
          let it = Map.iter(m, #fwd);
          Map.foldLeft<Nat, Text, Bool>(m, true, func (k, v, acc) {acc and it.next() == ?(k, v)})
        }),
        prop("foldRight as iter(#bwd)", func(m) {
          let it = Map.iter(m, #bwd);
          Map.foldRight<Nat, Text, Bool>(m, true, func (k, v, acc) {acc and it.next() == ?(k, v)})
        })
      ]),
    ]))   
};

run_all_props((1, 3), 0, 1, 10);
run_all_props((1, 5), 5, 100, 100);
run_all_props((1, 10), 10, 100, 100);
run_all_props((1, 100), 20, 100, 100);
run_all_props((1, 1000), 100, 100, 100);