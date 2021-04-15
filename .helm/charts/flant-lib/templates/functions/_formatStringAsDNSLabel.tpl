{{- define "fl.formatStringAsDNSLabel" }}
  {{- $string := . }}

  {{- $result := $string | lower | nospace | replace "_" "-" | replace "/" "-" | replace "\\" "-" | replace ":" "-" | replace "," "-" | replace "." "-" }}
  {{- if gt (len $result) 63 }}
    {{- $result = printf "%s-%s" (trunc 53 $result) (adler32sum $result) }}
  {{- end }}
  {{- $result }}
{{- end }}
