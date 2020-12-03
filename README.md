## Add new chart

1. Place the chart in `.helm/charts/<new chart name>`
1. Add dependency for it in `.helm/requirements.yaml`:
    ```yaml
    .helm/requirements.yaml:
    ===============================
    - name: <new chart name>
      condition: <new chart name>.enabled
    ```
1. In `.helm/charts/<new chart name>/values.yaml` you should have `$.Values.enabled == false`:
     ```yaml
    .helm/charts/<new chart name>/values.yaml:
    =================================================
    enabled: false
    ```
