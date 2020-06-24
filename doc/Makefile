MO_DOC ?= ../bin/mo-doc
SHELL=bash

all: html | adocs

adocs: _out
	$(MO_DOC) --source ../src --output _out/adoc --format adoc
html: _out
	$(MO_DOC) --source ../src --output _out/html --format html

clean:
	rm -rf _out

_out:
	@mkdir -p $@

.PHONY: all clean adocs html
