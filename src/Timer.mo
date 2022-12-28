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
      case (#seconds s) s * 1000_000_000;
      case (#nanoseconds ns) ns });

  /// Installs a one-off timer that upon expiration after given duration `d`
  /// executes the future `job()`.
  ///
  public func setTimer(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano(toNanos d, false, job)
  };

  /// Installs a recurring timer that upon expiration after given duration `d`
  /// executes the future `job()` and reinserts itself for another expiration.
  ///
  /// Note: A duration of 0 will only expire once.
  ///
  public func recurringTimer(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano(toNanos d, true, job)
  };

  /// Cancels a still active timer with `(id : TimerId)`. For expired timers
  /// and not recognised `id`s nothing happens.
  public let cancelTimer : TimerId -> () = cancel;

}
