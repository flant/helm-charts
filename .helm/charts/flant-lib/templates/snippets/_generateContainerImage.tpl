{{- define "fl.generateContainerImageQuoted" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $imageConfig := index . 2 }}

  {{- $imageName := include "fl.value" (list $ . $imageConfig.name) }}
  {{- if include "fl.isTrue" (list $ . $imageConfig.generateSignatureBasedTag) }}
    {{- include "werf_container_image" (list $imageName $) | trimPrefix "image: " }}
  {{- else -}}
    '{{ $imageName }}:{{ include "fl.value" (list $ . $imageConfig.staticTag) }}'
  {{- end }}
{{- end }}
