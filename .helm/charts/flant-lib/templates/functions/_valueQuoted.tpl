{{- define "fl.valueQuoted" }}
  {{- $result := include "fl.value" . }}
  {{- if ne $result "" }}
    {{- $result | quote }}
  {{- end }}
{{- end }}
