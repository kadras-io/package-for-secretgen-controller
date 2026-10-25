# Sharing Secrets

Other Kadras packages rely on secretgen-controller to share Secrets across namespaces. For example, cert-manager imports the DNS-01 credentials into its namespace, and the packages authenticate with private registries via placeholder Secrets.

## Registry credentials

The packages include a placeholder Secret for the registry credentials, annotated with `secretgen.carvel.dev/image-pull-secret`, which secretgen-controller fills with the credentials exported to its namespace. To authenticate all the packages with a private registry, export the credentials once:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: registry-credentials
  namespace: kadras-system
type: kubernetes.io/dockerconfigjson
stringData:
  .dockerconfigjson: |
    {"auths": {"ghcr.io": {"username": "kadras", "password": "<token>"}}}
---
apiVersion: secretgen.carvel.dev/v1alpha1
kind: SecretExport
metadata:
  name: registry-credentials
  namespace: kadras-system
spec:
  toNamespace: "*"
```

Exporting to all the namespaces is convenient, but has security implications: see [security.md](security.md#sharing-secrets). To limit the export, list the namespaces in `toNamespaces` instead.

## More

* [Exporting and importing Secrets](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/secret-export.md), including placeholder Secrets.
* [Composing Secrets from other resources](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/secret-template.md) with SecretTemplate.
* [Generating passwords](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/password.md), [certificates](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/certificate.md), [RSA keys](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/rsa_key.md), and [SSH keys](https://github.com/carvel-dev/secretgen-controller/blob/develop/docs/ssh_key.md).
