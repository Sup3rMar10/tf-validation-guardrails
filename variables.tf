variable "bucket_name" {
  type        = string
  description = "Name of the (pretend) storage bucket."

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 chars of lowercase letters, digits, dots or hyphens, starting and ending alphanumeric."
  }

  validation {
    condition     = !can(regex("[.][.]", var.bucket_name))
    error_message = "bucket_name must not contain consecutive dots."
  }
}

variable "owner_email" {
  type = string

  validation {
    condition     = can(regex("^[^@ ]+@[^@ ]+[.][a-z]{2,}$", var.owner_email))
    error_message = "owner_email must look like an email address."
  }
}

variable "classification" {
  type    = string
  default = "internal"

  validation {
    condition     = contains(["public", "internal", "restricted"], var.classification)
    error_message = "classification must be public, internal or restricted."
  }
}

variable "retention_days" {
  type    = number
  default = 90

  validation {
    condition     = var.retention_days >= 1 && var.retention_days == floor(var.retention_days)
    error_message = "retention_days must be a whole number of at least 1."
  }

  # Cross-variable validation: this rule reads var.classification (Terraform 1.9+).
  validation {
    condition     = var.classification != "restricted" || var.retention_days >= 365
    error_message = "restricted data must be retained for at least 365 days."
  }
}

variable "encryption_enabled" {
  type    = bool
  default = true
}

variable "api_token" {
  type      = string
  sensitive = true
  default   = "not-a-real-token"
}
