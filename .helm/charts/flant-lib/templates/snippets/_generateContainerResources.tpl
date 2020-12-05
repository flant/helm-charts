{{/*
  Generate container resources from values.yaml.

  Usage:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | resources:
  |   requests:
  |     mcpu: 100
  |     memoryMb: 200
  |   limits:
  |     mcpu: null
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  | kind: Deployment
  | ...
  |   resources: {{ include "fl.generateContainerResources" (list $ . $.Values.resources) | nindent 4 }}
  ————————————————————————————————————————————————————————————————————
  Results in:
  ————————————————————————————————————————————————————————————————————
  |   resources:
  |     requests:
  |       cpu: 100
  |       memory: 200
  ————————————————————————————————————————————————————————————————————

  NOTE: no way to pass empty string as a value, it would cause the variable
  not to be rendered at all (TODO: although "nil" might work?)
*/}}
{{- define "fl.generateContainerResources" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $resources := index . 2 }}

  {{- range $resourceGroup, $resourceGroupVals := $resources }}
    {{- $resourceGroup | nindent 0 }}:
      {{- $mcpu := include "fl.value" (list $ . $resourceGroupVals.mcpu (dict "suffix" "m")) }}
      {{- if $mcpu }}{{ cat "cpu:" $mcpu | nindent 2 }}{{ end }}
      {{- $memoryMb := include "fl.value" (list $ . $resourceGroupVals.memoryMb (dict "suffix" "Mi")) }}
      {{- if $memoryMb }}{{ cat "memory:" $memoryMb | nindent 2 }}{{ end }}
  {{- end }}
{{- end }}
