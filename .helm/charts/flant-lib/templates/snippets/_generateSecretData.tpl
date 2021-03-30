{{- define "fl.generateSecretData" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $data := index . 2 }}

  {{- range $key, $value := $data }}
    {{- $value = include "fl.value" (list $ $relativeScope $value) }}
    {{- if eq $value "___FL_THIS_ENV_VAR_WILL_BE_DEFINED_BUT_EMPTY___" }}
{{ $key | quote }}: ""
    {{- else if ne $value "" }}
{{ $key | quote }}: {{ $value | b64enc | quote }}
    {{- end }}
  {{- end }}
{{- end }}
