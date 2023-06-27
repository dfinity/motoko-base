/// Error values and inspection.
///
/// The `Error` type is the argument to `throw`, parameter of `catch`.
/// The `Error` type is opaque.

import Prim "mo:⛔";

module {

  /// Error value resulting from  `async` computations
  public type Error = Prim.Types.Error;

  /// Error code to classify different kinds of user and system errors:
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
  ///   // Future error code (with unrecognized numeric code).
  ///   #future : Nat32;
  ///   // Error issuing inter-canister call
  ///   // (indicating destination queue full or freezing threshold crossed).
  ///   #call_error : { err_code :  Nat32 }
  /// };
  /// ```
  public type ErrorCode = Prim.ErrorCode;

  /// Create an error from the message with the code `#canister_reject`.
  ///
  /// Example:
  /// ```motoko
  /// import Error "mo:base/Error";
  ///
  /// Error.reject("Example error") // can be used as throw argument
  /// ```
  public let reject : (message : Text) -> Error = Prim.error;

  /// Returns the code of an error.
  ///
  /// Example:
  /// ```motoko
  /// import Error "mo:base/Error";
  ///
  /// let error = Error.reject("Example error");
  /// Error.code(error) // #canister_reject
  /// ```
  public let code : (error : Error) -> ErrorCode = Prim.errorCode;

  /// Returns the message of an error.
  ///
  /// Example:
  /// ```motoko
  /// import Error "mo:base/Error";
  /// import Debug "mo:base/Debug";
  ///
  /// let error = Error.reject("Example error");
  /// Error.message(error) // "Example error"
  /// ```
  public let message : (error : Error) -> Text = Prim.errorMessage;

}
