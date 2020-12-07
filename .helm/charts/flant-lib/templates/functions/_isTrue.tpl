{{- define "fl.isTrue" }}
  {{- ternary true "" (include "fl.value" . | eq "true") }}
{{- end }}


{{- define "fl.isFalse" }}
  {{- ternary "" true (include "fl.value" . | eq "true") }}
{{- end }}
