import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

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
