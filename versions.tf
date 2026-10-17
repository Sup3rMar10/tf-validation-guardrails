terraform {
  required_version = ">= 1.9" # validation blocks that reference other variables need 1.9 or later
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
