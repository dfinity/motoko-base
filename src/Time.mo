
import Prim "mo:⛔";
module {

  ///  System time is represent as nanoseconds since 1970-01-01.
  public type Time = Int;

  ///  Current system time given as nanoseconds since 1970-01-01. The system guarantees that:
  /// 
  ///  * The time, as observed by the canister smart contract, is monotonically increasing, even across canister upgrades.
  ///  * Within an invocation of one entry point, the time is constant.
  /// 
  /// The system times of different canisters are unrelated, and calls from one canister to another may appear to travel "backwards in time"
  /// 
  /// :::note [Accuracy guarantee]
  ///  While an implementation will likely try to keep the system time close to the real time, this is not formally guaranteed.
  /// :::
  public let now : () -> Time = func() : Int = Prim.nat64ToNat(Prim.time());
  /// 
  ///  The following example illustrates using the system time:
  /// 
  ///  ```motoko
  ///  import Int = "mo:base/Int";
  ///  import Time = "mo:base/Time";
  /// 
  ///  actor {
  ///    var lastTime = Time.now();
  ///    public func greet(name : Text) : async Text {
  ///      let now = Time.now();
  ///      let elapsedSeconds = (now - lastTime) / 1000_000_000;
  ///      lastTime := now;
  ///      return "Hello, " # name # "!" #
  ///        " I was last called " # Int.toText(elapsedSeconds) # " seconds ago";
  ///     };
  ///  };
  ///  ```
}
