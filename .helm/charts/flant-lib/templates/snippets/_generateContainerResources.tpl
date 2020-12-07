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
