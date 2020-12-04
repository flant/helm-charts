{{/*
  Generate container environment variables from values.yaml.

  Usage:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | envs:
  |   ENV_VAR_1: 1
  |   ENV_VAR_2: 2
  |   ENV_VAR_3: null
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  | kind: Deployment
  | ...
  |   env: {{ include "flant-lib.generateContainerEnvVars" (list $ . .envs) | nindent 4 }}
  ————————————————————————————————————————————————————————————————————
  Results in:
  ————————————————————————————————————————————————————————————————————
  |   env:
  |   - name: ENV_VAR_1
  |     value: "1"
  |   - name: ENV_VAR_2
  |     value: "2"
  ————————————————————————————————————————————————————————————————————

  NOTE: no way to pass empty string as a value, it would cause the variable
  not to be rendered at all (TODO: although "nil" might work?)
*/}}
{{- define "flant-lib.generateContainerEnvVars" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $envs := index . 2 }}

  {{- range $envVarName, $envVarVal := $envs }}
    {{- $envVarVal = include "flant-lib.valueQuoted" (list $ $relativeScope $envVarVal) }}
    {{- if ne $envVarVal "" }}
- name: {{ $envVarName | quote }}
  value: {{ $envVarVal }}
    {{- end }}
  {{- end }}
{{- end }}
