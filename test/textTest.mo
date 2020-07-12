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
  display = Text.fromChar;
  equals = Char.equal;
};

// TODO: generalize and move to Iter.mo
func iterT(c : [Char]): T.TestableItem<Iter.Iter<Char>> = {
  item = c.vals();
  display = Text.implode;
  equals = func (cs1 : Iter.Iter<Char>, cs2 : Iter.Iter<Char>) : Bool {
     loop {
       switch (cs1.next(), cs2.next()) {
         case (null,null) return true;
         case (? c1, ? c2)
           if (c1 != c2) return false;
         case (_, _) return false;
       }
     }
  };
};

// TODO: generalize and move to Iter.mo
func textIterT(c : [Text]): T.TestableItem<Iter.Iter<Text>> = {
  item = c.vals();
  display = func (ts: Iter.Iter<Text>) : Text { Text.joinWith(",", ts) } ; // TBR
  equals = func (cs1 : Iter.Iter<Text>, cs2 : Iter.Iter<Text>) : Bool {
     loop {
       switch (cs1.next(), cs2.next()) {
         case (null,null) return true;
         case (? c1, ? c2)
           if (c1 != c2) return false;
         case (_, _) return false;
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


Suite.run(Suite.suite("split",
[
 Suite.test(
   "split-char-empty",
   Text.split("", #char ';'),
   M.equals(textIterT([]))),
 Suite.test(
   "split-char-none",
   Text.split("abc", #char ';'),
   M.equals(textIterT(["abc"]))),
 Suite.test(
   "split-char-empties2",
   Text.split(";", #char ';'),
   M.equals(textIterT(["",""]))),
 Suite.test(
   "split-char-empties3",
   Text.split(";;", #char ';'),
   M.equals(textIterT(["","",""]))),
 Suite.test(
   "split-char-singles",
   Text.split("a;b;;c;;;d", #char ';'),
   M.equals(textIterT(["a","b","","c","","","d"]))),
 Suite.test(
   "split-char-mixed",
   Text.split("a;;;ab;;abc;", #char ';'),
   M.equals(textIterT(["a","","","ab","","abc",""]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   Suite.test(
     "split-char-large",
     Text.split(t, #char ';'),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(100000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   Suite.test(
     "split-char-very-large",
     Text.split(t, #char ';'),
     M.equals(textIterT a))
 },
]));


{
let pat : Text.Pattern = #predicate (func (c : Char) : Bool { c == ';' or c == '!' }) ;
Suite.run(Suite.suite("split",
[
 Suite.test(
   "split-pred-empty",
   Text.split("", pat),
   M.equals(textIterT([]))),
 Suite.test(
   "split-pred-none",
   Text.split("abc", pat),
   M.equals(textIterT(["abc"]))),
 Suite.test(
   "split-pred-empties2",
   Text.split(";", pat),
   M.equals(textIterT(["",""]))),
 Suite.test(
   "split-pred-empties3",
   Text.split(";!", pat),
   M.equals(textIterT(["","",""]))),
 Suite.test(
   "split-pred-singles",
   Text.split("a;b;!c!;;d", pat),
   M.equals(textIterT(["a","b","","c","","","d"]))),
 Suite.test(
   "split-pred-mixed",
   Text.split("a;!;ab;!abc;", pat),
   M.equals(textIterT(["a","","","ab","","abc",""]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   Suite.test(
     "split-pred-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(10000,func _ = "abc");
   let t = Text.joinWith(";", a.vals());
   Suite.test(
     "split-pred-very-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
]))
};


{
let pat : Text.Pattern = #text "PAT" ;
Suite.run(Suite.suite("split",
[
 Suite.test(
   "split-pat-empty",
   Text.split("", pat),
   M.equals(textIterT([]))),
 Suite.test(
   "split-pat-none",
   Text.split("abc", pat),
   M.equals(textIterT(["abc"]))),
 Suite.test(
   "split-pat-empties2",
   Text.split("PAT", pat),
   M.equals(textIterT(["",""]))),
 Suite.test(
   "split-pat-empties3",
   Text.split("PATPAT", pat),
   M.equals(textIterT(["","",""]))),
 Suite.test(
   "split-pat-singles",
   Text.split("aPATbPATPATcPATPATPATd", pat),
   M.equals(textIterT(["a","b","","c","","","d"]))),
 Suite.test(
   "split-pat-mixed",
   Text.split("aPATPATPATabPATPATabcPAT", pat),
   M.equals(textIterT(["a","","","ab","","abc",""]))),
 {
   let a = Array.tabulate<Text>(1000,func _ = "abc");
   let t = Text.joinWith("PAT", a.vals());
   Suite.test(
     "split-pat-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
 {
   let a = Array.tabulate<Text>(10000,func _ = "abc");
   let t = Text.joinWith("PAT", a.vals());
   Suite.test(
     "split-pat-very-large",
     Text.split(t, pat),
     M.equals(textIterT a))
 },
]))
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
      Iter.toArray(Text.tokens(input, #char ';'));
      Debug.print(debug_show(actual));

    assert (actual.size() == expected.size());

    for (i in actual.keys()) {
        assert(actual[i] == expected[i]);
    };
  };

};


Suite.run(Suite.suite("startsWith",
[
 Suite.test(
   "startsWith-both-empty",
   Text.startsWith("", #text ""),
   M.equals(T.bool true)),
 Suite.test(
   "startsWith-empty-text",
   Text.startsWith("", #text "abc"),
   M.equals(T.bool false)),
 Suite.test(
   "startsWith-empty-pat",
   Text.startsWith("abc", #text ""),
   M.equals(T.bool true)),
 Suite.test(
   "startsWith-1",
   Text.startsWith("a", #text "b"),
   M.equals(T.bool false)),
 Suite.test(
   "startsWith-2",
   Text.startsWith("abc", #text "abc"),
   M.equals(T.bool true)),
 Suite.test(
   "startsWith-3",
   Text.startsWith("abcd", #text "ab"),
   M.equals(T.bool true)),
 Suite.test(
   "startsWith-4",
   Text.startsWith("abcdefghijklmnopqrstuvwxyz",#text "abcdefghijklmno"),
   M.equals(T.bool true)),
]));



Suite.run(Suite.suite("endsWith",
[
 Suite.test(
   "endsWith-both-empty",
   Text.endsWith("", #text ""),
   M.equals(T.bool true)),
 Suite.test(
   "endsWith-empty-text",
   Text.endsWith("", #text "abc"),
   M.equals(T.bool false)),
 Suite.test(
   "endsWith-empty-pat",
   Text.endsWith("abc", #text ""),
   M.equals(T.bool true)),
 Suite.test(
   "endsWith-1",
   Text.endsWith("a", #text "b"),
   M.equals(T.bool false)),
 Suite.test(
   "endsWith-2",
   Text.endsWith("abc", #text "abc"),
   M.equals(T.bool true)),
 Suite.test(
   "endsWith-3",
   Text.endsWith("abcd", #text "cd"),
   M.equals(T.bool true)),
 Suite.test(
   "endsWith-4",
   Text.endsWith("abcdefghijklmnopqrstuvwxyz",#text "pqrstuvwxyz"),
   M.equals(T.bool true)),
]));


Suite.run(Suite.suite("contains",
[
 Suite.test(
   "contains-start",
   Text.contains("abcd", #text "ab"),
   M.equals(T.bool true)),
 Suite.test(
   "contains-empty",
   Text.contains("abc", #text ""),
   M.equals(T.bool true)),
 Suite.test(
   "contains-false",
   Text.contains("ab", #text "bc" ),
   M.equals(T.bool false)),
 Suite.test(
   "contains-exact",
   Text.contains("abc", #text "abc"),
   M.equals(T.bool true)),
 Suite.test(
   "contains-within",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "qrst"),
   M.equals(T.bool true)),
 Suite.test(
   "contains-front",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "abcdefg"),
   M.equals(T.bool true)),
 Suite.test(
   "contains-end",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "xyz"),
   M.equals(T.bool true)),
 Suite.test(
   "contains-false",
   Text.contains("abcdefghijklmnopqrstuvwxyz", #text "lkj"),
   M.equals(T.bool false)),
 Suite.test(
   "contains-empty-nonempty",
   Text.contains("", #text "xyz"),
   M.equals(T.bool false)),
]));


Debug.print ("replace");
Suite.run(Suite.suite("replace",
[
 Suite.test(
   "replace-start",
   Text.replace("abcd", #text "ab", "AB"),
   M.equals(T.text "ABcd")),
 Suite.test(
   "replace-empty",
   Text.replace("abc", #text "", "AB"),
   M.equals(T.text "ABaABbABcAB")),
 Suite.test(
   "replace-none",
   Text.replace("ab", #text "bc", "AB"),
   M.equals(T.text "ab")),
 Suite.test(
   "replace-exact",
   Text.replace("ab", #text "ab", "AB"),
   M.equals(T.text "AB")),
 Suite.test(
   "replace-several",
   Text.replace("abcdabghijabmnopqrstuabwxab", #text "ab", "AB"),
   M.equals(T.text "ABcdABghijABmnopqrstuABwxAB")),
 Suite.test(
   "replace-delete",
   Text.replace("abcdabghijabmnopqrstuabwxab", #text "ab", ""),
   M.equals(T.text "cdghijmnopqrstuwx")),
 Suite.test(
   "replace-pred",
   Text.replace("abcdefghijklmnopqrstuvwxyz", #predicate (func (c : Char) : Bool { c < 'm'}), ""),
   M.equals(T.text "mnopqrstuvwxyz")),
]));



{
  Debug.print("  compareWith");

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

    let actual = Text.compareWith(t.input.0, t.input.1, Char.compare);
    assert (Order.equal(actual, t.expected));

    // sanity check against Text.compare;
    let comparison = Text.compare(t.input.0, t.input.1);
    assert (Order.equal(actual, comparison));
  };

};


