import Prim "mo:prim";
import Random "mo:base/Random";
import Nat8 "mo:base/Nat8";
import Blob "mo:base/Blob";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let nat8Testable : T.Testable<Nat8> = object {
  public func display(n: Nat8) : Text {
    Nat8.toText(n)
  };
  public func equals(first : Nat8, second : Nat8) : Bool {
    first == second
  }
};

let { run; test; suite } = Suite;

func toBits(b : Blob) : Nat -> Bool {
   let bytes = Blob.toArray(b);
   func (n : Nat) : Bool {
     let byte = bytes[n / 8];
     let mask = 0x80 >> (Nat8.fromNat(n % 8));
     0 != byte & mask
   }
};


func toWords(b : Blob, bits : Nat) : Nat -> Nat {
   let bytes = Blob.toArray(b);
   func (n : Nat) : Nat {
     let o = n/bits/8;
     var acc = 0;
     var i = 0;
     while (i < bits / 8) {
       let byte = bytes[o + i];
       acc := acc * 256 + Nat8.toNat(byte);
       i += 1;
     };
     acc
   }
};

func toPopcounts(b : Blob, bits : Nat) : Nat -> Nat8 {
   let bytes = Blob.toArray(b);
   func (n : Nat) : Nat8 {
     let o = n/bits/8;
     var acc : Nat8 = 0;
     var i = 0;
     while (i < bits / 8) {
       let byte = bytes[o + i];
       acc := Nat8.bitcountNonZero(byte);
       i += 1;
     };
     acc
   }
};

run(

   suite(
    "random-coin",
    [
      test(
        "random empty coin",
        Random.Finite("").coin(),
        M.equals(T.optional(T.boolTestable, null : ?Bool))
      ),
      test(
        "random non-empty coin - true",
        Random.Finite("\FF").coin(),
        M.equals(T.optional(T.boolTestable, ?true : ?Bool))
      ),
      test(
        "random non-empty coin - false",
        Random.Finite("\7F").coin(),
        M.equals(T.optional(T.boolTestable, ?false : ?Bool))
      ),

      test(
        "random coin echoes bits",
        do {
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let bits = toBits(blob);
          var i = 0;
          var max = blob.size()*8;
          var eq = true;
          while (i < max) {
            eq := eq and f.coin() == ?bits(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

    ]
  )
);

run(
  suite(
    "random-range",
    [
      test(
        "random empty range 8",
        Random.Finite("").range(8),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "random 1 byte range 8",
        Random.Finite("\FF").range(8),
        M.equals(T.optional(T.natTestable, ?255 : ?Nat))
      ),
      test(
        "random 1 byte range 8",
        Random.Finite("\00").range(8),
        M.equals(T.optional(T.natTestable, ?0 : ?Nat))
      ),
      test(
        "random 1 byte range 16",
        Random.Finite("\00").range(16),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
       test(
        "random 2 byte range 16",
        Random.Finite("\FF\FF").range(16),
        M.equals(T.optional(T.natTestable, ?65535 : ?Nat))
      ),

      test(
        "random range echoes bits 32",
        do {
          let bits = 32;
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let words = toWords(blob, bits);
          var i = 0;
          var max = blob.size() / bits / 8;
          var eq = true;
          while (i < max) {
            eq := eq and f.range(Nat8.fromNat(bits)) == ?words(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

      test(
        "random range echoes bits 8",
        do {
          let bits = 8;
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let words = toWords(blob, bits);
          var i = 0;
          var max = blob.size() / bits / 8;
          var eq = true;
          while (i < max) {
            eq := eq and f.range(Nat8.fromNat(bits)) == ?words(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

      test(
        "random range echoes bits 16",
        do {
          let bits = 16;
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let words = toWords(blob, bits);
          var i = 0;
          var max = blob.size() / bits / 8;
          var eq = true;
          while (i < max) {
            eq := eq and f.range(Nat8.fromNat(bits)) == ?words(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

    ]
  )
);

run(
  suite(
    "random-binomial",
    [
      test(
        "random empty binomial 8",
        Random.Finite("").binomial(8),
        M.equals(T.optional(nat8Testable, null : ?Nat8))
      ),
      test(
        "random 1 byte binomial 8 8",
        Random.Finite("\FF").binomial(8),
        M.equals(T.optional(nat8Testable, ?8 : ?Nat8))
      ),
      test(
        "random 1 byte binomial 8 0",
        Random.Finite("\00").binomial(8),
        M.equals(T.optional(nat8Testable, ?0 : ?Nat8))
      ),
      test(
        "random 1 byte binomial 8 0",
        Random.Finite("\AA").binomial(8),
        M.equals(T.optional(nat8Testable, ?4 : ?Nat8))
      ),
      test(
        "random 1 byte binomial 16",
        Random.Finite("\00").binomial(16),
        M.equals(T.optional(nat8Testable, null : ?Nat8))
      ),
      test(
        "random 2 byte binomial 16/16",
        Random.Finite("\FF\FF").binomial(16),
        M.equals(T.optional(nat8Testable, ?16 : ?Nat8))
      ),
      test(
        "random 2 byte binomial 0/16",
        Random.Finite("\00\00").binomial(16),
        M.equals(T.optional(nat8Testable, ?0 : ?Nat8))
      ),
      test(
        "random 2 byte binomial 8/16",
        Random.Finite("\AA\AA").binomial(16),
        M.equals(T.optional(nat8Testable, ?8 : ?Nat8))
      ),

      test(
        "random range echoes bits 32",
        do {
          let bits = 32;
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let popcounts = toPopcounts(blob, bits);
          var i = 0;
          var max = blob.size() / bits / 8;
          var eq = true;
          while (i < max) {
            eq := eq and f.binomial(Nat8.fromNat(bits)) == ?popcounts(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

      test(
        "random range echoes bits 8",
        do {
          let bits = 8;
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let popcounts = toPopcounts(blob, bits);
          var i = 0;
          var max = blob.size() / bits / 8;
          var eq = true;
          while (i < max) {
            eq := eq and f.binomial(Nat8.fromNat(bits)) == ?popcounts(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

      test(
        "random binomial echoes bits 16",
        do {
          let bits = 16;
          let blob : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
          let f = Random.Finite(blob);
          let popcounts = toPopcounts(blob, bits);
          var i = 0;
          var max = blob.size() / bits / 8;
          var eq = true;
          while (i < max) {
            eq := eq and f.binomial(Nat8.fromNat(bits)) == ?popcounts(i);
            i += 1;
          };
          eq;
         },
        M.equals(T.bool(true))
      ),

    ]
  )
);

run(
   suite(
    "random-coinFrom",
    [
      test(
        "random non-empty coin - true",
        Random.coinFrom("\FF"),
        M.equals(T.bool(true))
      ),
      test(
        "random non-empty coin - false",
        Random.coinFrom("\7F"),
        M.equals(T.bool(false))
      ),
      test(
        "random non-empty coin - true",
        Random.coinFrom("\FF\CA\FE\BA\BE"),
        M.equals(T.bool(true))
      ),
      test(
        "random non-empty coin - false",
        Random.coinFrom("\7F\CA\FE\BA\BE"),
        M.equals(T.bool(false))
      )
    ]
  )
);

