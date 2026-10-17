# tf-validation-guardrails

The three places Terraform can stop a bad change, side by side, with a test for each: variable validation, resource preconditions and postconditions, and `check` blocks.

> **What is verified.** The "bucket" is a manifest file written with `hashicorp/local`, so there is no cloud account involved. On 2026-10-17, with Terraform 1.16.5 on Windows, `terraform test` passed 11 of 11 runs. CI repeats this on Linux.

## The layers

| Layer | Where | Blocks the plan? | Use it for |
|---|---|---|---|
| `validation` on a variable | `variables.tf` | yes, before anything is evaluated | one input being malformed: name format, enum, range, whole number |
| Cross-variable `validation` | `retention_days` reads `var.classification` | yes | two inputs that must agree (Terraform 1.9+) |
| `precondition` | `lifecycle` of the resource | yes, before creating it | a *combination* of values or data that must hold: restricted data must be encrypted |
| `postcondition` | `lifecycle` of the resource | yes, after creating it | what the resource turned out to be (here: manifest size) |
| `check` block | `main.tf` | **no**, warning only | "this looks unusual" rules that should not stop a deploy |

## What the tests cover

Valid input plans and applies; uppercase and double-dot bucket names, a bad email, an unknown classification and a fractional retention are each rejected by the variable that owns the rule; restricted data with short retention is rejected by the cross-variable rule; restricted data unencrypted is rejected by the precondition; very long retention fires the check block.

## Also shown: a sensitive input

`api_token` is `sensitive`. The output shows only the first 8 hex characters of its SHA-256, which needs `nonsensitive()`, because a hash of a sensitive value is still marked sensitive. That is a deliberate, reviewed use, and the comment says so.

## Honest limits

- **The postcondition is never triggered by a test.** It is hard to exceed 2000 bytes with these inputs, so it is documented but only proven to *not* fire on valid input.
- A `check` failure only warns in normal use. The test lists it under `expect_failures` to assert that it fires; do not read that as "check blocks fail runs".
- Regexes are intentionally simple (the email one is not RFC 5322).
- The `out/` directory is where the manifest is written; it is gitignored and cleaned up by the test run.

## Run it

```
terraform init
terraform test
```

Needs Terraform 1.9 or later.
