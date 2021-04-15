{{- define "fl.generateSelectorLabels" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $appName := index . 2 }}
app: {{ $appName | quote }}
{{- end }}
