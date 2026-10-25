# secretgen-controller

![Test Workflow](https://github.com/kadras-io/package-for-secretgen-controller/actions/workflows/test.yml/badge.svg)
![Release Workflow](https://github.com/kadras-io/package-for-secretgen-controller/actions/workflows/release.yml/badge.svg)
[![The SLSA Level 3 badge](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev/spec/v1.0/levels)
[![The Apache 2.0 license badge](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Follow us on Bluesky](https://img.shields.io/static/v1?label=Bluesky&message=Follow&color=1DA1F2)](https://bsky.app/profile/kadras.bsky.social)

A Carvel package for [secretgen-controller](https://github.com/carvel-dev/secretgen-controller), a cloud-native solution to generate and share Secrets, passwords, keys, and certificates.

## ✨&nbsp; What's Included

* **Secret generation**. Passwords, RSA keys, SSH keys, and X.509 certificates, generated into Secrets whose format can be customized.
* **Secret sharing**. Secrets exported from a namespace and imported into others, image pull secrets filled with the exported registry credentials, and Secrets composed from other resources.
* **Observability**. Prometheus metrics.
* **Security**. The controller complies with the `restricted` [Pod Security Standard](https://kubernetes.io/docs/concepts/security/pod-security-standards/), uses a short-lived service account token, and can be isolated with network policies.

## 🚀&nbsp; Getting Started

### Prerequisites

* Kubernetes 1.35+
* Carvel [`kctrl`](https://carvel.dev/kapp-controller/docs/latest/install/#installing-kapp-controller-cli-kctrl) CLI.
* Carvel [kapp-controller](https://carvel.dev/kapp-controller) deployed in your Kubernetes cluster. You can install it with Carvel [`kapp`](https://carvel.dev/kapp/docs/latest/install) (recommended choice) or `kubectl`.

```shell
kapp deploy -a kapp-controller -y \
  -f https://github.com/carvel-dev/kapp-controller/releases/latest/download/release.yml
```

### Installation

Add the Kadras [package repository](https://github.com/kadras-io/kadras-packages) to your Kubernetes cluster:

```shell
kctrl package repository add -r kadras-packages \
  --url ghcr.io/kadras-io/kadras-packages \
  -n kadras-system --create-namespace
```

<details><summary>Installation without package repository</summary>
The recommended way of installing the secretgen-controller package is via the Kadras <a href="https://github.com/kadras-io/kadras-packages">package repository</a>. If you prefer not using the repository, you can add the package definition directly using <a href="https://carvel.dev/kapp/docs/latest/install"><code>kapp</code></a> or <code>kubectl</code>.

```shell
kubectl create namespace kadras-system
kapp deploy -a secretgen-controller-package -n kadras-system -y \
  -f https://github.com/kadras-io/package-for-secretgen-controller/releases/latest/download/metadata.yml \
  -f https://github.com/kadras-io/package-for-secretgen-controller/releases/latest/download/package.yml
```
</details>

Install the secretgen-controller package:

```shell
kctrl package install -i secretgen-controller \
  -p secretgen-controller.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system
```

> **Note**
> You can find the `${VERSION}` value by retrieving the list of package versions available in the Kadras package repository installed on your cluster.
> 
> ```shell
> kctrl package available list -p secretgen-controller.packages.kadras.io -n kadras-system
> ```

Verify the installed packages and their status:

```shell
kctrl package installed list -n kadras-system
```

### Try It Out

Generate a password:

```shell
kubectl apply -f - <<EOF
apiVersion: secretgen.k14s.io/v1alpha1
kind: Password
metadata:
  name: hello
spec:
  length: 32
EOF
```

Check that the password is generated. It's stored in the `hello` Secret, under the `password` key.

```shell
kubectl get secret hello -o jsonpath='{.data.password}' | base64 -d
```

## 📙&nbsp; Documentation

Documentation, tutorials and examples for this package are available in the [docs](docs) folder.
For documentation specific to secretgen-controller, check out [github.com/carvel-dev/secretgen-controller](https://github.com/carvel-dev/secretgen-controller/tree/develop/docs).

Features:

* [Sharing Secrets](docs/sharing.md)
* [Availability](docs/availability.md)
* [Observability](docs/observability.md)
* [Security](docs/security.md)

Operations:

* [Configuration and ytt overlays](docs/configuration.md)
* [Upgrading](docs/upgrade.md)
* [Verifying the release](docs/verify-release.md)

## 🎯&nbsp; Configuration

The secretgen-controller package can be customized via a `values.yml` file.

```yaml
namespace: secretgen-controller
security:
  network_policies: true
```

Reference the `values.yml` file from the `kctrl` command when installing or upgrading the package.

```shell
kctrl package install -i secretgen-controller \
  -p secretgen-controller.packages.kadras.io \
  -v ${VERSION} \
  -n kadras-system \
  --values-file values.yml
```

Anything not covered by the values can be customized via ytt overlays, as described in [docs/configuration.md](docs/configuration.md).

### Values

The secretgen-controller package has the following configurable properties.

<details><summary>Configurable properties</summary>

<!-- values-table:start -->

| Config | Default | Description |
|--------|---------|-------------|
| `namespace` | `"secretgen-controller"` | The namespace in which to deploy secretgen-controller. |
| `observability.metrics.enabled` | `true` | Whether the controller exposes metrics in the Prometheus format on port 8080 (`/metrics`), and its Pod is annotated for Prometheus scraping. When false, the metrics server is disabled. |
| `security.network_policies` | `false` | Whether to deny the inbound traffic to the controller Pod, except for the metrics scraping. See https://kubernetes.io/docs/concepts/services-networking/network-policies. |

<!-- values-table:end -->

</details>

## 🛠️&nbsp; Development

The development environment is defined with [devenv](https://devenv.sh). Enter it with `devenv shell`, or automatically with [direnv](https://direnv.net) after running `direnv allow`. Run `task --list` to see all the available tasks.

```shell
# Run the unit tests, which render the package and check the result without a cluster.
task test:config

# Create a local kind cluster and run the integration tests on it.
task cluster:setup
task test:integration

# Deploy the package from the local sources to the current cluster.
task dev

# Update the table of configurable values in this README after changing the values schema.
task docs:values
```

The unit tests are described in [test/unit/README.md](test/unit/README.md).

## 🛡️&nbsp; Security

The security process for reporting vulnerabilities is described in [SECURITY.md](SECURITY.md).

## 🖊️&nbsp; License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for more information.
