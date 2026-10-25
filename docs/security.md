# Security

secretgen-controller reads and writes Secrets across the cluster, so it's hardened, and the features sharing Secrets across namespaces should be used carefully.

## Pod Security Standards

The controller complies with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), enforced on the package namespace: it runs as non-root, with a read-only root filesystem, no privilege escalation, no capabilities, and the `RuntimeDefault` seccomp profile.

## Service account tokens

The service account token isn't auto-mounted. The controller mounts a projected token instead, which expires after an hour and is rotated by the kubelet.

## Network policies

The package can deny the inbound traffic to the controller, except for the metrics scraping on port 8080, when the metrics are enabled. The controller has no webhooks, so it doesn't receive any other traffic.

```yaml
security:
  network_policies: true
```

The source of the scraping isn't known in advance, so it's allowed from anywhere. Restrict it with a ytt overlay (see [configuration.md](configuration.md#ytt-overlays)), for example to only allow scraping from the namespace of Prometheus:

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "NetworkPolicy", "metadata": {"name": "secretgen-controller-allow-metrics"}})
---
spec:
  ingress:
    #@overlay/match by=overlay.all
    -
      #@overlay/match missing_ok=True
      from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: observability
```

### Outbound traffic

The controller only reaches the Kubernetes API server (usually on port 443 or 6443). The package doesn't restrict the outbound traffic, since the API server address depends on the cluster. To restrict it, create your own NetworkPolicy in the package namespace, adjusting the ports to your cluster:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secretgen-controller-egress
  namespace: secretgen-controller
spec:
  podSelector:
    matchLabels:
      app: secretgen-controller
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 6443
```

## Permissions

The controller can read and write all the Secrets in the cluster, read the namespaces and service accounts, and request tokens for service accounts, which it uses to read the input resources of a SecretTemplate on behalf of its service account. Restrict who can access the package namespace.

## Sharing Secrets

Sharing a Secret makes it readable by anyone who can read Secrets in the namespaces it's shared with. Before exporting a Secret, consider that:

* `toNamespace: "*"` and `dangerousToNamespacesSelector` match the namespaces created later too, and anyone who can create or label a namespace can make it match. Prefer listing the namespaces explicitly.
* Anyone who can create Secrets in a namespace can get the registry credentials exported to it, by creating a [placeholder](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/secret-export.md). Only export read-only credentials, scoped to the repositories the namespaces need.
* A namespace annotated with `secretgen.carvel.dev/excluded-from-wildcard-matching` doesn't receive the Secrets exported to `"*"`. The annotation doesn't affect `dangerousToNamespacesSelector`.
* A SecretImport overwrites any Secret with the same name in its namespace.

Restrict who can create SecretExports with Kubernetes RBAC, since anyone who can create them in a namespace can share its Secrets.
