variables {
  bucket_name = "team-data-prod"
  owner_email = "owner@example.com"
}

run "valid_defaults_plan" {
  command = plan
}

run "valid_apply_writes_manifest" {
  command = apply

  assert {
    condition     = jsondecode(local_file.manifest.content).classification == "internal"
    error_message = "default classification should be internal"
  }

  assert {
    condition     = length(output.token_fingerprint) == 8
    error_message = "fingerprint should be 8 hex chars"
  }
}

run "uppercase_bucket_name_rejected" {
  command = plan
  variables { bucket_name = "Team-Data" }
  expect_failures = [var.bucket_name]
}

run "double_dot_bucket_name_rejected" {
  command = plan
  variables { bucket_name = "team..data" }
  expect_failures = [var.bucket_name]
}

run "bad_email_rejected" {
  command = plan
  variables { owner_email = "not-an-email" }
  expect_failures = [var.owner_email]
}

run "unknown_classification_rejected" {
  command = plan
  variables { classification = "secret" }
  expect_failures = [var.classification]
}

run "fractional_retention_rejected" {
  command = plan
  variables { retention_days = 30.5 }
  expect_failures = [var.retention_days]
}

run "restricted_needs_long_retention" {
  command = plan
  variables {
    classification = "restricted"
    retention_days = 30
  }
  expect_failures = [var.retention_days]
}

run "restricted_must_be_encrypted" {
  command = plan
  variables {
    classification     = "restricted"
    retention_days     = 400
    encryption_enabled = false
  }
  # The precondition lives on the resource, so that is what the test expects to fail.
  expect_failures = [local_file.manifest]
}

run "restricted_encrypted_long_retention_is_fine" {
  command = plan
  variables {
    classification = "restricted"
    retention_days = 400
  }
}

run "very_long_retention_only_warns" {
  command = plan
  variables {
    retention_days = 4000
  }
  # check blocks are non-blocking in normal use; the test lists it explicitly to assert it fired.
  expect_failures = [check.retention_is_reasonable]
}
