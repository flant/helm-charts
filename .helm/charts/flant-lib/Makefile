TERM ?= xterm
SHELL = /bin/bash

WERF_VERSION ?= 1.1 ea
WERF_ENV ?= test
WERF_VALUES_1 ?= .helm/charts/flant-lib/tests/render/values.yaml
WERF_SET_90 ?= flant-lib.enabled=true
WERF_SET_91 ?= global.ci_url=example.org
WERF_SET_92 ?= global.werf.repo=example.org/repogroup/repo

charts_to_disable := $(shell find .helm/charts -mindepth 1 -maxdepth 1 -type d -exec sh -c 'basename "$$0"' '{}' \; | grep -v "flant-lib")
sets_charts_to_disable := $(shell for chart in $(charts_to_disable); do echo "$$chart" | awk '{printf(" --set %s.enabled=false", $$1)}'; done)

.EXPORT_ALL_VARIABLES:
.PHONY: test render save-as-expected-render

test:
	source <(multiwerf use $(WERF_VERSION)) && \
	werf helm lint $(sets_charts_to_disable) && \
	diff -u --color=always <(cat .helm/charts/flant-lib/tests/render/expected-render.yaml) <( \
		werf helm render $(sets_charts_to_disable) | tail -n +6 | grep -vE '(^\#)|(werf.io/version)' | yq -sy --indentless 'sort_by(.apiVersion,.kind,.metadata.name)[]' \
	)

render:
	source <(multiwerf use $(WERF_VERSION)) && \
	werf helm lint $(sets_charts_to_disable) && \
	werf helm render $(sets_charts_to_disable) | tail -n +6 | grep -vE '(^\#)|(werf.io/version)' | yq -sy --indentless 'sort_by(.apiVersion,.kind,.metadata.name)[]'

update-expected-render:
	source <(multiwerf use $(WERF_VERSION)) && \
	werf helm lint $(sets_charts_to_disable) && \
	werf helm render $(sets_charts_to_disable) | tail -n +6 | grep -vE '(^\#)|(werf.io/version)' | yq -sy --indentless 'sort_by(.apiVersion,.kind,.metadata.name)[]' > .helm/charts/flant-lib/tests/render/expected-render.yaml
