# Availability

secretgen-controller doesn't support leader election, so it runs as a single replica: more replicas would reconcile the same resources at the same time.

## Upgrades

During a rolling update, the old Pod is stopped before the new one starts (`maxSurge: 0`, `maxUnavailable: 1`), so that two controllers never run at once.

## Downtime

While the controller isn't running, no Secrets are generated, imported, or updated. The existing Secrets aren't affected, so the workloads using them keep working. When the controller starts again, it reconciles all the resources, catching up with the changes made in the meantime.

## Priority

The controller runs with the `system-cluster-critical` priority, so it's scheduled before, and evicted after, the workloads relying on its Secrets.
