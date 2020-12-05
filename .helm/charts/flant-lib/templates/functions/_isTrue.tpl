{{/*
  Check whether boolean Value is true.

  1. Using "fl.value" under the hood, so safely handles "false" boolean value.
  2. Meant to be used in if-statements:
  ————————————————————————————————————————————————————————————————————
  | {{- if include "fl.isTrue" (list $ . $.Values.testBoolean) }}
  ————————————————————————————————————————————————————————————————————
  3. Can be used in the "ternary" function this way:
  ————————————————————————————————————————————————————————————————————
  | {{- ternary true false (include "fl.isTrue" (list $ . $.Values.testBoolean) | not | empty) }}
  ————————————————————————————————————————————————————————————————————
*/}}
{{- define "fl.isTrue" }}
  {{- ternary true "" (include "fl.value" . | eq "true") }}
{{- end }}


{{/*
  Same as "fl.isTrue" template, but reversed.
*/}}
{{- define "fl.isFalse" }}
  {{- ternary "" true (include "fl.value" . | eq "true") }}
{{- end }}
