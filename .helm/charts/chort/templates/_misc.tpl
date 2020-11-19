{{/*
  Check whether boolean Value is true.

  1. Using "val" under the hood, so safely handles "false" boolean value.
  2. Meant to be used in if-statements:
  ————————————————————————————————————————————————————————————————————
  | {{- if include "c.isTrue" (list $ . $.Values.testBoolean) }}
  ————————————————————————————————————————————————————————————————————
  3. Can be used in the "ternary" function this way:
  ————————————————————————————————————————————————————————————————————
  | {{- ternary true false (include "c.isTrue" (list $ . $.Values.testBoolean) | not | empty) }}
  ————————————————————————————————————————————————————————————————————
*/}}
{{- define "c.isTrue" }}
  {{- ternary true "" (include "c.val" . | eq "true") }}
{{- end }}


{{/*
  Same as "isTrue" template, but reversed.
*/}}
{{- define "c.isFalse" }}
  {{- ternary "" true (include "c.val" . | eq "true") }}
{{- end }}


{{/* TODO: refactor, document */}}
{{- define "c.percentage" }}
  {{- $num := index . 0 }}
  {{- $percents := index . 1 }}

  {{- $num_mul_by_1000 := mul $num 1000 }}
  {{- $1_percent_of_num_mul_by_1000 := div $num_mul_by_1000 100 }}
  {{- $result_mul_by_1000 := mul $1_percent_of_num_mul_by_1000 $percents }}
  {{- div $result_mul_by_1000 1000 }}
{{- end }}
