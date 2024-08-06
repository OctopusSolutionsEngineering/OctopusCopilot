resource "octopusdeploy_user" "example" {
  display_name  = "Bob Smith"
  email_address = "bob.smith@example.com"
  is_active     = true
  is_service    = true
  username      = "bsmith"
}