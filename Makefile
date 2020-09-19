ENV ?= "test"
GLOBAL_CI_URL ?= "example.org"
SHELL = /bin/bash
WERF_HELM_BASE_COMMAND = source <(multiwerf use 1.1 ea) && werf helm --values=.helm/charts/$(CHART)/tests/values.yaml --env $(ENV) --set 'global.ci_url=$(GLOBAL_CI_URL),$(CHART)._enabled=true'
WERF_HELM_RENDER_COMMAND = $(WERF_HELM_BASE_COMMAND) render | tail -n +6 | grep -vE '(^\#)|(werf.io/version)' | yq -sy --indentless 'sort_by(.apiVersion,.kind,.metadata.name)[]'

.PHONY: check-required-envs render test test-generate-expected-output

check-required-envs:
ifndef CHART
	$(error CHART env var is required but undefined)
endif

render: check-required-envs
	$(WERF_HELM_RENDER_COMMAND)

lint: check-required-envs
	$(WERF_HELM_BASE_COMMAND) lint

test: check-required-envs lint
	dyff between -s <(cat .helm/charts/$(CHART)/tests/expected-render.yaml) <($(WERF_HELM_RENDER_COMMAND))
	echo "Tests passed successfully."

test-generate-expected-output: check-required-envs
	$(WERF_HELM_RENDER_COMMAND) > .helm/charts/$(CHART)/tests/expected-render.yaml

helm: check-required-envs
ifndef COMMAND
	$(error COMMAND env var is required but undefined)
endif
	$(WERF_HELM_BASE_COMMAND) $(COMMAND)
