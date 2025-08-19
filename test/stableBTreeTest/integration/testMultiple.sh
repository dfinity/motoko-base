#!/usr/local/bin/ic-repl

function install(wasm, args) {
  import interface = "2vxsx-fae" as ".dfx/local/canisters/multipleBTrees/multipleBTrees.did";
  let id = call ic.provisional_create_canister_with_cycles(record { settings = null; amount = null; });
  call ic.install_code(
    record {
      arg = encode interface.__init_args(args);
      wasm_module = wasm;
      mode = variant { install };
      canister_id = id.canister_id;
    }
  );
  id.canister_id
};

function upgrade(canister_id, wasm, args) {
  import interface = "2vxsx-fae" as ".dfx/local/canisters/multipleBTrees/multipleBTrees.did";
  call ic.install_code(
    record {
      arg = encode interface.__init_args(args);
      wasm_module = wasm;
      mode = variant { upgrade };
      canister_id = canister_id;
    }
  );
};

function reinstall(canister_id, wasm, args) {
  import interface = "2vxsx-fae" as ".dfx/local/canisters/multipleBTrees/multipleBTrees.did";
  call ic.install_code(
    record {
      arg = encode interface.__init_args(args);
      wasm_module = wasm;
      mode = variant { reinstall };
      canister_id = canister_id;
    }
  );
};

let args = record { max_key_size = 32; max_value_size = 128; };

// Create the canister
let multiple_btrees = install(file(".dfx/local/canisters/multipleBTrees/multipleBTrees.wasm"), args);

// Use a first btreemap of identifier 0
call multiple_btrees.getLength(0);
assert _ == (0 : nat64);
call multiple_btrees.insert(0, 12345, "hello");
assert _ == variant { ok = null : opt record{} };
call multiple_btrees.getLength(0);
assert _ == (1 : nat64);
call multiple_btrees.get(0, 12345);
assert _ == opt("hello" : text);

// Use a second btreemap of identifier 1
call multiple_btrees.getLength(1);
assert _ == (0 : nat64);
call multiple_btrees.get(1, 12345);
assert _ == (null : opt record{});
call multiple_btrees.insert(1, 67890, "hi");
call multiple_btrees.insert(1, 45678, "ola");
call multiple_btrees.insert(1, 34567, "salut");
assert _ == variant { ok = null : opt record{} };
call multiple_btrees.getLength(1);
assert _ == (3 : nat64);
call multiple_btrees.get(1, 67890);
assert _ == opt("hi" : text);
call multiple_btrees.get(1, 45678);
assert _ == opt("ola" : text);
call multiple_btrees.get(1, 34567);
assert _ == opt("salut" : text);

// Both BTrees shall be preserved after an upgrade
upgrade(multiple_btrees, file(".dfx/local/canisters/multipleBTrees/multipleBTrees.wasm"), args);
call multiple_btrees.getLength(0);
assert _ == (1 : nat64);
call multiple_btrees.get(0, 12345);
assert _ == opt("hello" : text);
call multiple_btrees.getLength(1);
assert _ == (3 : nat64);
call multiple_btrees.get(1, 67890);
assert _ == opt("hi" : text);
call multiple_btrees.get(1, 45678);
assert _ == opt("ola" : text);
call multiple_btrees.get(1, 34567);
assert _ == opt("salut" : text);

// Both BTrees shall be emptied after a reinstall
reinstall(multiple_btrees, file(".dfx/local/canisters/multipleBTrees/multipleBTrees.wasm"), args);
call multiple_btrees.getLength(0);
assert _ == (0 : nat64);
call multiple_btrees.get(0, 12345);
assert _ == (null : opt record{});
call multiple_btrees.getLength(1);
assert _ == (0 : nat64);
call multiple_btrees.get(1, 67890);
assert _ == (null : opt record{});
call multiple_btrees.get(1, 45678);
assert _ == (null : opt record{});
call multiple_btrees.get(1, 34567);
assert _ == (null : opt record{});
