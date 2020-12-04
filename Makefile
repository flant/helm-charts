# Don't use this, this is deprecated

TERM ?= xterm
SHELL = /bin/bash

WERF_VERSION ?= 1.1 ea
WERF_ENV ?= test
WERF_SET_90 ?= global.ci_url=example.org
WERF_SET_91 ?= $(CHART_NAME).enabled=true
WERF_SET_92 ?= global.werf.repo=example.org/repogroup/repo

LOAD_WERF = source <(multiwerf use $(WERF_VERSION))
WERF_RENDER_COMMAND = werf helm render | tail -n +6 | grep -vE '(^\#)|(werf.io/version)' | yq -sy --indentless 'sort_by(.apiVersion,.kind,.metadata.name)[]'

.EXPORT_ALL_VARIABLES:
.PHONY: check-required-envs render lint run-render-tests render-expected-output-for-render-tests save-expected-output-for-render-tests

render: check-required-envs
	$(LOAD_WERF) && \
	$(WERF_RENDER_COMMAND)

lint: CHART = $(CHART_NAME)
lint: check-required-envs
	$(LOAD_WERF) && \
	werf helm lint && \
	werf helm lint --env prod

run-render-tests: check-required-envs
	$(LOAD_WERF) && \
	export WERF_VALUES_1=".helm/charts/$(CHART_NAME)/render-tests/values.yaml" && \
	werf helm lint && \
	diff -u --color=always \
		<(cat .helm/charts/$(CHART_NAME)/render-tests/expected-render.yaml) \
		<($(WERF_RENDER_COMMAND)) && \
	{ tput setaf 2; echo "Tests passed successfully."; tput sgr 0; }

render-expected-output-for-render-tests: check-required-envs
	$(LOAD_WERF) && \
	export WERF_VALUES_1=".helm/charts/$(CHART_NAME)/render-tests/values.yaml" && \
	werf helm lint && \
	$(WERF_RENDER_COMMAND)

save-expected-output-for-render-tests: check-required-envs
	$(LOAD_WERF) && \
	export WERF_VALUES_1=".helm/charts/$(CHART_NAME)/render-tests/values.yaml" && \
	werf helm lint && \
	$(WERF_RENDER_COMMAND) > .helm/charts/$(CHART_NAME)/render-tests/expected-render.yaml

check-required-envs:
ifndef CHART_NAME
	$(error CHART_NAME env var is required but undefined)
endif
