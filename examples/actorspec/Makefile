STDLIB ?= ../../src
MOC ?= ../../../src/moc
WASMTIME_OPTIONS = --disable-cache --cranelift

OUTDIR=_out

all: $(OUTDIR)/demo.out

$(OUTDIR):
	@mkdir $@

$(OUTDIR)/ActorSpecDemo.wasm: demo/Demo.mo src/*.mo | $(OUTDIR)
	$(MOC) -c --package base $(STDLIB) -wasi-system-api -o $@ $<

$(OUTDIR)/demo.out: $(OUTDIR)/ActorSpecDemo.wasm
	wasmtime $(WASMTIME_OPTIONS) $<


clean:
	rm -rf $(OUTDIR)
