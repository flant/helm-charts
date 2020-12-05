{{/*
  Generate labels.

  Usage:
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  | {{- $appName := printf "%s-sidekiq" $.Values.global.werf.name }}
  | kind: Deployment
  | metadata:
  |   labels: {{ include "fl.generateLabels" (list $ . $appName) | nindent 4 }}
  ————————————————————————————————————————————————————————————————————
*/}}
{{- define "fl.generateLabels" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $appName := index . 2 }}
app: {{ $appName | quote }}
chart: {{ $.Chart.Name | trunc 63 | quote }}
repo: {{ regexSplit "/" $.Values.global.werf.repo -1 | rest | join "-" | trunc 63 | quote }}
{{- end }}
