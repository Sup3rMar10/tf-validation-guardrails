output "manifest_path" {
  value = local_file.manifest.filename
}

output "token_fingerprint" {
  description = "First 8 hex chars of the token's SHA-256. The token itself never appears in output."
  # sha256() of a sensitive value is itself marked sensitive; nonsensitive() is a deliberate,
  # reviewed decision here because a truncated hash does not reveal the token.
  value = nonsensitive(substr(sha256(var.api_token), 0, 8))
}
