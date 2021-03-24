# -*- coding: utf-8 -*-
#
# Copyright (c) 2008-2021 The pip developers
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# SPDX-License-Identifier: MIT

# Use bash even on Windows
SHELL := /bin/bash

# On Windows the activate script is stored in a different location.
ACTIVATE_SCRIPT := venv/bin/activate
ifeq ($(OS),Windows_NT)
ACTIVATE_SCRIPT := venv/Scripts/activate
endif

ACTIVATE=[[ -e $(ACTIVATE_SCRIPT) ]] && source $(ACTIVATE_SCRIPT);

clean:
	rm -rf build dist pythondata_*.egg-info

.PHONY: clean

venv-clean:
	rm -rf venv

.PHONY: venv-clean

$(ACTIVATE_SCRIPT): requirements.txt setup.py Makefile
	make venv
	@ls -l $(ACTIVATE_SCRIPT)
	@touch $(ACTIVATE_SCRIPT)
	@ls -l $(ACTIVATE_SCRIPT)

venv:
	virtualenv --python=python3 --always-copy venv
	# Packaging tooling.
	${ACTIVATE} pip install -U pip twine build
	# Setup requirements.
	${ACTIVATE} pip install -r requirements.txt
	@${ACTIVATE} python -c "from requirements.version import version as v; print('Installed version:', v)"
	# Infra requirements.
	${ACTIVATE} pip install git+https://github.com/mithro/actions-includes.git

.PHONY: venv

# Packaging and uploading to PyPI
build: | $(ACTIVATE_SCRIPT)
	${ACTIVATE} python -m build --sdist
	${ACTIVATE} python -m build --wheel

.PHONY: build

PYPI_TEST = --repository-url https://test.pypi.org/legacy/
upload-test: | $(ACTIVATE_SCRIPT)
	make clean
	make build
	${ACTIVATE} twine upload ${PYPI_TEST} dist/*

.PHONY: upload-test

upload: | $(ACTIVATE_SCRIPT)
	make clean
	make build
	${ACTIVATE} twine upload --verbose dist/*

.PHONY: upload

check: | $(ACTIVATE_SCRIPT)
	make clean
	make build
	${ACTIVATE} twine check dist/*.whl

.PHONY: check

install: | $(ACTIVATE_SCRIPT)
	${ACTIVATE} python setup.py install

.PHONY: install

# Testing the library
TEST_LIKE_CI_RUN_SH := venv/actions/includes/actions/python/run-installed-tests/run.sh
$(TEST_LIKE_CI_RUN_SH):
	if [ ! -d venv/actions ]; then git clone https://github.com/SymbiFlow/actions venv/actions; fi
	cd venv/actions && git pull

test-like-ci: | $(TEST_LIKE_CI_RUN_SH) $(ACTIVATE_SCRIPT)
	${ACTIVATE} $(TEST_LIKE_CI_RUN_SH)

.PHONY: test-like-ci

test: | $(ACTIVATE_SCRIPT)
	${ACTIVATE} pytest

.PHONY: test

version: | $(ACTIVATE_SCRIPT)
	${ACTIVATE} python setup.py --version

.PHONY: version

# Format the code
GHA_WORKFLOW_SRCS = $(wildcard .github/workflows-src/*.yml)
GHA_WORKFLOW_OUTS = $(addprefix .github/workflows/,$(notdir $(GHA_WORKFLOW_SRCS)))

.github/workflows/%.yml: .github/workflows-src/%.yml | $(ACTIVATE_SCRIPT)
	${ACTIVATE} python -m actions_includes $< $@

format-gha: $(GHA_WORKFLOW_OUTS) | $(ACTIVATE_SCRIPT)
	@echo $(GHA_WORKFLOW_OUTS)
	@true

.PHONY: format-gha

format:
	$(MAKE) format-gha

.PHONY: format
