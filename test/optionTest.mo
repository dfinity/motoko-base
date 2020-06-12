import Option "mo:base/Option";
import Prelude "mo:base/Prelude";

Prelude.debugPrintLine("Option");

{
  Prelude.debugPrintLine("  apply");

  {
    Prelude.debugPrintLine("    null function, null value");

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
    Prelude.debugPrintLine("    null function, non-null value");

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
    Prelude.debugPrintLine("    non-null function, null value");

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
    Prelude.debugPrintLine("    non-null function, non-null value");

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
  Prelude.debugPrintLine("  bind");

  {
    Prelude.debugPrintLine("    null value to null value");

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
    Prelude.debugPrintLine("    non-null value to null value");

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
    Prelude.debugPrintLine("    non-null value to non-null value");

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
  Prelude.debugPrintLine("  flatten");

  {
    Prelude.debugPrintLine("    null value");

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
    Prelude.debugPrintLine("    non-null value");
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
  Prelude.debugPrintLine("  transform");

  {
    Prelude.debugPrintLine("    null value");

    let isEven = func (x : Int) : Bool {
      x % 2 == 0;
    };

    let actual = Option.transform<Int, Bool>(isEven, null);
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
    Prelude.debugPrintLine("    non-null value");

    let isEven = func (x : Int) : Bool {
      x % 2 == 0;
    };

    let actual = Option.transform<Int, Bool>(isEven, ?0);
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
  Prelude.debugPrintLine("  make");

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
