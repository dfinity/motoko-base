/// Timers for one-off or periodic tasks.
///
/// Note: If `moc` is invoked with `-no-timer`, the importing will fail.
/// Note: The resolution of the timers is in the order of the block rate,
///       so durations should be chosen well above that. For frequent
///       canister wake-ups the heatbeat mechanism should be considered.

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
  /// ```motoko no-repl
  /// let now = Time.now();
  /// let thirtyMinutes = 1_000_000_000 * 60 * 30;
  /// func alarmUser() : async () {
  ///   // ...
  /// };
  /// appt.reminder = setTimer(#nanoseconds (Int.abs(appt.when - now - thirtyMinutes)), alarmUser);
  /// ```
  public func setTimer(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano<async>(toNanos d, false, job)
  };

  /// Installs a recurring timer that upon expiration after given duration `d`
  /// executes the future `job()` and reinserts itself for another expiration.
  ///
  /// Note: A duration of 0 will only expire once.
  ///
  /// ```motoko no-repl
  /// func checkAndWaterPlants() : async () {
  ///   // ...
  /// };
  /// let daily = recurringTimer(#seconds (24 * 60 * 60), checkAndWaterPlants);
  /// ```
  public func recurringTimer(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano<async>(toNanos d, true, job)
  };

  /// Cancels a still active timer with `(id : TimerId)`. For expired timers
  /// and not recognised `id`s nothing happens.
  ///
  /// ```motoko no-repl
  /// func deleteAppt(appt : Appointment) {
  ///   cancelTimer (appt.reminder);
  ///   // ...
  /// };
  /// ```
  public let cancelTimer : TimerId -> () = cancel;

}
