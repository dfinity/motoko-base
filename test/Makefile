# Deprecated in favor of running `npm test` in the root directory

STDLIB ?= ../src
MOC ?= moc
WASMTIME_OPTIONS = -C cache=n -W nan-canonicalization=y -W multi-memory -W bulk-memory

OUTDIR=_out

TESTS = $(wildcard *.mo)

TEST_TARGETS = $(patsubst %.mo,_out/%.checked,$(TESTS))

all: $(OUTDIR)/import_all.checked $(TEST_TARGETS)

STDLIB_FILES= $(wildcard $(STDLIB)/*.mo)

VESSEL_PKGS= $(shell vessel sources)

$(OUTDIR):
	@mkdir $@

$(OUTDIR)/import_all.mo: $(STDLIB_FILES) | $(OUTDIR)
	> $@
	for f in $(patsubst $(STDLIB)/%.mo,%,$(STDLIB_FILES)); do \
	  echo "import _Import_$$f \"mo:base/$$f\";" >> $@; \
	done

$(OUTDIR)/%.wasm: %.mo | $(OUTDIR)
	$(MOC) -c --package base $(STDLIB) $(VESSEL_PKGS) -wasi-system-api -o $@ $<

$(OUTDIR)/%.wasm: $(OUTDIR)/%.mo | $(OUTDIR)
	$(MOC) -c --package base $(STDLIB) $(VESSEL_PKGS) -wasi-system-api -o $@ $<

$(OUTDIR)/%.checked: $(OUTDIR)/%.wasm
	wasmtime run $(WASMTIME_OPTIONS) $<
	touch $@

clean:
	rm -rf $(OUTDIR)

.PRECIOUS: $(OUTDIR)/%.wasm
