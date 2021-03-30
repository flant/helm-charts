{{- define "fl.isTrue" }}
  {{- ternary true "" (include "fl.value" . | eq "true") }}
{{- end }}
