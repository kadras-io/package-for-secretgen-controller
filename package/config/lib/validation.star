load("@ytt:regexp", "regexp")

# Validation helpers used by the values schema.
# They must not depend on data values, since they run while the schema is evaluated.

_dns_label = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"

def is_dns_label(value):
  return len(value) <= 63 and regexp.match("^" + _dns_label + "$", value)
end
