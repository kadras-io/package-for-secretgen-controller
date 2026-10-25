# Observability

## Logs

The controller logs in JSON. The log level isn't configurable.

## Metrics

The controller exposes metrics in the Prometheus format on port 8080 (`/metrics`). By default, its Pod is annotated for Prometheus scraping (`prometheus.io/scrape`, `prometheus.io/port`, `prometheus.io/path`). To disable the metrics server:

```yaml
observability:
  metrics:
    enabled: false
```

If you use the Prometheus Operator, create a PodMonitor instead:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: secretgen-controller
  namespace: secretgen-controller
spec:
  selector:
    matchLabels:
      app: secretgen-controller
  podMetricsEndpoints:
    - port: metrics
```

The metrics are the standard ones of [controller-runtime](https://book.kubebuilder.io/reference/metrics-reference), like `controller_runtime_reconcile_errors_total` and `workqueue_depth`, labelled by controller.

## Status

All the secretgen-controller resources report their state in `status.conditions` and `status.friendlyDescription`, shown by `kubectl get`.

```shell
kubectl get passwords,certificates,secretexports,secretimports,secrettemplates -A
```
