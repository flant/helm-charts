{{- define "fl.isFalse" }}
  {{- ternary "" true (include "fl.value" . | eq "true") }}
{{- end }}
