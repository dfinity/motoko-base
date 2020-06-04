STDLIB ?= ../src

SHELL=bash


STDLIB_FILES= $(patsubst $(STDLIB)/%.mo,%,$(wildcard $(STDLIB)/*.mo))

INPUTS = $(patsubst %,$(STDLIB)/%.mo,$(STDLIB_FILES))
DOCS = $(patsubst %,_build/%.adoc,$(STDLIB_FILES))

ADOCS = _build/index.adoc $(DOCS)

all: _out/index.html

adocs: $(ADOCS)

clean:
	rm -rf _out _build

_out:
	@mkdir -p $@

_build:
	@mkdir -p $@

$(DOCS) : $(INPUTS)  | _build
	mo-doc --source $(STDLIB) --output _build --format adoc

_build/index.adoc: index.adoc | _build
	cp $< $@

_out/index.html: _build/index.adoc $(DOCS) | _out
	# checking if all files are included
	@diff -u \
	  --label "Present" \
	  <(echo $(STDLIB_FILES)| tr ' ' '\n' |sort) \
	  --label "Included" \
	  <(perl -n -e 'print "$$1\n" if m,include::(.*)\.adoc,' $< | sort) \
	 # ok

	asciidoctor $< -o $@

.PHONY: all clean adocs
