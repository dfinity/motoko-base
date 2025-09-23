import { HttpAgent, Actor } from "@dfinity/agent";
import { idlFactory } from "./.dfx/local/canisters/singleBTree/singleBTree.did.js";
import fetch from "node-fetch";
import { test } from "tape";
// From https://stackoverflow.com/a/74018376/6021706
import { createRequire } from "module";          
const require = createRequire(import.meta.url);
const canister_ids = require("./.dfx/local/canister_ids.json");

global.fetch = fetch;

const agent = new HttpAgent({
  host: "http://127.0.0.1:4943/"
});

agent.fetchRootKey().catch((err) => {
  console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
  console.error(err);
});

const single_b_tree = Actor.createActor(idlFactory, {
  agent: agent,
  canisterId: canister_ids["singleBTree"]["local"]
});

let NUM_INSERTIONS = 5000;

test('random_insertions', async function (t) {
  // Remove previous entries in the btree if any
  await single_b_tree.empty();
  t.equal(await single_b_tree.getLength(), 0n);

  // Insert NUM_INSERTIONS random entries
  let random_keys = [];
  for (var i=0; i<NUM_INSERTIONS; i++){
    let random = Math.random();
    let power = Math.trunc(Math.random() * 32);
    let random_nat32 = Math.trunc(random * 2 ** power);
    random_keys.push(random_nat32);
  };

  const entries = random_keys.map(key => [key, key.toString()]);

  // Verify the insertion works
  t.ok(await single_b_tree.insertMany(entries));

  const unique_keys = [...new Set(random_keys)];

  // Verify the length of the btree
  t.equal(await single_b_tree.getLength(), BigInt(unique_keys.length));

  // Verify retrieving each value works (use join to compare array's content)
  t.equal((await single_b_tree.getMany(unique_keys)).join(""), unique_keys.map(key => key.toString()).join(""));
});

test('increasing_insertions', async function (t) {
  // Remove previous entries in the btree if any
  await single_b_tree.empty();
  t.equal(await single_b_tree.getLength(), 0n);

  // Insert NUM_INSERTIONS increasing entries
  let entries = [];
  for (var i=0; i<NUM_INSERTIONS; i++){
    entries.push([i, i.toString()]);
  };
  let keys = entries.map(entry => entry[0]);
  let values = entries.map(entry => entry[1]);

  // Verify the insertion works
  t.ok(await single_b_tree.insertMany(entries));
  // Verify the length of the btree
  t.equal(await single_b_tree.getLength(), BigInt(entries.length));
  // Verify retrieving each value works (use join to compare array's content)
  t.equal((await single_b_tree.getMany(keys)).join(""), values.join(""));
});

test('decreasing_insertions', async function (t) {
  // Remove previous entries in the btree if any
  await single_b_tree.empty();
  t.equal(await single_b_tree.getLength(), 0n);

  // Insert NUM_INSERTIONS decreasing entries
  let entries = [];
  for (var i=(NUM_INSERTIONS-1); i >= 0; i--){
    entries.push([i, i.toString()]);
  };
  let keys = entries.map(entry => entry[0]);
  let values = entries.map(entry => entry[1]);

  // Verify the insertion works
  t.ok(await single_b_tree.insertMany(entries));
  // Verify the length of the btree
  t.equal(await single_b_tree.getLength(), BigInt(entries.length));
  // Verify retrieving each value works (use join to compare array's content)
  t.equal((await single_b_tree.getMany(keys)).join(""), values.join(""));
});