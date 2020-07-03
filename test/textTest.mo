import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Char "mo:base/Char";
import Order "mo:base/Order";

Debug.print("Text");

{
  Debug.print("  concat");

  let actual = Text.concat("x", "y");
  let expected = "xy";

  assert(actual == expected);
};


{
  Debug.print("  join");

  let actual = Text.join((["aaa", "", "c", "dd"].vals()));
  let expected = "aaacdd";

  assert(actual == expected);
};


{
  Debug.print("  join");

  let actual = Text.joinWith(";",(["aaa", "", "c", "dd"].vals()));
  let expected = "aaa;;c;dd";

  assert(actual == expected);
};


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
