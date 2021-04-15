## Contents

[Functions](#functions)
  * [fl.value](#flvalue-function)
  * [fl.valueQuoted](#flvaluequoted-function)
  * [fl.valueSingleQuoted](#flvaluesinglequoted-function)
  * [fl.expandIncludesInValues](#flexpandincludesinvalues-function)
  * [fl.isTrue](#flistrue-function)
  * [fl.isFalse](#flisfalse-function)
  * [fl.formatStringAsDNSSubdomain](#flformatstringasdnssubdomain-function)
  * [fl.formatStringAsDNSLabel](#flformatstringasdnslabel-function)

[Templates](#templates)
  * [fl.generateLabels](#flgeneratelabels-template)
  * [fl.generateSelectorLabels](#flgenerateselectorlabels-template)
  * [fl.generateContainerImageQuoted](#flgeneratecontainerimagequoted-template)
  * [fl.generateContainerEnvVars](#flgeneratecontainerenvvars-template)
  * [fl.generateConfigMapEnvVars](#flgenerateconfigmapenvvars-template)
  * [fl.generateSecretEnvVars](#flgeneratesecretenvvars-template)
  * [fl.generateSecretData](#flgeneratesecretdata-template)
  * [fl.generateContainerResources](#flgeneratecontainerresources-template)

[Development](#development)
  * [Tests](#tests)

## Functions

### "fl.value" function

Wrapper for all the Values that you use in your chart.
<br/><br/>

What is this function for:

1. Does the typical `pluck $.Values.global.env ... | default ...` for you.
Also, `_default` key in `values.yaml` can be omitted if no other envs specified
for the value, e.g. here `key1` and `key2` will result in the same thing:
    ```yaml
    .helm/values.yaml:
    —————————————————————————————————————
    key1: val
    key2:
      _default: val
    key3:
      _default: val
      production: val
    ```

2. The values are processed through "tpl" function, enabling templating
for values of your values in your, ehmm, `values.yaml`. Extended to support
relative scope in "tpl" function. Example:
    ```yaml
    .helm/values.yaml:
    —————————————————————————————————————
    key1: "{{ $.Values.global.env }}-value"
    key2: "{{ .someCurrentScopeValue }}-value"
    ```

3. Safely handles booleans in your `values.yaml`, "false" doesnt mean
that the value is "empty" anymore:
    ```yaml
    .helm/values.yaml:
    —————————————————————————————————————
    # Without using this helper using these values is very dangerous
    # and will result in "production: true" if value is passed
    # through the standard "default" function (e.g. when used with "pluck"):
    key:
      _default: true
      production: false
    ```

4. You can optionally specify prefix and/or suffix for the result.
No prefix/suffix will be added if invocation of this function results in nothing (null, "", ...).
    ```yaml
    .helm/templates/test.yaml:
    —————————————————————————————————————
    key1: {{ include "fl.value" (list $ . $.Values.memory (dict "suffix" "Mi") }}
    ```
<br/>

General usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
key1:
  production: val1
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
key1: {{ include "fl.value" (list $ . $.Values.key1) }}
```
<br/>

**WARNING**: maps and lists should only be passed as a string, not as a map/list.
Also only full YAML form of maps/lists is allowed, short JSON form (`[]/{}`) is not supported yet.
I.e. instead of this:
```yaml
.helm/values.yaml:
—————————————————————————————————————
map:
  val1: key1
list: ["key1"]
```
You should use this:
```yaml
.helm/values.yaml:
—————————————————————————————————————
map: | # << note this
  val1: key1
list: |
- key1
```
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: value to expand
  3: dict (optional):
    prefix (optinal): add prefix to the result
    suffix (optional): add suffix to the result
```
<br/>

### "fl.valueQuoted" function

Invokes "fl.value" function and if there is a result, then quotes it, otherwise no quotes.
Usage is the same as with the ["fl.value" function](#flvalue-function).
<br/><br/>

### "fl.valueSingleQuoted" function

Invokes "fl.value" function and if there is a result, then single quotes it, otherwise no quotes.
Usage is the same as with the ["fl.value" function](#flvalue-function).
<br/><br/>

### "fl.expandIncludesInValues" function

A way to keep your `values.yaml` DRY. Move common pieces of your Values in
`$.Values.global._includes` and include them back with `_include`.
<br/><br/>

Usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
map1:
  _include: ["include1"]
  key1: val1

global:
  # All includes should be defined in this map:
  _includes:
    include1:
      key2: val2
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
# Place this somewhere at the beginning of your manifest:
{{- include "fl.expandIncludesInValues" (list $ $.Values) }}

{{ $.Values.map1 }}
```
Results in:
```yaml
key1: val1
key2: val2
```
<br/>

Features:
1. Multiple includes in `_include` directive allowed. They will be
merged one into another, and every next include in `_include` list
will override values from the previous one.

2. After all the includes in `_include` directive merged one into
another, the result is expanded in place, i.e. the result is merged
into where the `_include` directive is defined.

3. Recursive includes allowed, i.e. you can reference other includes
in your include. No depth limit (except limitations on nested includes
of Helm templates).

4. Deep recursive merge of maps.

5. No recursive merge of lists, because if implemented then you won't
be able to override lists defined previously, only append new elements to
the existing list.

6. Define your includes in your `$.Values.global._includes` once and use
them in any Values files: top-level `values.yaml`, chart-level `values.yaml`,
even `secret-values.yaml`.

7. No restrictions on where `_include` directive can be used, as long
as it is in your `values.yaml`.

8. Use `null`, `""`, `[]`, `{}` or similar to override values defined in previous
includes with "null", basically canceling them.
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: location (expand includes recursively starting here)
```
<br/>

### "fl.isTrue" function

Check whether boolean Value is true.

1. This function uses "fl.value" function under the hood, which safely
handles "false" boolean value.
2. Meant to be used in if-statements:
    ```yaml
    {{- if include "fl.isTrue" (list $ . $.Values.testBoolean) }}
    ```
3. Can be used in the "ternary" function this way:
    ```yaml
    {{- ternary true false (include "fl.isTrue" (list $ . $.Values.testBoolean) | not | empty) }}
    ```
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: boolean value that's going to be checked
```
<br/>

### "fl.isFalse" function

Same as "fl.isTrue" function, but the result is reversed. Usage is the same as with the
["fl.isTrue" function](#flistrue-function).
<br/><br/>

### "fl.formatStringAsDNSSubdomain" function

Format the string as a DNS subdomain name as defined in RFC 1123. Usually to be able to use the string
as a name for some Kubernetes resources. If string is longer than 253 symbols, then truncate it and add a unique hash at the end of it. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-subdomain-names
<br/>

Arguments:
```yaml
string: string to convert
```
<br/><br/>

### "fl.formatStringAsDNSLabel" function

Format the string as a DNS label name as defined in RFC 1123. Usually to be able to use the string
as a name for some Kubernetes resources. If string is longer than 63 symbols, then truncate it and add a unique hash at the end of it. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names
<br/>

Arguments:
```yaml
string: string to convert
```
<br/><br/>

## Templates

### "fl.generateLabels" template

Automatically generate basic set of labels.
<br/><br/>

Usage:
```yaml
.helm/templates/test.yaml:
—————————————————————————————————————
kind: Deployment
metadata:
  labels: {{ include "fl.generateLabels" (list $ . "testapp") | nindent 4 }}
```
Results in:
```yaml
  labels:
    app: testapp
    chart: chartname
    repo: gitlabrepogroup-repo
```
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: app name or some other unique identifier, used for generating unique labels
```
<br/>

### "fl.generateSelectorLabels" template

Automatically generate a minimal set of labels for selectors.
<br/><br/>

Usage:
```yaml
.helm/templates/test.yaml:
—————————————————————————————————————
kind: Deployment
metadata:
  labels: {{ include "fl.generateSelectorLabels" (list $ . "testapp") | nindent 4 }}
```
Results in:
```yaml
  labels:
    app: testapp
```
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: app name or some other unique identifier, used for generating unique labels
```
<br/>

### "fl.generateContainerImageQuoted" template

Generate container image name and tag. Supports generating Werf signature-based image/tag.
<br/><br/>

Generate static image name and tag:
```yaml
.helm/values.yaml:
—————————————————————————————————————
image:
  name: "alpine"
  staticTag: "10"
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
  image: {{ include "fl.generateContainerImageQuoted" (list $ . $.Values.image) }}
```
Results in:
```yaml
  image: "alpine:10"
```
<br/>

Generate dynamic Werf signature-based image name and tag:
```yaml
.helm/values.yaml:
—————————————————————————————————————
image:
  name: "backend"
  generateSignatureBasedTag: true
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
  image: {{ include "fl.generateContainerImageQuoted" (list $ . $.Values.image) }}
```
Results in:
```yaml
  image: example.org/repogroup/repo/backend:dfe383f700b1fb09f9881f330d22a9637d2b154ae3cb91b9cd3658f7
```
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with the image configuration (see Usage)
```
<br/>

### "fl.generateContainerEnvVars" template

Generate container environment variables list.
<br/><br/>

Usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
envs:
  ENV_VAR_1: 1
  # No environment variable will be passed
  ENV_VAR_2: null
  # No environment variable will be passed
  ENV_VAR_3: ""
  # Special keyword can be used to define variable, but keep it empty
  ENV_VAR_4: "___FL_THIS_ENV_VAR_WILL_BE_DEFINED_BUT_EMPTY___"
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
kind: Deployment
...
  env: {{ include "fl.generateContainerEnvVars" (list $ . .envs) | nindent 4 }}
```
Results in:
```yaml
  env:
  - name: ENV_VAR_1
    value: "1"
  - name: ENV_VAR_4
    value: ""
```

<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with env vars (see Usage)
```
<br/>

### "fl.generateConfigMapEnvVars" template

Generate ConfigMap data entries to be used as environment variables.
<br/><br/>

Usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
envs:
  ENV_VAR_1: 1
  # No environment variable will be passed
  ENV_VAR_2: null
  # No environment variable will be passed
  ENV_VAR_3: ""
  # Special keyword can be used to define variable, but keep it empty
  ENV_VAR_4: "___FL_THIS_ENV_VAR_WILL_BE_DEFINED_BUT_EMPTY___"
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
kind: ConfigMap
data: {{ include "fl.generateConfigMapEnvVars" (list $ . .envs) | nindent 2 }}
```
Results in:
```yaml
kind: ConfigMap
data:
  ENV_VAR_1: "1"
  ENV_VAR_4: ""
```

<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with env vars (see Usage)
```
<br/>

### "fl.generateSecretEnvVars" template

Generate base64-encoded Secret data entries to be used as environment variables.
<br/><br/>

Usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
envs:
  ENV_VAR_1: 1
  # No environment variable will be passed
  ENV_VAR_2: null
  # No environment variable will be passed
  ENV_VAR_3: ""
  # Special keyword can be used to define variable, but keep it empty
  ENV_VAR_4: "___FL_THIS_ENV_VAR_WILL_BE_DEFINED_BUT_EMPTY___"
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
kind: ConfigMap
data: {{ include "fl.generateConfigMapEnvVars" (list $ . .envs) | nindent 2 }}
```
Results in:
```yaml
kind: Secret
data:
  ENV_VAR_1: "MQ=="   # base64-encoded "1"
  ENV_VAR_4: ""
```

<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with env vars (see Usage)
```
<br/>

### "fl.generateSecretData" template

Generate base64-encoded Secret data entries. Usage is the same as with the ["fl.generateSecretEnvVars" function](#flgeneratesecretenvvars-template).
<br/><br/>

### "fl.generateContainerResources" template

Generate container resources block.
<br/>

Usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
resources:
  requests:
    mcpu: 100
    memoryMb: 200
  limits:
    mcpu: null
—————————————————————————————————————
.helm/templates/test.yaml:
—————————————————————————————————————
kind: Deployment
...
  resources: {{ include "fl.generateContainerResources" (list $ . $.Values.resources) | nindent 4 }}
```
Results in:
```yaml
  resources:
    requests:
      cpu: 100
      memory: 200
```
<br/>

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with resources (see Usage)
```

## Development

### Tests

There is a simple tests implementation, which only renders a simple template with a sample `values.yaml` file, and then checks whether the rendered result is as expected. It does not try to deploy the result in the cluster, unlike other Helm testing solutions. It consists of:
* Helm template for tests: [templates/tests/render/test.yaml](templates/tests/render/test.yaml)
* `values.yaml` file for tests: [tests/render/values.yaml](tests/render/values.yaml)
* result we expect to be rendered from these template and `values.yaml` files: [tests/render/expected-render.yaml](tests/render/expected-render.yaml)

Usage:
```bash
make -f .helm/charts/flant-lib/Makefile run-render-tests # run tests
make -f .helm/charts/flant-lib/Makefile render-expected-output-for-render-tests # show what's rendered
make -f .helm/charts/flant-lib/Makefile save-expected-output-for-render-tests # render and save the result to expected-render.yaml
```
