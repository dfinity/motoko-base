// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type address = Text;
  public type block_hash = Blob;
  public type config = {
    api_access : flag;
    blocks_source : Principal;
    fees : fees;
    watchdog_canister : ?Principal;
    network : network;
    stability_threshold : Nat;
    syncing : flag;
    disable_api_if_not_fully_synced : flag;
  };
  public type fees = {
    get_current_fee_percentiles : Nat;
    get_utxos_maximum : Nat;
    get_current_fee_percentiles_maximum : Nat;
    send_transaction_per_byte : Nat;
    get_balance : Nat;
    get_utxos_cycles_per_ten_instructions : Nat;
    get_utxos_base : Nat;
    get_balance_maximum : Nat;
    send_transaction_base : Nat;
  };
  public type flag = { #disabled; #enabled };
  public type get_balance_request = {
    network : network;
    address : address;
    min_confirmations : ?Nat32;
  };
  public type get_current_fee_percentiles_request = { network : network };
  public type get_utxos_request = {
    network : network;
    filter : ?{ #page : Blob; #min_confirmations : Nat32 };
    address : address;
  };
  public type get_utxos_response = {
    next_page : ?Blob;
    tip_height : Nat32;
    tip_block_hash : block_hash;
    utxos : [utxo];
  };
  public type millisatoshi_per_byte = Nat64;
  public type network = { #mainnet; #regtest; #testnet };
  public type outpoint = { txid : Blob; vout : Nat32 };
  public type satoshi = Nat64;
  public type send_transaction_request = {
    transaction : Blob;
    network : network;
  };
  public type set_config_request = {
    api_access : ?flag;
    fees : ?fees;
    watchdog_canister : ??Principal;
    stability_threshold : ?Nat;
    syncing : ?flag;
    disable_api_if_not_fully_synced : ?flag;
  };
  public type utxo = { height : Nat32; value : satoshi; outpoint : outpoint };
  public type Self = config -> async actor {
    bitcoin_get_balance : shared get_balance_request -> async satoshi;
    bitcoin_get_current_fee_percentiles : shared get_current_fee_percentiles_request -> async [
        millisatoshi_per_byte
      ];
    bitcoin_get_utxos : shared get_utxos_request -> async get_utxos_response;
    bitcoin_send_transaction : shared send_transaction_request -> async ();
    get_config : shared query () -> async config;
    set_config : shared set_config_request -> async ();
  }
}
