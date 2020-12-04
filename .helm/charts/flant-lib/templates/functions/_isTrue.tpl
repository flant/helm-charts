{{/*
  Check whether boolean Value is true.

  1. Using "flant-lib.value" under the hood, so safely handles "false" boolean value.
  2. Meant to be used in if-statements:
  ————————————————————————————————————————————————————————————————————
  | {{- if include "flant-lib.isTrue" (list $ . $.Values.testBoolean) }}
  ————————————————————————————————————————————————————————————————————
  3. Can be used in the "ternary" function this way:
  ————————————————————————————————————————————————————————————————————
  | {{- ternary true false (include "flant-lib.isTrue" (list $ . $.Values.testBoolean) | not | empty) }}
  ————————————————————————————————————————————————————————————————————
*/}}
{{- define "flant-lib.isTrue" }}
  {{- ternary true "" (include "flant-lib.value" . | eq "true") }}
{{- end }}


{{/*
  Same as "flant-lib.isTrue" template, but reversed.
*/}}
{{- define "flant-lib.isFalse" }}
  {{- ternary "" true (include "flant-lib.value" . | eq "true") }}
{{- end }}
