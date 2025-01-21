/// Timers for one-off or periodic tasks. Applicable as part of the default mechanism.
///
/// Note: If `moc` is invoked with `-no-timer`, the importing will fail.
///
/// Note: The resolution of the timers is in the order of the block rate,
///       so durations should be chosen well above that. For frequent
///       canister wake-ups the heartbeat mechanism should be considered.
///
/// Note: The functionality described below is enabled only when the actor does not override it by declaring an explicit `system func timer`.
///
/// Note: Timers are _not_ persisted across upgrades. One possible strategy
///       to re-establish timers after an upgrade is to walk stable variables
///       in the `post_upgrade` hook and distill necessary timer information
///       from there.
///
/// Note: Basing security (e.g. access control) on timers is almost always
///       the wrong choice. Be sure to inform yourself about state-of-the art
///       dApp security. If you _must use_ timers for security controls, be sure
///       to consider reentrancy issues, and the vanishing of timers on upgrades
///       and reinstalls.
///
/// Note: For further usage information for timers on the IC please consult
///       https://internetcomputer.org/docs/current/developer-docs/backend/periodic-tasks#timers-library-limitations
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
  public func setTimer<system>(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano<system>(toNanos d, false, job)
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
  public func recurringTimer<system>(d : Duration, job : () -> async ()) : TimerId {
    setTimerNano<system>(toNanos d, true, job)
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
