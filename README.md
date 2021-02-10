# Installing charts from Flant's ChartMuseum

Our main directory for public charts is `https://charts.flant.com/common/github`. To use it, you need to add this repository to your Helm (e.g. it will be called `flant_common_github`):

```bash
helm repo add flant_common_github https://charts.flant.com/common/github
helm repo update
```

Now you can `helm install` the charts you need. Currently, we have the following charts _(generated automatically via GitHub Actions)_:

* `k8s-image-availability-exporter` — [k8s-iae](https://github.com/flant/k8s-image-availability-exporter) is a Prometheus exporter that warns you proactively about images that are defined in Kubernetes objects but are not available in the container registry;
* `loghouse` — [loghouse](https://github.com/flant/loghouse) is a log management solution for Kubernetes based on ClickHouse and Fluentd;
* `flant-lib` — Flant's Helm library with useful helpers/functions.

# Using ChartMuseum in your apps

To use these charts in your apps, you need to add the corresponding `.helm/requirements.yaml` file.

For example, to use a common chart for a Ruby on Rails app, you'll need to put the following in its `requirements.yaml`:

```yaml
dependencies:
- name: rubyonrails
  version: 1.0.0
  repository: https://charts.flant.com/common/github
  condition: rubyonrails.enabled
```

# Adding a new chart

1. Place a chart in `.helm/charts/<new chart name>`
2. Add a dependency for it:
    ```yaml
    .helm/requirements.yaml:
    ===============================
    - name: <new chart name>
      condition: <new chart name>.enabled
      version: ~<major version only, minor/patch not required>
    ```
3. Chart should be disabled by default:
     ```yaml
    .helm/charts/<new chart name>/values.yaml:
    =================================================
    enabled: false
    ```

## Charts publishing

Each new commit in master branch triggers automatic publishing to ChartMuseum at https://charts.flant.com/common/github
