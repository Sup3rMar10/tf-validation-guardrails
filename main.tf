# The three layers, from earliest to latest:
#   1. variable validation   - rejects bad input before anything is evaluated
#   2. precondition          - rejects a bad combination before a resource is created
#   3. postcondition / check - verifies the result, or warns without blocking
# No cloud is involved: the "bucket" is a manifest file written with hashicorp/local.

locals {
  manifest = {
    bucket         = var.bucket_name
    owner          = var.owner_email
    classification = var.classification
    retention_days = var.retention_days
    encrypted      = var.encryption_enabled
  }
}

resource "local_file" "manifest" {
  filename = "${path.module}/out/${var.bucket_name}.json"
  content  = jsonencode(local.manifest)

  lifecycle {
    # Only variables that were individually valid reach this point, so this guards a
    # *combination*: restricted data may never be unencrypted.
    precondition {
      condition     = var.classification != "restricted" || var.encryption_enabled
      error_message = "restricted data must have encryption_enabled = true."
    }

    # Postcondition: checks what the resource actually became. Here it guards against a
    # manifest so large that downstream tools would reject it.
    postcondition {
      condition     = length(self.content) < 2000
      error_message = "manifest is unexpectedly large (>= 2000 bytes)."
    }
  }
}

# A check block never blocks a plan or apply: failure is a warning in normal use.
check "retention_is_reasonable" {
  assert {
    condition     = var.retention_days <= 2555
    error_message = "retention_days is above 7 years (2555); is that intended?"
  }
}
