{{- define "fl.valueSingleQuoted" }}
  {{- $result := include "fl.value" . }}
  {{- if ne $result "" }}
    {{- $result | squote }}
  {{- end }}
{{- end }}
