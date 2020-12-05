{{/*
  Wrapper for all the Values you use in your chart.

  WARNING: maps and lists should only be passed as a string, not as a map/list.
  I.e. instead of this:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | map:
  |   val1: key1
  | list:
  | - key1
  ————————————————————————————————————————————————————————————————————
  You should use this:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | map: |  # << note this
  |   val1: key1
  | list: |
  | - key1
  ————————————————————————————————————————————————————————————————————

  What's this function for:

  1. Does the typical "pluck $.Values.global.env ... | default ..." for you.
  Also, "_default" key in values.yaml can be omitted if no other envs specified
  for the value, e.g. here key1 and key2 will result in the same thing:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | key1: val
  | key2:
  |   _default: val
  | key3:
  |   _default: val
  |   production: val
  ————————————————————————————————————————————————————————————————————

  2. The values are processed through "tpl" function, enabling templating
  for values of your values in your, ehmm, values.yaml. Extended to support
  relative scope in "tpl" function. Example:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | key1: "{{ $.Values.global.env }}-value"
  | key2: "{{ .someCurrentScopeValue }}-value"
  ————————————————————————————————————————————————————————————————————

  3. Safely handles booleans in your values.yaml, "false" doesnt mean
  that the value is "empty" anymore:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | # Without using this helper using these values is very dangerous
  | # and will result in "production: true" if value is passed
  | # through the standard "default" function (e.g. when used with "pluck"):
  | key:
  |   _default: true
  |   production: false
  ————————————————————————————————————————————————————————————————————

  4. You can optionally specify prefix and/or suffix for the result.
  No prefix/suffix will be added if the include results in nothing (null, "", ...).
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  | key1: {{ include "fl.value" (list $ . $.Values.memory (dict "suffix" "Mi") }}
  ————————————————————————————————————————————————————————————————————

  General usage:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | key1:
  |   production: val1
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  | key1: {{ include "fl.value" (list $ . $.Values.key1) }}
  ————————————————————————————————————————————————————————————————————
*/}}
{{- define "fl.value" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $val := index . 2 }}
  {{- $prefix := "" }}  {{- /* Optional */ -}}
  {{- $suffix := "" }}  {{- /* Optional */ -}}
  {{- if gt (len .) 3 }}
    {{- $optionalArgs := index . 3 }}
    {{- if hasKey $optionalArgs "prefix" }}
      {{- $prefix = $optionalArgs.prefix }}
    {{- end }}
    {{- if hasKey $optionalArgs "suffix" }}
      {{- $suffix = $optionalArgs.suffix }}
    {{- end }}
  {{- end }}

  {{- if kindIs "map" $val }}
    {{- $currentEnvVal := "" }}
    {{- if hasKey $val $.Values.global.env }}
      {{- $currentEnvVal = index $val $.Values.global.env }}
    {{- else if hasKey $val "_default" }}
      {{- $currentEnvVal = index $val "_default" }}
    {{- end }}
    {{- include "fl._renderValue" (list $ $relativeScope $currentEnvVal $prefix $suffix) }}
  {{- else }}
    {{- include "fl._renderValue" (list $ $relativeScope $val $prefix $suffix) }}
  {{- end }}
{{- end }}

{{- define "fl._renderValue" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $val := index . 2 }}
  {{- $prefix := index . 3 }}
  {{- $suffix := index . 4 }}

  {{- if and (not (kindIs "map" $val)) (not (kindIs "slice" $val)) }}
    {{- $valAsString := toString $val }}
    {{- if not (regexMatch "^<(nil|no value)>$" $valAsString) }}
      {{- $result := "" }}
      {{- if contains "{{" $valAsString }}
        {{- if empty $relativeScope }}
          {{- $relativeScope = $ }}  {{- /* tpl fails if $relativeScope is empty */ -}}
        {{- end }}
        {{- $result = tpl (print $prefix "{{ with $.RelativeScope }}" $valAsString "{{ end }}" $suffix) (merge (dict "RelativeScope" $relativeScope) $) }}
      {{- else }}
        {{- $result = print $prefix $valAsString $suffix }}
      {{- end }}
      {{- if ne $result "" }}{{ $result }}{{ end }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
  Invokes "fl.value" template and if there is a result, then quotes it, otherwise
  no quotes.
*/}}
{{- define "fl.valueQuoted" }}
  {{- $result := include "fl.value" . }}
  {{- if ne $result "" }}
    {{- $result | quote }}
  {{- end }}
{{- end }}


{{/*
  Invokes "fl.value" template and if there is a result, then single quotes it,
  otherwise no quotes.
*/}}
{{- define "fl.valueSingleQuoted" }}
  {{- $result := include "fl.value" . }}
  {{- if ne $result "" }}
    {{- $result | squote }}
  {{- end }}
{{- end }}
