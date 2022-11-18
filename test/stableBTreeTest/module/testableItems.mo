import Types "../../src/types";

import Suite "mo:matchers/Suite";
import Matchers "mo:matchers/Matchers";
import Testable "mo:matchers/Testable";

import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Int8 "mo:base/Int8";
import Int16 "mo:base/Int16";
import Int32 "mo:base/Int32";
import Int64 "mo:base/Int64";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Bool "mo:base/Bool";

module {

  // For convenience: from base module
  type Result<Ok, Err> = Result.Result<Ok, Err>;
  // For convenience: from matchers module
  let { run;test;suite; } = Suite;
  // For convenience: from types module
  type InsertError = Types.InsertError;
  type NodeType = Types.NodeType;
  type Entry = Types.Entry;

  func testNat(item: Nat) : Testable.TestableItem<Nat> {
    { display = Nat.toText; equals = Nat.equal; item ; };
  };

  func testNat8(item: Nat8) : Testable.TestableItem<Nat8> {
    { display = Nat8.toText; equals = Nat8.equal; item ; };
  };

  func testNat16(item: Nat16) : Testable.TestableItem<Nat16> {
    { display = Nat16.toText; equals = Nat16.equal; item ; };
  };

  func testNat32(item: Nat32) : Testable.TestableItem<Nat32> {
    { display = Nat32.toText; equals = Nat32.equal; item ; };
  };

  func testNat64(item: Nat64) : Testable.TestableItem<Nat64> {
    { display = Nat64.toText; equals = Nat64.equal; item ; };
  };

  func testInt(item: Int) : Testable.TestableItem<Int> {
    { display = Int.toText; equals = Int.equal; item ; };
  };

  func testInt8(item: Int8) : Testable.TestableItem<Int8> {
    { display = Int8.toText; equals = Int8.equal; item ; };
  };

  func testInt16(item: Int16) : Testable.TestableItem<Int16> {
    { display = Int16.toText; equals = Int16.equal; item ; };
  };

  func testInt32(item: Int32) : Testable.TestableItem<Int32> {
    { display = Int32.toText; equals = Int32.equal; item ; };
  };

  func testInt64(item: Int64) : Testable.TestableItem<Int64> {
    { display = Int64.toText; equals = Int64.equal; item ; };
  };

  func bytesToText(bytes: [Nat8]) : Text {
    let text_buffer = Buffer.Buffer<Text>(bytes.size() + 2);
    text_buffer.add("[");
    for (byte in Array.vals(bytes)){
      text_buffer.add(Nat8.toText(byte) # " ");
    };
    text_buffer.add("]");
    Text.join("", text_buffer.vals());
  };

  func optBytesToText(bytes: ?[Nat8]) : Text {
    optToText<[Nat8]>(bytes, bytesToText);
  };

  func optBytesEqual(bytes_1: ?[Nat8], bytes_2: ?[Nat8]) : Bool {
    optEqual<[Nat8]>(bytes_1, bytes_2, bytesEqual);
  };

  func bytesEqual(bytes_1: [Nat8], bytes_2: [Nat8]) : Bool {
    bytes_1 == bytes_2;
  };

  func testBytes(item: [Nat8]) : Testable.TestableItem<[Nat8]> {
    {
      display = bytesToText;
      equals = bytesEqual;
      item;
    };
  };

  func optToText<T>(opt: ?T, to_text: T -> Text) : Text {
    switch(opt){
      case(null) { "opt: null"; };
      case(?item) { "opt: " # to_text(item); };
    };
  };

  func optEqual<T>(opt1: ?T, opt2: ?T, equal: (T, T) -> Bool) : Bool {
    switch(opt1){
      case(null) {
        switch(opt2){
          case(null) { true; };
          case(_) { false; };
        };
      };
      case(?item1) {
        switch(opt2){
          case(null) { false; };
          case(?item2) { equal(item1, item2); };
        };
      };
    };
  };

  func testOptItem<T>(opt: ?T, to_text: T -> Text, equal: (T, T) -> Bool) : Testable.TestableItem<?T> {
    {
      display = func(opt: ?T) : Text {
        optToText(opt, to_text);
      };
      equals = func (opt1: ?T, opt2: ?T) : Bool {
        optEqual(opt1, opt2, equal)
      };
      item = opt;
    };
  };

  func testResult<Ok, Err>(
    item: Result<Ok, Err>,
    ok_to_text: Ok -> Text,
    err_to_text: Err -> Text,
    ok_equal: (Ok, Ok) -> Bool,
    err_equal: (Err, Err) -> Bool
  ) : Testable.TestableItem<Result<Ok, Err>> {
    {
      display = func(item: Result<Ok, Err>) : Text {
        switch(item){
          case(#ok(ok)) { "ok: " # ok_to_text(ok); };
          case(#err(err)) { "err: " # err_to_text(err); };
        };
      };
      equals = func (r1: Result<Ok, Err>, r2: Result<Ok, Err>) : Bool {
        Result.equal(ok_equal, err_equal, r1, r2);
      };
      item;
    };
  };

  func testOptBytes(item: ?[Nat8]) : Testable.TestableItem<?[Nat8]> {
    testOptItem<[Nat8]>(item, bytesToText, bytesEqual);
  };

  func insertErrorToText(error: InsertError) : Text {
    switch(error){
      case(#KeyTooLarge({given; max;})){
        "Key too large. Given is '" # Nat.toText(given) # "' while max is '" # Nat.toText(max) # "'";
      };
      case(#ValueTooLarge({given; max;})){
        "Value too large. Given is '" # Nat.toText(given) # "' while max is '" # Nat.toText(max) # "'";
      };
    };
  };

  func insertErrorEqual(error1: InsertError, error2: InsertError) : Bool {
    error1 == error2;
  };

  type InsertResult = Result<?[Nat8], InsertError>;

  func testInsertResult(result: InsertResult) : Testable.TestableItem<InsertResult> {
    testResult<?[Nat8], InsertError>(result, optBytesToText, insertErrorToText, optBytesEqual, insertErrorEqual);
  };

  func testNodeType(node_type: NodeType) : Testable.TestableItem<NodeType> {
    {
      display = func(node_type: NodeType) : Text {
        switch(node_type){
          case(#Leaf){ "Leaf"; };
          case(#Internal){ "Internal"; };
        };
      };
      equals = func (type1: NodeType, type2: NodeType) : Bool {
        type1 == type2;
      };
      item = node_type;
    };
  };

  func testBool(bool: Bool) : Testable.TestableItem<Bool> {
    {
      display = func(bool: Bool) : Text {
        Bool.toText(bool);
      };
      equals = func(bool1: Bool, bool2: Bool) : Bool {
        bool1 == bool2;
      };
      item = bool;
    };
  };

  func entryToText(entry: Entry) : Text {
    "key: " # bytesToText(entry.0) # ", value: " # bytesToText(entry.1);
  };

  func entryEqual(entry1: Entry, entry2: Entry) : Bool {
    bytesEqual(entry1.0, entry2.0) and bytesEqual(entry1.1, entry2.1);
  };

  func testEntries(entries: [Entry]) : Testable.TestableItem<[Entry]> {
    {
      display = func(entries: [Entry]) : Text {
        let text_buffer = Buffer.Buffer<Text>(entries.size() + 2);
        text_buffer.add("[");
        for (entry in Array.vals(entries)){
          text_buffer.add("(" # entryToText(entry) # "), ");
        };
        text_buffer.add("]");
        Text.join("", text_buffer.vals());
      };
      equals = func(entries1: [Entry], entries2: [Entry]) : Bool {
        Array.equal(entries1, entries2, entryEqual);
      };
      item = entries;
    };
  };

  func arrayNat16toText(array: [Nat16]) : Text {
    let text_buffer = Buffer.Buffer<Text>(array.size() + 2);
    text_buffer.add("[");
    for (elem in Array.vals(array)){
      text_buffer.add("(" # Nat16.toText(elem) # "), ");
    };
    text_buffer.add("]");
    Text.join("", text_buffer.vals());
  };

  func arrayNat16Equal(array1: [Nat16], array2: [Nat16]) : Bool {
    Array.equal(array1, array2, Nat16.equal);
  };

  func testOptArrayNat16(array: ?[Nat16]) : Testable.TestableItem<?[Nat16]> {
    testOptItem<[Nat16]>(array, arrayNat16toText, arrayNat16Equal);
  };

  public class TestBuffer() {

    let tests_ = Buffer.Buffer<Suite.Suite>(0);

    public func run(message: Text) {
      Suite.run(suite(message, tests_.toArray()));
    };

    public func equals<T>(message: Text, actual: T, expected: Testable.TestableItem<T>){
      tests_.add(test(message, actual, Matchers.equals(expected)));
    };

    public func equalsNat(actual: Nat, expected: Nat){
      equals<Nat>("equalsNat", actual, testNat(expected));
    };

    public func equalsNat8(actual: Nat8, expected: Nat8){
      equals<Nat8>("equalsNat8", actual, testNat8(expected));
    };

    public func equalsNat16(actual: Nat16, expected: Nat16){
      equals<Nat16>("equalsNat16", actual, testNat16(expected));
    };

    public func equalsNat32(actual: Nat32, expected: Nat32){
      equals<Nat32>("equalsNat32", actual, testNat32(expected));
    };

    public func equalsNat64(actual: Nat64, expected: Nat64){
      equals<Nat64>("equalsNat64", actual, testNat64(expected));
    };

    public func equalsInt(actual: Int, expected: Int){
      equals<Int>("equalsInt", actual, testInt(expected));
    };

    public func equalsInt8(actual: Int8, expected: Int8){
      equals<Int8>("equalsInt8", actual, testInt8(expected));
    };

    public func equalsInt16(actual: Int16, expected: Int16){
      equals<Int16>("equalsInt16", actual, testInt16(expected));
    };

    public func equalsInt32(actual: Int32, expected: Int32){
      equals<Int32>("equalsInt32", actual, testInt32(expected));
    };

    public func equalsInt64(actual: Int64, expected: Int64){
      equals<Int64>("equalsInt64", actual, testInt64(expected));
    };

    public func equalsBytes(actual: [Nat8], expected: [Nat8]){
      equals<[Nat8]>("equalsBytes", actual, testBytes(expected));
    };

    public func equalsOptBytes(actual: ?[Nat8], expected: ?[Nat8]){
      equals<?[Nat8]>("equalsOptBytes", actual, testOptBytes(expected));
    };

    public func equalsInsertResult(actual: InsertResult, expected: InsertResult){
      equals<InsertResult>("equalsInsertResult", actual, testInsertResult(expected));
    };

    public func equalsNodeType(actual: NodeType, expected: NodeType){
      equals<NodeType>("equalsNodeType", actual, testNodeType(expected));
    };

    public func equalsBool(actual: Bool, expected: Bool){
      equals<Bool>("equalsBool", actual, testBool(expected));
    };

    public func equalsEntries(actual: [Entry], expected: [Entry]){
      equals<[Entry]>("equalsEntries", actual, testEntries(expected));
    };

    public func equalsOptArrayNat16(actual: ?[Nat16], expected: ?[Nat16]){
      equals<?[Nat16]>("equalsOptArrayNat16", actual, testOptArrayNat16(expected));
    };

  };

};