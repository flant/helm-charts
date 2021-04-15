{{- define "fl.formatStringAsDNSSubdomain" }}
  {{- $string := . }}

  {{- $result := $string | lower | nospace | replace "_" "-" | replace "/" "-" | replace "\\" "-" | replace ":" "-" | replace "," "-" }}
  {{- if gt (len $result) 253 }}
    {{- $result = printf "%s-%s" (trunc 243 $result) (adler32sum $result) }}
  {{- end }}
  {{- $result }}
{{- end }}
