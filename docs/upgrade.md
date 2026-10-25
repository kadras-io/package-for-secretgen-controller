# Upgrading

Upgrade secretgen-controller one minor version at a time, and read the [release notes](https://github.com/carvel-dev/secretgen-controller/releases) of each version first.

```shell
kctrl package installed update -i secretgen-controller -v ${VERSION} -n kadras-system
```

## Back up before uninstalling

The secretgen-controller CRDs are part of the package. Deleting the PackageInstall deletes them, and with them all the Passwords, Certificates, RSAKeys, SSHKeys, SecretExports, SecretImports, and SecretTemplates in the cluster. Since they own the Secrets they generated, imported, or composed, those Secrets are deleted too.

To keep the CRDs when the package is deleted, add this ytt overlay (see [configuration.md](configuration.md#ytt-overlays)):

```yaml
#@ load("@ytt:overlay", "overlay")

#@overlay/match by=overlay.subset({"kind": "CustomResourceDefinition"}), expects="1+"
---
metadata:
  #@overlay/match missing_ok=True
  annotations:
    #@overlay/match missing_ok=True
    kapp.k14s.io/delete-strategy: orphan
```
