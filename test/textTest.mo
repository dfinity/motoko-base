import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Order "mo:base/Order";
import Array "mo:base/Array";
import Word32 "mo:base/Word32";

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

Debug.print("Text");

func charT(c : Char): T.TestableItem<Char> = {
  item = c;
  display = Text.text;
  equals = Char.equal;
};

// TODO: generalize and move to Iter.mo
func iterT(c : [Char]): T.TestableItem<Iter.Iter<Char>> = {
  item = c.vals();
  display = Text.implode;
  equals = func (cs1 : Iter.Iter<Char>, cs2 : Iter.Iter<Char>) : Bool {
     loop {
       switch (cs1.next(),cs2.next()) {
         case (null,null) return true;
	 case (? c1, ? c2)
	   if (c1 != c2) return false;
	 case (_,_) return false;
       }
     }
  };
};


Suite.run(Suite.suite("size",
[
 Suite.test(
   "size-0",
   Text.size(""),
   M.equals(T.nat 0)),
 Suite.test(
   "size-1",
   Text.size("a"),
   M.equals(T.nat 1)),
 Suite.test(
   "size-2",
   Text.size("abcdefghijklmnopqrstuvwxyz"),
   M.equals(T.nat 26)),
 Suite.test(
   "size-3",
   Text.size("☃"),
   M.equals(T.nat 1)),
 Suite.test(
   "size-4",
   Text.size("☃☃"),
   M.equals(T.nat 2)),
]));


Suite.run(Suite.suite("size",
[
 Suite.test(
   "size-0",
   Text.size(""),
   M.equals(T.nat 0)),
 Suite.test(
   "size-1",
   Text.size("a"),
   M.equals(T.nat 1)),
 Suite.test(
   "size-2",
   Text.size("abcdefghijklmnopqrstuvwxyz"),
   M.equals(T.nat 26)),
 Suite.test(
   "size-3",
   Text.size("☃"),
   M.equals(T.nat 1)),
 Suite.test(
   "size-4",
   Text.size("☃☃"),
   M.equals(T.nat 2)),
]));


Suite.run(Suite.suite("sub",
[
 Suite.test(
   "sub-0",
   Text.sub("abcdefghijklmnopqrstuvwxyz", 0),
   M.equals(charT 'a')),
 Suite.test(
   "sub-1",
   Text.sub("abcdefghijklmnopqrstuvwxyz", 1),
   M.equals(charT 'b')),
 Suite.test(
   "sub-2",
   Text.sub("abcdefghijklmnopqrstuvwxyz", 25),
   M.equals(charT 'z')),
]));


Suite.run(Suite.suite("extract",
[
 Suite.test(
   "extract-0",
   Text.extract("", 0, ? 0),
   M.equals(T.text "")),
 Suite.test(
   "extract-1",
   Text.extract("abcdefghijklmnopqrstuvwxyz", 0, ? 3),
   M.equals(T.text "abc")),
 Suite.test(
   "extract-2",
   Text.extract("abcdefghijklmnopqrstuvwxyz", 23, ? 3),
   M.equals(T.text "xyz")),
 Suite.test(
   "extract-3",
   Text.extract("abcdefghijklmnopqrstuvwxyz", 0, ? 26),
   M.equals(T.text "abcdefghijklmnopqrstuvwxyz")),
 Suite.test(
   "extract-3",
   Text.extract("a☃c", 1, ? 2),
   M.equals(T.text "☃c")),
]));


Suite.run(Suite.suite("subtext",
[
 Suite.test(
   "subtext-0",
   Text.subtext("", 0, 0),
   M.equals(T.text "")),
 Suite.test(
   "subtext-1",
   Text.subtext("abcdefghijklmnopqrstuvwxyz", 0, 3),
   M.equals(T.text "abc")),
 Suite.test(
   "subtext-2",
   Text.subtext("abcdefghijklmnopqrstuvwxyz", 23, 3),
   M.equals(T.text "xyz")),
 Suite.test(
   "subtext-3",
   Text.subtext("abcdefghijklmnopqrstuvwxyz", 0, 26),
   M.equals(T.text "abcdefghijklmnopqrstuvwxyz")),
 Suite.test(
   "subtext-3",
   Text.subtext("a☃c", 1, 2),
   M.equals(T.text "☃c")),
]));


Suite.run(Suite.suite("explode",
[
 Suite.test(
   "explode-0",
   Text.explode(""),
   M.equals(iterT([]))),
 Suite.test(
   "explode-1",
   Text.explode("a"),
   M.equals(iterT (['a']))),
 Suite.test(
   "explode-2",
   Text.explode("abc"),
   M.equals(iterT (['a','b','c']))),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   Suite.test(
   "implode-2",
   Text.explode(Text.join(Array.map(a, Char.toText).vals())),
   M.equals(iterT a))
 },
]));

Suite.run(Suite.suite("implode",
[
 Suite.test(
   "implode-0",
   Text.implode(([].vals())),
   M.equals(T.text(""))),
 Suite.test(
   "implode-1",
   Text.implode((['a'].vals())),
   M.equals(T.text "a")),
 Suite.test(
   "implode-2",
   Text.implode((['a', 'b', 'c'].vals())),
   M.equals(T.text "abc")),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   Suite.test(
   "implode-3",
   Text.implode(a.vals()),
   M.equals(T.text (Text.join(Array.map(a, Char.toText).vals()))))
 },
]));


