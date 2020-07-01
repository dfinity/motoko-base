/// Text values
///
/// This type describes a valid, human-readable text. It does not contain arbitrary
/// binary data.

import Iter "Iter";
import Hash "Hash";
import Prim "mo:prim";

module {

  // remove?
  public func append(x : Text, y : Text) : Text =
    x # y;

  /// Creates an [iterator](Iter.html#type.Iter) that traverses the characters of the text.
  public func toIter(text : Text) : Iter.Iter<Char> =
    text.chars();

  public func equal(x : Text, y : Text) : Bool { x == y };

  /// WARNING: This only hashes the lowest 32 bits of the `Int`
  public func hash(t : Text) : Hash.Hash {
    var x = 0 : Word32;
    for (c in t.chars()) {
      x := x ^ Prim.charToWord32(c);
    };
    return x
  };

  public func join(ts : Iter.Iter<Text>) : Text {
     var r = "";
     for (t in ts) {
       r #= t
     };
     return r;
  };

  public func joinWith(sep : Text, ts : Iter.Iter<Text>) : Text {
    var r = "";
    let next = ts.next;
    switch (next()) {
      case null { return r; };
      case (? t) {
        r #= t;
      }
    };
    loop {
      switch (next()) {
        case null { return r; };
        case (? t) {
          r #= sep;
          r #= t;
        }
      }
    }
  };

  public func implode(cs : Iter.Iter<Char>) : Text {
    var r = "";
    for (c in cs) {
      r #= Prim.charToText(c);
    };
    return r;
  };

  public func explode(t : Text) : Iter.Iter<Char> {
    t.chars();
  };

  public func map(t : Text, f : Char -> Char) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= Prim.charToText(f(c));
    };
    return r;
  };

  public func translate(t : Text, f : Char -> Text) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= f(c);
    };
    return r;
  };

  public func fields(t : Text, p : Char -> Bool) : Iter.Iter<Text> {
    var getc = t.chars().next;
    var state : { #init; #resume; #done} = #init;
    var field = "";
    object {
      public func next() : ?Text {
        switch state {
	  case (#done) { return null };
          case (#init) {
            loop {
              switch (getc()) {
                case (? c) {
                  if (p(c)) {
                    let r = field;
		    field := "";
                    state := #resume;
		    return ? r
	          }
                  else field #= Prim.charToText(c);
                };
                case null {
                  state := #done;
                  return if (field == "") null else ? field;
                }
              }
            }
          };
	  case (#resume) {
            loop {
              switch (getc()) {
                case (? c) {
                  if (p(c)) {
                    let r = field;
		    field := "";
                    state := #resume;
		    return ? r
	          }
                  else field #= Prim.charToText(c);
                };
                case null {
                  state := #done;
                  return ? field;
                }
              }
            }
          }
        }
      }
    }
  };

  public func tokens(t : Text, p : Char -> Bool) : Iter.Iter<Text> {
    let fs = fields(t, p);
    object {
      public func next() : ? Text {
        switch (fs.next()) {
	  case (? "") next();
          case ot ot;
	}
      }
    }
  };


}
