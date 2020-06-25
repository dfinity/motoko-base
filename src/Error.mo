/// Error type, argument to throw, parameter of catch

/// The Error type is opaque.
/// Its values are constructed and accessed with the following operations.

import Prim "mo:prim";

module {

  /// Error codes (user and system), where module `Prim` defines:
  /// ```motoko
  /// type ErrorCode = {
  ///   // Fatal error.
  ///   #system_fatal;
  ///   // Transient error.
  ///   #system_transient;
  ///   // Destination invalid.
  ///   #destination_invalid;
  ///   // Explicit reject by canister code.
  ///   #canister_reject;
  ///   // Canister trapped.
  ///   #canister_error;
  ///   // Future error code (with unrecognized numeric code)
  ///   #future : Nat32;
  /// };
  /// ```
  public type ErrorCode = Prim.ErrorCode;

  /// Create an error from message `m` with code #canister_reject.
  public let error : (m : Text) -> Error = Prim.error;

  /// Returns the code of an error `e`.
  public let errorCode : ( e : Error) -> ErrorCode = Prim.errorCode;

  /// Returns the message of an error `e`.
  public let errorMessage : ( e: Error) -> Text = Prim.errorMessage;

}
