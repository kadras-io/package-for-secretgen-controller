# ###########
# CONTROLLER
# ###########

# The Deployment and container of the controller, as defined in the upstream manifest.
deployment = "secretgen-controller"
container = "secretgen-controller"

# The labels selecting the controller Pods in the upstream manifest.
# They're kept as they are, since the selector of a Deployment is immutable.
def controller_selector():
  return {"app": "secretgen-controller"}
end

# The controller serves the Prometheus metrics on this port (`-metrics-bind-address`, default `:8080`).
def metrics_port():
  return 8080
end
