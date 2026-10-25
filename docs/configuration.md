# Configuration

The package values cover the decisions most installations need to make: namespace, observability, and security. Everything else can still be customized with ytt overlays.

## ytt overlays

Any Kubernetes resource of the package can be customized with a [ytt overlay](https://carvel.dev/ytt/docs/latest/ytt-overlays/), stored in a Secret and referenced from the PackageInstall via the `ext.packaging.carvel.dev/ytt-paths-from-secret-name.0` annotation.

```shell
kubectl create secret generic secretgen-controller-overlays -n kadras-system --from-file=overlays.yml
kubectl annotate packageinstall secretgen-controller -n kadras-system \
  ext.packaging.carvel.dev/ytt-paths-from-secret-name.0=secretgen-controller-overlays
```

### Resources

The controller requests 120m of CPU and 100Mi of memory, with no limits. Its memory grows with the number of Secrets and secretgen-controller resources in the cluster.

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "secretgen-controller"}})
---
spec:
  template:
    spec:
      containers:
        #@overlay/match by="name"
        - name: secretgen-controller
          #@overlay/match-child-defaults missing_ok=True
          resources:
            requests:
              cpu: 50m
              memory: 128Mi
            limits:
              memory: 256Mi
```

### Node placement

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "secretgen-controller"}})
---
spec:
  template:
    spec:
      #@overlay/match-child-defaults missing_ok=True
      nodeSelector:
        node-restriction.kubernetes.io/reserved-for: platform
      #@overlay/match missing_ok=True
      tolerations:
        - key: node-restriction.kubernetes.io/reserved-for
          operator: Equal
          value: platform
          effect: NoExecute
```

### Private registries

When the package images are relocated to a private registry, the controller needs credentials to pull its own image. Other packages can rely on a placeholder Secret filled by secretgen-controller, but secretgen-controller can't, since it must be running to fill it. Create the Secret in the package namespace yourself, and reference it from the Deployment.

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "Deployment", "metadata": {"name": "secretgen-controller"}})
---
spec:
  template:
    spec:
      #@overlay/match missing_ok=True
      imagePullSecrets:
        - name: registry-credentials
```
