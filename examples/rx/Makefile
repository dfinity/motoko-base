STDLIB ?= ../../src
MOC ?= ../../bin/moc
WASMTIME_OPTIONS = --disable-cache --cranelift

OUTDIR=_out

all: $(OUTDIR)/test.out

$(OUTDIR):
	@mkdir $@

$(OUTDIR)/Test.wasm: test/RxTest.mo src/*.mo | $(OUTDIR)
	$(MOC) -c --package base $(STDLIB) -wasi-system-api -o $@ $<

$(OUTDIR)/test.out: $(OUTDIR)/Test.wasm
	wasmtime $(WASMTIME_OPTIONS) $<


clean:
	rm -rf $(OUTDIR)
