# Deprecated in favor of running `npm test` in the root directory

STDLIB ?= ../src
MOC ?= moc
WASMTIME_OPTIONS = -C cache=n -W nan-canonicalization=y -W memory64 -W multi-memory -W bulk-memory

OUTDIR=_out

TESTS = $(wildcard *.mo) # FIXME somehow add StableBTreeTest into suite

TEST_CLASSICAL_TARGETS = $(patsubst %.mo,_out/%.classical.checked,$(TESTS))
TEST_ENHANCED_TARGETS = $(patsubst %.mo,_out/%.enhanced.checked,$(TESTS))

all: $(OUTDIR)/import_all.classical.checked \
	$(OUTDIR)/import_all.enhanced.checked \
	$(TEST_CLASSICAL_TARGETS) \
	$(TEST_ENHANCED_TARGETS)

STDLIB_FILES= $(wildcard $(STDLIB)/*.mo)

VESSEL_PKGS= $(shell vessel sources)

MOC_COMMON_FLAGS=-c --package base $(STDLIB) $(VESSEL_PKGS) -wasi-system-api
MOC_CLASSICAL=$(MOC) $(MOC_COMMON_FLAGS)
MOC_ENHANCED=$(MOC) $(MOC_COMMON_FLAGS) --enhanced-orthogonal-persistence

$(OUTDIR):
	@mkdir $@

$(OUTDIR)/import_all.mo: $(STDLIB_FILES) | $(OUTDIR)
	> $@
	for f in $(patsubst $(STDLIB)/%.mo,%,$(STDLIB_FILES)); do \
	  echo "import _Import_$$f \"mo:base/$$f\";" >> $@; \
	done

$(OUTDIR)/%.classical.wasm: %.mo | $(OUTDIR)
	$(MOC_CLASSICAL) -o $@ $<

$(OUTDIR)/%.enhanced.wasm: %.mo | $(OUTDIR)
	$(MOC_ENHANCED) -o $@ $<

$(OUTDIR)/import_all.classical.wasm: $(OUTDIR)/import_all.mo | $(OUTDIR)
	$(MOC_CLASSICAL) -o $@ $<

$(OUTDIR)/import_all.enhanced.wasm: $(OUTDIR)/import_all.mo | $(OUTDIR)
	$(MOC_ENHANCED) -o $@ $<

$(OUTDIR)/%.checked: $(OUTDIR)/%.wasm
	wasmtime run $(WASMTIME_OPTIONS) $<
	touch $@

clean:
	rm -rf $(OUTDIR)

.PRECIOUS: $(OUTDIR)/%.wasm
