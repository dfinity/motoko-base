#!/usr/local/bin/ic-repl

function install(wasm, args) {
  import interface = "2vxsx-fae" as ".dfx/local/canisters/singleBTree/singleBTree.did";
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
  import interface = "2vxsx-fae" as ".dfx/local/canisters/singleBTree/singleBTree.did";
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
  import interface = "2vxsx-fae" as ".dfx/local/canisters/singleBTree/singleBTree.did";
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

// Create a BTree
let btree_canister = install(file(".dfx/local/canisters/singleBTree/singleBTree.wasm"), args);
// Verify it is empty
call btree_canister.getLength();
assert _ == (0 : nat64);
// Insert a pair of key/value
call btree_canister.insert(12345, "hello");
assert _ == variant { ok = null : opt record{} };
// Verify the Btree contains the pair of key/value
call btree_canister.getLength();
assert _ == (1 : nat64);
call btree_canister.get(12345);
assert _ == opt("hello" : text);

// The BTree shall be preserved after an upgrade
upgrade(btree_canister, file(".dfx/local/canisters/singleBTree/singleBTree.wasm"), args);
call btree_canister.getLength();
assert _ == (1 : nat64);
call btree_canister.get(12345);
assert _ == opt("hello" : text);

// The BTree shall be empty after a reinstall
reinstall(btree_canister, file(".dfx/local/canisters/singleBTree/singleBTree.wasm"), args);
call btree_canister.getLength();
assert _ == (0 : nat64);
call btree_canister.get(12345);
assert _ == (null : opt record{});