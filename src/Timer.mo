/// Timers for one-off or periodic tasks.
///

import { setTimer = setTimerNano; cancelTimer = cancel } = "mo:⛔";
import { fromIntWrap } = "Nat64";

module {

  public type Duration = { #seconds : Nat; #nanoseconds : Nat };
  public type TimerId = Nat;

  /// installs a one-off timer that upon expiration after given duration `d`
  /// executes the future `job()`
  ///
  public func setTimer(d : Duration, job : () -> async ()) : TimerId {
    let nanos = switch d {
      case (#seconds s) 1000_000_000 * s;
      case (#nanoseconds ns) ns
    };
    setTimerNano(fromIntWrap nanos, false, job)
  };

  /// installs a recurring timer that upon expiration after given duration `d`
  /// executes the future `job()` and reinserts itself for expiration
  ///
  public func recurringTimer(d : Duration, job : () -> async ()) : TimerId {
    let nanos = switch d {
      case (#seconds s) 1000_000_000 * s;
      case (#nanoseconds ns) ns
    };
    setTimerNano(fromIntWrap nanos, true, job)
  };

  /// cancels a still active timer with `(id : TimerId)`. For expired timers
  /// and not recognised `id`s nothing happens
  public let cancelTimer = cancel;

}
