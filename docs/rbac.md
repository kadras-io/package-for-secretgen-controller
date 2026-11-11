# Access to the Resources

The package extends the Kubernetes [default roles](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles) with the secretgen-controller resources, via [aggregation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#aggregated-clusterroles). The users bound to `admin`, `edit`, or `view` in a namespace get the following permissions on the resources in that namespace.

| Resources | `admin` | `edit` | `view` |
|-----------|---------|--------|--------|
| Password, Certificate, RSAKey, SSHKey | Read and write | Read and write | Read |
| SecretTemplate, SecretImport | Read and write | Read and write | Read |
| SecretExport | Read and write | Read | Read |

The Secrets generated in the namespace, and the ones imported from other namespaces. SecretExports share the Secrets of the namespace with other namespaces, so only `admin` can manage them.

The permissions are granted by the `secretgen-controller-admin`, `secretgen-controller-edit`, and `secretgen-controller-view` ClusterRoles.
