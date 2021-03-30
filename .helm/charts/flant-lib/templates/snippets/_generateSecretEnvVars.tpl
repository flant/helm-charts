{{- define "fl.generateSecretEnvVars" }}
{{ include "fl.generateSecretData" . }}
{{- end }}
