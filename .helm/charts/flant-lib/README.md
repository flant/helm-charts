[Functions](#functions)
  * [fl.value](#function-fl.value)
  * [fl.valueQuoted](#function-fl.valuequoted)
  * [fl.valueSingleQuoted](#function-fl.valuesinglequoted)
  * [fl.expandIncludesInValues](#function-fl.expandincludesinvalues)
  * [fl.isTrue](#function-fl.istrue)
  * [fl.isFalse](#function-fl.isfalse)

[Templates](#templates)
  * [fl.generateLabels](#template-fl.generatelabels)
  * [fl.generateContainerImageQuoted](#template-fl.generatecontainerimagequoted)
  * [fl.generateContainerEnvVars](#template-fl.generatecontainerenvvars)
  * [fl.generateContainerResources](#template-fl.generatecontainerresources)

## Functions

### Function fl.value

Wrapper for all the Values that you use in your chart.

What's this function for:

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

WARNING: maps and lists should only be passed as a string, not as a map/list.
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

### Function fl.valueQuoted

Invokes "fl.value" function and if there is a result, then quotes it, otherwise no quotes.
Usage is the same as with the ["fl.value" function](#function-fl.value).

### Function fl.valueSingleQuoted

Invokes "fl.value" function and if there is a result, then single quotes it, otherwise no quotes.
Usage is the same as with the ["fl.value" function](#function-fl.value).

### Function fl.expandIncludesInValues

A way to keep your `values.yaml` DRY. Move common pieces of your Values in
`$.Values.global._includes` and include them back with `_include`.

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

Features:
1. Multiple includes in `_include` directive allowed. They will be
merged one into another, and every next include in `_include` list
will override values from the previous one.

2. After all the includes in `_include` directive merged one into
another, the result is expanded in place, i.e. the result is merged
one level above `_include` directive.

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

8. Use `null`, `""`, `[]`, `{}` or similar to override with "null" values defined in previous
includes, basically canceling them.

Arguments:
```yaml
list:
  0: global scope
  1: location (expand includes recursively starting here)
```

### Function fl.isTrue

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

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: boolean value that's going to be checked
```

### Function fl.isFalse
Same as "fl.isTrue" function, but the result is reversed. Usage is the same as with the
["fl.isTrue" function](#function-fl.istrue).

## Templates

### Template fl.generateLabels

Automatically generate basic set of labels.

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

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: app name or some other unique identifier, used for generating unique labels
```

### Template fl.generateContainerImageQuoted

Generate container image name and tag. Supports generating Werf signature-based image/tag.

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
  image: {{ include "fl.generateContainerImageQuoted" (list $ . $.Values.image) | nindent 4 }}
```
Results in:
```yaml
  image: "alpine:10"
```

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
  image: {{ include "fl.generateContainerImageQuoted" (list $ . $.Values.image) | nindent 4 }}
```
Results in:
```yaml
  image: example.org/repogroup/repo/backend:dfe383f700b1fb09f9881f330d22a9637d2b154ae3cb91b9cd3658f7
```

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with the image configuration (see Usage)
```

### Template fl.generateContainerEnvVars

Generate container environment variables list.

Usage:
```yaml
.helm/values.yaml:
—————————————————————————————————————
envs:
  ENV_VAR_1: 1
  ENV_VAR_2: 2
  ENV_VAR_3: null
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
  - name: ENV_VAR_2
    value: "2"
```

NOTE: no way to pass empty string as a value, it would cause the variable
not to be rendered at all (TODO: "nil" might work?)

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with env vars (see Usage)
```

### Template fl.generateContainerResources

Generate container resources block.

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

Arguments:
```yaml
list:
  0: global scope
  1: current relative scope
  2: map with resources (see Usage)
```
