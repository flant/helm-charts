{{- define "fl.generateSecretEnvVars" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $envs := index . 2 }}

  {{- range $envVarName, $envVarVal := $envs }}
    {{- $envVarVal = include "fl.value" (list $ $relativeScope $envVarVal) }}
    {{- if eq $envVarVal "___FL_THIS_ENV_VAR_WILL_BE_DEFINED_BUT_EMPTY___" }}
{{ $envVarName | quote }}: ""
    {{- else if ne $envVarVal "" }}
{{ $envVarName | quote }}: {{ $envVarVal | b64enc | quote }}
    {{- end }}
  {{- end }}
{{- end }}
