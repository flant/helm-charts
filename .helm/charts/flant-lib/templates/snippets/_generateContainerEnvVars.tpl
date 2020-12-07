{{- define "fl.generateContainerEnvVars" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $envs := index . 2 }}

  {{- range $envVarName, $envVarVal := $envs }}
    {{- $envVarVal = include "fl.valueQuoted" (list $ $relativeScope $envVarVal) }}
    {{- if ne $envVarVal "" }}
- name: {{ $envVarName | quote }}
  value: {{ $envVarVal }}
    {{- end }}
  {{- end }}
{{- end }}
