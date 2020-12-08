{{- define "fl.generateConfigMapEnvVars" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $envs := index . 2 }}

  {{- range $envVarName, $envVarVal := $envs }}
    {{- $envVarVal = include "fl.valueQuoted" (list $ $relativeScope $envVarVal) }}
    {{- if ne $envVarVal "" }}
{{ $envVarName | quote }}: {{ $envVarVal }}
    {{- end }}
  {{- end }}
{{- end }}

