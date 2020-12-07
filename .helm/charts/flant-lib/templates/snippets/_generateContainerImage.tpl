{{- define "fl.generateContainerImageQuoted" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $imageConfig := index . 2 }}

  {{- if include "fl.isTrue" (list $ . $imageConfig.generateSignatureBasedTag) }}
    {{- include "werf_container_image" (list $imageConfig.name $) | trimPrefix "image: " }}
  {{- else -}}
    '{{ include "fl.value" (list $ . $imageConfig.name) }}:{{ include "fl.value" (list $ . $imageConfig.staticTag) }}'
  {{- end }}
{{- end }}
