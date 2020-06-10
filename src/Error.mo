/// Error type, argument to throw, parameter of catch

import Prim "mo:prim";

module {
 
  // Prim.ErrorCode
  /// Error codes (user and system)
  public type ErrorCode = {
    /// Fatal error.
    #system_fatal;
    /// Transient error;
    #system_transient;
    /// Destination invalid.
    #destination_invalid;
    /// Explicit reject by canister code.
    #canister_reject;
    /// Canister trapped.
    #canister_error;
    /// (unknown) future error code
    #future : Nat32;
  };

  /// Create an error from message with ErrorCode #canister_reject.
  public let error : Text -> Error = Prim.error;

  /// Return the ErrorCode of an error.
  public let errorCode : Error -> ErrorCode = Prim.errorCode;

  /// Return the message of an error.
  public let errorMessage : Error -> Text = Prim.errorMessage;

}
