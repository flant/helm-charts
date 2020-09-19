{{/*
  A way to keep your values.yaml DRY. Move common pieces of your Values in
  "$.Values.global._includes" and include them back with "_include".

  Usage:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | map1:
  |   _include: ["include1"]
  |   key1: val1
  |
  | global:
  |   # All includes should be defined in this map:
  |   _includes:
  |     include1:
  |       key2: val2
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  | # Place this somewhere at the beginning of your manifest:
  | {{- include "c.expandIncludes" (list $ $.Values) }}
  |
  | {{ $.Values.map1 }}
  ————————————————————————————————————————————————————————————————————
  | result:
  ————————————————————————————————————————————————————————————————————
  | key1: val1
  | key2: val2
  ————————————————————————————————————————————————————————————————————

  Features:
  ————————————————————————————————————————————————————————————————————
  1. Multiple includes in "_include" directive allowed. They will be
  merged one into another, and every next include in "_include" list
  will override values from the previous one.

  2. After all the includes in "_include" directive merged one into
  another, the result is expanded in place, i.e. the result is merged
  one level above "_include" directive.

  3. Recursive includes allowed, i.e. you can reference other includes
  in your include. No depth limit (except limitations on nested includes
  of Helm templates).

  4. Deep recursive merge of maps.

  5. No recursive merge of lists, since if implemented then you won't
  be able to override lists defined previously, only append new elements.

  6. Define your includes in your "$.Values.global._includes" once and use
  them in any values.yaml: top-level values.yaml, chart-level values.yaml,
  even secret-values.yaml.

  7. No restrictions on where "_include" directive can be used, as long
  as it is in your values.yaml.

  8. Use "null", "", [], {} or similar to undefine previously defined values.
  Works well with "val" helper.
  ————————————————————————————————————————————————————————————————————

  PS: the stuff below is complex and scary, and I can't make it simpler
  further. But it provides us with a missing and very powerful feature.
*/}}

{{/* FIXME: merge values in simple form with expanded form */}}
{{- define "c.expandIncludes" }}
  {{- $ := index . 0 }}
  {{- $location := index . 1 }}  {{/* Expand includes recursively starting here */}}

  {{- if kindIs "map" $location }}
    {{- include "c._recurseMergeAndExpandNestedIncludesIn" (list $ $location) }}
  {{- else if kindIs "slice" $location }}
    {{- range $_, $locationNested := $location }}
      {{- include "c.expandIncludes" (list $ $locationNested) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "c._recurseMergeAndExpandNestedIncludesIn" }}
  {{- $ := index . 0 }}
  {{- $mergeInto := index . 1 }}

  {{- if kindIs "map" $mergeInto }}
    {{- if hasKey $mergeInto "_include" }}
      {{- $joinedIncludes := (include "c._getJoinedIncludesInJson" (list $ $mergeInto._include) | fromJson).wrapper }}
      {{- $_ := unset $mergeInto "_include" }}
      {{- include "c._recurseMapsMerge" (list $ $joinedIncludes $mergeInto) }}
      {{- include "c.expandIncludes" (list $ $mergeInto) }}
    {{- else }}
      {{- range $nestedKey, $nestedVal := $mergeInto }}
        {{- if ne $nestedKey "_includes" }}
          {{- include "c.expandIncludes" (list $ $nestedVal) }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "c._getJoinedIncludesInJson" }}
  {{- $ := index . 0 }}
  {{- $includesNames := index . 1 }}

  {{- $includesBodies := list }}
  {{- range $_, $includeName := $includesNames }}
    {{- $includesBodies = append $includesBodies (index $.Values.global._includes $includeName) }}
  {{- end }}

  {{- $joinedIncludesResult := dict }}
  {{- range $i, $includeBody := reverse $includesBodies }}
    {{- include "c._recurseMapsMerge" (list $ $includeBody $joinedIncludesResult) }}
  {{- end }}
  {{- dict "wrapper" $joinedIncludesResult | toJson }}
{{- end }}

{{- define "c._recurseMapsMerge" }}
  {{- $ := index . 0 }}
  {{- $mapToMergeFrom := index . 1 }}
  {{- $mapToMergeInto := index . 2 }}

  {{- range $keyToMergeFrom, $valToMergeFrom := $mapToMergeFrom }}
    {{- $valToMergeInto := index $mapToMergeInto $keyToMergeFrom }}

    {{- if kindIs "map" $valToMergeFrom }}
      {{- if kindIs "map" $valToMergeInto }}
        {{- include "c._recurseMapsMerge" (list $ $valToMergeFrom $valToMergeInto) }}
      {{- else if not (hasKey $mapToMergeInto $keyToMergeFrom) }}
        {{- $_ := set $mapToMergeInto $keyToMergeFrom $valToMergeFrom }}
      {{- end }}

    {{- else if kindIs "slice" $valToMergeFrom }}
      {{- if eq $keyToMergeFrom "_include" }}
        {{- if kindIs "slice" $valToMergeInto }}
          {{- $joinedIncludes := (include "c._concatLists" (list $valToMergeFrom $valToMergeInto) | fromJson).wrapper }}
          {{- $_ := unset $mapToMergeInto "_include" }}
          {{- $_ := set $mapToMergeInto "_include" $joinedIncludes }}
        {{- else }}
          {{- $_ := unset $mapToMergeInto "_include" }}
          {{- $_ := set $mapToMergeInto "_include" $valToMergeFrom }}
        {{- end }}
      {{- end }}

    {{- else }}
      {{- if not (hasKey $mapToMergeInto $keyToMergeFrom) }}
        {{- $_ := set $mapToMergeInto $keyToMergeFrom $valToMergeFrom }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "c._concatLists" }}
  {{- $lists := index . }}

  {{- $result := list }}
  {{- range $_, $list := $lists }}
    {{- range $_, $list_elem := $list }}
      {{- $result = append $result $list_elem }}
    {{- end }}
  {{- end }}
  {{- dict "wrapper" $result | toJson }}
{{- end }}
