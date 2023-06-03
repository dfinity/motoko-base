default:
	dfx stop
	dfx start --clean --background
	dfx deploy singleBTree --argument='(record {max_key_size=32; max_value_size=128})'
	ic-repl testSingle.sh
	npm install
	node testSingle.js
	dfx deploy multipleBTrees --argument='(record {max_key_size=32; max_value_size=128})'
	ic-repl testMultiple.sh