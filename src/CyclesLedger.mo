module {
  public type Account = { owner : Principal; subaccount : ?Subaccount };
  public type BlockIndex = Nat;
  public type Duration = Nat64;
  public type RejectionCode = {
    #NoError;
    #CanisterError;
    #SysTransient;
    #DestinationInvalid;
    #Unknown;
    #SysFatal;
    #CanisterReject
  };
  public type SendArg = {
    to : Principal;
    fee : ?Nat;
    memo : ?Blob;
    from_subaccount : ?Subaccount;
    created_at_time : ?Timestamp;
    amount : Nat
  };
  public type SendError = { fee_block : BlockIndex; reason : SendErrorReason };
  public type SendErrorReason = {
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #FailedToSend : { rejection_code : RejectionCode; rejection_reason : Text };
    #Duplicate : { duplicate_of : BlockIndex };
    #BadFee : { expected_fee : Nat };
    #InvalidReceiver : { receiver : Principal };
    #CreatedInFuture : { ledger_time : Timestamp };
    #TooOld;
    #InsufficientFunds : { balance : Nat }
  };
  public type Subaccount = Blob;
  public type Timestamp = Nat64;
  public type TransferArgs = {
    to : Account;
    fee : ?Nat;
    memo : ?Blob;
    from_subaccount : ?Subaccount;
    created_at_time : ?Timestamp;
    amount : Nat
  };
  public type TransferError = {
    #GenericError : { message : Text; error_code : Nat };
    #TemporarilyUnavailable;
    #BadBurn : { min_burn_amount : Nat };
    #Duplicate : { duplicate_of : BlockIndex };
    #BadFee : { expected_fee : Nat };
    #CreatedInFuture : { ledger_time : Timestamp };
    #TooOld;
    #InsufficientFunds : { balance : Nat }
  };
  public type Value = { #Int : Int; #Nat : Nat; #Blob : Blob; #Text : Text };
  public type Self = actor {
    deposit : shared { to : Account; memo : ?Blob } -> async {
      balance : Nat;
      txid : BlockIndex
    };
    icrc1_balance_of : shared query Account -> async Nat;
    icrc1_decimals : shared query () -> async Nat8;
    icrc1_fee : shared query () -> async Nat;
    icrc1_metadata : shared query () -> async [(Text, Value)];
    icrc1_minting_account : shared query () -> async ?Account;
    icrc1_name : shared query () -> async Text;
    icrc1_supported_standards : shared query () -> async [{
      url : Text;
      name : Text
    }];
    icrc1_symbol : shared query () -> async Text;
    icrc1_total_supply : shared query () -> async Nat;
    icrc1_transfer : shared TransferArgs -> async {
      #Ok : BlockIndex;
      #Err : TransferError
    };
    send : shared SendArg -> async { #Ok : BlockIndex; #Err : SendError }
  }
}
