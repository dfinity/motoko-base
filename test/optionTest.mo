import Option "mo:base/Option";
import Debug "mo:base/Debug";

Debug.print("Option");

{
  Debug.print("  apply");

  {
    Debug.print("    null function, null value");

    let actual = Option.apply<Int, Bool>(null, null);
    let expected : ?Bool = null;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    null function, non-null value");

     let actual = Option.apply<Int, Bool>(?0, null);
    let expected : ?Bool = null;

     switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    non-null function, null value");

     let isEven = func (x : Int) : Bool {
      x % 2 == 0;
    };

    let actual = Option.apply<Int, Bool>(null, ?isEven);
    let expected : ?Bool = null;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    non-null function, non-null value");

   let isEven = func (x : Int) : Bool {
      x % 2 == 0;
    };

    let actual = Option.apply<Int, Bool>(?0, ?isEven);
    let expected = ?true;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(actual_ == expected_);
      };
      case (_, _) {
        assert(false);
      };
    };
  };

 };

{
  Debug.print("  bind");

  {
    Debug.print("    null value to null value");

    let safeInt = func (x : Int) : ?Int {
      if (x > 9007199254740991) {
        null;
      } else {
        ?x;
      }
    };

    let actual = Option.chain<Int, Int>(null, safeInt);
    let expected : ?Int = null;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    non-null value to null value");

    let safeInt = func (x : Int) : ?Int {
      if (x > 9007199254740991) {
        null;
      } else {
        ?x;
      }
    };

    let actual = Option.chain<Int, Int>(?9007199254740992, safeInt);
    let expected : ?Int = null;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    non-null value to non-null value");

    let safeInt = func (x : Int) : ?Int {
      if (x > 9007199254740991) {
        null;
      } else {
        ?x;
      }
    };

    let actual = Option.chain<Int, Int>(?0, safeInt);
    let expected = ?0;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(actual_ == expected_);
      };
      case (_, _) {
        assert(false);
      };
    };
  };

};

{
  Debug.print("  flatten");

  {
    Debug.print("    null value");

    let actual = Option.flatten<Int>(?null);
    let expected : ?Int = null;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    non-null value");
    let actual = Option.flatten<Int>(??0);
    let expected = ?0;

     switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(actual_ == expected_);
      };
      case (_, _) {
        assert(false);
      };
    };
  };

};

{
  Debug.print("  map");

  {
    Debug.print("    null value");

    let isEven = func (x : Int) : Bool {
      x % 2 == 0;
    };

    let actual = Option.map<Int, Bool>(isEven, null);
    let expected : ?Bool = null;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(false);
      };
      case (_, _) {
        assert(true);
      };
    };
  };

  {
    Debug.print("    non-null value");

    let isEven = func (x : Int) : Bool {
      x % 2 == 0;
    };

    let actual = Option.map<Int, Bool>(isEven, ?0);
    let expected = ?true;

    switch (actual, expected) {
      case (?actual_, ?expected_) {
        assert(actual_ == expected_);
      };
      case (_, _) {
        assert(false);
      };
    };
  };

};

{
  Debug.print("  make");

  let actual = Option.make<Int>(0);
  let expected = ?0;

  switch (actual, expected) {
    case (?actual_, ?expected_) {
      assert(actual_ == expected_);
    };
    case (_, _) {
      assert(false);
    };
  };
};
