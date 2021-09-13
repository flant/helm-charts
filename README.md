# Flant Helm charts

## Install chart

All the charts in this repo are available in our ChartMuseum located at https://charts.flant.com/common/github. \
To be able to use them, you will need to add our ChartMuseum to the Helm's list of repositories:

```bash
helm repo add flant_common_github https://charts.flant.com/common/github
helm repo update
```

Now you can `helm install` the charts you need:

* `k8s-image-availability-exporter` — [k8s-iae](https://github.com/flant/k8s-image-availability-exporter) is a Prometheus exporter that warns you proactively about images that are defined in Kubernetes objects but are not available in the container registry;
* `loghouse` — [loghouse](https://github.com/flant/loghouse) is a log management solution for Kubernetes based on ClickHouse and Fluentd;
* `flant-lib` — Flant Helm library with useful helpers/functions.

Alternatively, you can make your charts explicitly depend on one of the charts from this repo by adding a `dependencies` section to your `requirements.yaml` or `Chart.yaml`:

```yaml
dependencies:
- name: loghouse
  version: ~0.3
  repository: https://charts.flant.com/common/github
  condition: loghouse.enabled
```

## Add new chart

1. Place a chart in `.helm/charts/<new chart name>`
2. Add a dependency for it:
    ```yaml
    .helm/requirements.yaml:
    ===============================
    - name: <new chart name>
      condition: <new chart name>.enabled
      version: ~<major version only, minor/patch not required>
    ```


Each new commit in master branch triggers automatic publishing to ChartMuseum at https://charts.flant.com/common/github.
