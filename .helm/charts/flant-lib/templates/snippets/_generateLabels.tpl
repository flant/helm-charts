{{- define "fl.generateLabels" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $appName := index . 2 }}
app: {{ $appName | quote }}
chart: {{ $.Chart.Name | trunc 63 | quote }}
repo: {{ regexSplit "/" $.Values.global.werf.repo -1 | rest | join "-" | trunc 63 | quote }}
{{- end }}
