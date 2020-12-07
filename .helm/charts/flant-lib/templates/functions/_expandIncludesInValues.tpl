{{/* The stuff below is complex and scary, and I can't make it simpler */}}

{{/* FIXME: merge values in simple form with expanded form */}}
{{- define "fl.expandIncludesInValues" }}
  {{- $ := index . 0 }}
  {{- $location := index . 1 }}  {{/* Expand includes recursively starting here */}}

  {{- if kindIs "map" $location }}
    {{- include "fl._recursiveMergeAndExpandIncludes" (list $ $location) }}
  {{- else if kindIs "slice" $location }}
    {{- range $_, $locationNested := $location }}
      {{- include "fl.expandIncludesInValues" (list $ $locationNested) }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "fl._recursiveMergeAndExpandIncludes" }}
  {{- $ := index . 0 }}
  {{- $mergeInto := index . 1 }}

  {{- if kindIs "map" $mergeInto }}
    {{- if hasKey $mergeInto "_include" }}
      {{- $joinedIncludes := (include "fl._getJoinedIncludesInJson" (list $ $mergeInto._include) | fromJson).wrapper }}
      {{- $_ := unset $mergeInto "_include" }}
      {{- include "fl._recursiveMapsMerge" (list $ $joinedIncludes $mergeInto) }}
      {{- include "fl.expandIncludesInValues" (list $ $mergeInto) }}
    {{- else }}
      {{- range $nestedKey, $nestedVal := $mergeInto }}
        {{- if ne $nestedKey "_includes" }}
          {{- include "fl.expandIncludesInValues" (list $ $nestedVal) }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "fl._getJoinedIncludesInJson" }}
  {{- $ := index . 0 }}
  {{- $includesNames := index . 1 }}

  {{- $includesBodies := list }}
  {{- range $_, $includeName := $includesNames }}
    {{- $includesBodies = append $includesBodies (index $.Values.global._includes $includeName) }}
  {{- end }}

  {{- $joinedIncludesResult := dict }}
  {{- range $i, $includeBody := reverse $includesBodies }}
    {{- include "fl._recursiveMapsMerge" (list $ $includeBody $joinedIncludesResult) }}
  {{- end }}
  {{- dict "wrapper" $joinedIncludesResult | toJson }}
{{- end }}

{{- define "fl._recursiveMapsMerge" }}
  {{- $ := index . 0 }}
  {{- $mapToMergeFrom := index . 1 }}
  {{- $mapToMergeInto := index . 2 }}

  {{- range $keyToMergeFrom, $valToMergeFrom := $mapToMergeFrom }}
    {{- $valToMergeInto := index $mapToMergeInto $keyToMergeFrom }}

    {{- if kindIs "map" $valToMergeFrom }}
      {{- if kindIs "map" $valToMergeInto }}
        {{- include "fl._recursiveMapsMerge" (list $ $valToMergeFrom $valToMergeInto) }}
      {{- else if not (hasKey $mapToMergeInto $keyToMergeFrom) }}
        {{- $_ := set $mapToMergeInto $keyToMergeFrom $valToMergeFrom }}
      {{- end }}

    {{- else if kindIs "slice" $valToMergeFrom }}
      {{- if eq $keyToMergeFrom "_include" }}
        {{- if kindIs "slice" $valToMergeInto }}
          {{- $joinedIncludes := (include "fl._concatLists" (list $valToMergeFrom $valToMergeInto) | fromJson).wrapper }}
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

{{- define "fl._concatLists" }}
  {{- $lists := index . }}

  {{- $result := list }}
  {{- range $_, $list := $lists }}
    {{- range $_, $list_elem := $list }}
      {{- $result = append $result $list_elem }}
    {{- end }}
  {{- end }}
  {{- dict "wrapper" $result | toJson }}
{{- end }}
