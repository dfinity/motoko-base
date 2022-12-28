/// Timers for one-off or periodic tasks.
///
/// Note: if `moc` is invoked with `-no-timer`, the importing will fail

import { setTimer = setTimerNano; cancelTimer = cancel } = "mo:⛔";
import { fromIntWrap } = "Nat64";

module {

  public type Duration = { #seconds : Nat; #nanoseconds : Nat };
  public type TimerId = Nat;

  func toNanos(d : Duration) : Nat64 =
    fromIntWrap (switch d {
      case (#seconds s) 1000_000_000 * s;
      case (#nanoseconds ns) ns });

  /// installs a one-off timer that upon expiration after given duration `d`
  /// executes the future `job()`
  ///
  public func setTimer(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano(toNanos d, false, job)
  };

  /// installs a recurring timer that upon expiration after given duration `d`
  /// executes the future `job()` and reinserts itself for expiration
  ///
  /// Note: a duration of 0 will only expire once
  ///
  public func recurringTimer(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano(toNanos d, true, job)
  };

  /// cancels a still active timer with `(id : TimerId)`. For expired timers
  /// and not recognised `id`s nothing happens
  public let cancelTimer : TimerId -> () = cancel;

}
