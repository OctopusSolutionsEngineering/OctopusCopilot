resource "octopusdeploy_git_credential" "gitcredential_test" {
  description = "GitHub Credentials"
  name        = "test"
  type        = "UsernamePassword"
  username    = "admin"
  password    = "${var.gitcredential_test}"
}
variable "gitcredential_test" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential test"
  default     = "Password01!"
}
