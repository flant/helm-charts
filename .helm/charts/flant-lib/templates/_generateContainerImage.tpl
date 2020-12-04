{{/*
  Generate container image.

  Usage:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | image:
  |   name: "alpine"
  |   staticTag: "10"
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  |   image: {{ include "flant-lib.generateContainerImageQuoted" (list $ . $.Values.image) | nindent 4 }}
  ————————————————————————————————————————————————————————————————————
  Results in:
  ————————————————————————————————————————————————————————————————————
  |   image: "alpine:10"
  ————————————————————————————————————————————————————————————————————

  Generate dynamic Werf signature-based image name/tag:
  ————————————————————————————————————————————————————————————————————
  | .helm/values.yaml:
  ————————————————————————————————————————————————————————————————————
  | image:
  |   name: "backend"
  |   generateSignatureBasedTag: true
  ————————————————————————————————————————————————————————————————————
  | .helm/templates/test.yaml:
  ————————————————————————————————————————————————————————————————————
  |   image: {{ include "flant-lib.generateContainerImageQuoted" (list $ . $.Values.image) | nindent 4 }}
  ————————————————————————————————————————————————————————————————————
  Results in:
  ————————————————————————————————————————————————————————————————————
  |   image: example.org/repogroup/repo/backend:dfe383f700b1fb09f9881f330d22a9637d2b154ae3cb91b9cd3658f7
  ————————————————————————————————————————————————————————————————————
*/}}
{{- define "flant-lib.generateContainerImageQuoted" }}
  {{- $ := index . 0 }}
  {{- $relativeScope := index . 1 }}
  {{- $imageConfig := index . 2 }}

  {{- if include "flant-lib.isTrue" (list $ . $imageConfig.generateSignatureBasedTag) }}
    {{- include "werf_container_image" (list $imageConfig.name $) | trimPrefix "image: " }}
  {{- else -}}
    '{{ include "flant-lib.value" (list $ . $imageConfig.name) }}:{{ include "flant-lib.value" (list $ . $imageConfig.staticTag) }}'
  {{- end }}
{{- end }}
