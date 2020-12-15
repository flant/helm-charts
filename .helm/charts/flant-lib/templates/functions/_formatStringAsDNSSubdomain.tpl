{{- define "fl.formatStringAsDNSSubdomain" }}
{{- . | lower | nospace | replace "_" "-" | replace "/" "-" | replace "\\" "-" | replace ":" "-" | replace "," "-" | trunc 252 }}
{{- end }}
