default:
	$(shell vessel bin)/moc $(shell vessel sources) -wasi-system-api -o suite.wasm suite.mo && wasmtime suite.wasm
	rm -f suite.wasm
