{{- define "fl.formatStringAsDNSLabel" }}
{{- . | lower | nospace | replace "_" "-" | replace "/" "-" | replace "\\" "-" | replace ":" "-" | replace "," "-" | replace "." "-" | trunc 63 }}
{{- end }}