Suite.run(Suite.suite("concat",
[
 Suite.test(
   "concat-0",
   Text.concat("",""),
   M.equals(T.text(""))),
 Suite.test(
   "concat-1",
   Text.concat("","b"),
   M.equals(T.text "b")),
 Suite.test(
   "concat-2",
   Text.concat("a","b"),
   M.equals(T.text "ab")),
 Suite.test(
   "concat-3",
   Text.concat("abcdefghijklmno","pqrstuvwxyz"),
   M.equals(T.text "abcdefghijklmnopqrstuvwxyz")),
]));

Suite.run(Suite.suite("join",
[
 Suite.test(
   "join-0",
   Text.join((["",""].vals())),
   M.equals(T.text(""))),
 Suite.test(
   "join-1",
   Text.join((["","b"].vals())),
   M.equals(T.text "b")),
 Suite.test(
   "join-2",
   Text.join((["a","bb","ccc","dddd"].vals())),
   M.equals(T.text "abbcccdddd")),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   Suite.test(
   "join-3",
   Text.join(Array.map(a, Char.toText).vals()),
   M.equals(T.text (Text.implode(a.vals()))))
 },
 Suite.test(
   "join-4",
   Text.join(([].vals())),
   M.equals(T.text "")),
 Suite.test(
   "join-5",
   Text.join((["aaa"].vals())),
   M.equals(T.text "aaa")),
]));

Suite.run(Suite.suite("joinWith",
[
 Suite.test(
   "joinWith-0",
   Text.joinWith(",", (["",""].vals())),
   M.equals(T.text(","))),
 Suite.test(
   "joinWith-1",
   Text.joinWith(",", (["","b"].vals())),
   M.equals(T.text ",b")),
 Suite.test(
   "joinWith-2",
   Text.joinWith(",", (["a","bb","ccc","dddd"].vals())),
   M.equals(T.text "a,bb,ccc,dddd")),
 {
   let a = Array.tabulate<Char>(1000, func i = Char.fromWord32(65+Word32.fromInt(i % 26)));
   Suite.test(
   "joinWith-3",
   Text.joinWith("", Array.map(a, Char.toText).vals()),
   M.equals(T.text (Text.implode(a.vals()))))
  },
 Suite.test(
   "joinWith-4",
   Text.joinWith(",", ([].vals())),
   M.equals(T.text "")),
 Suite.test(
   "joinWith-5",
   Text.joinWith(",", (["aaa"].vals())),
   M.equals(T.text "aaa")),
]));

{
  Debug.print("  fields");

  let tests = [
    { input = "aaa;;c;dd"; expected = ["aaa","","c","dd"] },
    { input = ""; expected = [] },
    { input = ";"; expected = ["",""] }
  ];

  for ({input;expected} in tests.vals()) {

    let actual =
      Iter.toArray(Text.fields(input, func c  { c == ';'}));
      Debug.print(debug_show(actual));

    assert (actual.size() == expected.size());

    for (i in actual.keys()) {
        assert(actual[i] == expected[i]);
    };
  };

};


{
  Debug.print("  tokens");

  let tests = [
    { input = "aaa;;c;dd"; expected = ["aaa","c","dd"] },
    { input = "aaa"; expected = ["aaa"] },
    { input = ";"; expected = [] }
  ];

  for ({input;expected} in tests.vals()) {

    let actual =
      Iter.toArray(Text.tokens(input, func c  { c == ';'}));
      Debug.print(debug_show(actual));

    assert (actual.size() == expected.size());

    for (i in actual.keys()) {
        assert(actual[i] == expected[i]);
    };
  };

};

{
  Debug.print("  isPrefix");

  let tests = [
    { input = ("",""); expected = true },
    { input = ("","abc"); expected = true },
    { input = ("abc","ab"); expected = false },
    { input = ("abc","abc"); expected = true },
    { input = ("abc","abcd"); expected = true },
  ];

  for (t in tests.vals()) {
    Debug.print (debug_show(t));
    let actual = Text.isPrefix(t.input.0,t.input.1);
    assert (actual == t.expected);
  };

};


{
  Debug.print("  isSubtext");

  let tests = [
    { input = ("bc","abcd"); expected = true },
    { input = ("","abc"); expected = true },
    { input = ("bc","ab"); expected = false },
    { input = ("cb","abc"); expected = false },
    { input = ("abc","abcd"); expected = true },
    { input = ("qrst","abcdefghijklmnopqrstuvwxyz"); expected = true },
    { input = ("abcdefg","abcdefghijklmnopqrstuvwxyz"); expected = true },
    { input = ("xyz","abcdefghijklmnopqrstuvwxyz"); expected = true },
    { input = ("lkj","abcdefghijklmnopqrstuvwxyz"); expected = false },
    { input = ("xyz",""); expected = false },
  ];

  for (t in tests.vals()) {
    Debug.print (debug_show(t));

    let actual = Text.isSubtext(t.input.0,t.input.1);
    assert (actual == t.expected);
  };

};

{
  Debug.print("  collate");

  let tests = [
    { input = ("",""); expected = #equal },
    { input = ("","a"); expected = #less },
    { input = ("abc","abc"); expected = #equal },
    { input = ("abc","abd"); expected = #less },
    { input = ("abc","abb"); expected = #greater },
    { input = ("abc","abcd"); expected = #less },
    { input = ("","abcd"); expected = #less },
    { input = ("abcd","abc"); expected = #greater },
    { input = ("xxxxabcd","xxxxabc"); expected = #greater },
  ];

  for (t in tests.vals()) {
    Debug.print (debug_show(t));

    let actual = Text.collate(t.input.0, t.input.1, Char.compare);
    assert (Order.equal(actual, t.expected));

    // sanity check against Text.compare;
    let comparison = Text.compare(t.input.0, t.input.1);
    assert (Order.equal(actual, comparison));
  };

};


