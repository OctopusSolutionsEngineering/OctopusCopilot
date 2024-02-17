resource "octopusdeploy_variable" "octopus_copilot_function_octopus_azure_account_1" {
  owner_id     = "${octopusdeploy_project.project_octopus_copilot_function.id}"
  value        = "${data.octopusdeploy_accounts.account_azure___solutions_engineering.accounts[0].id}"
  name         = "Octopus.Azure.Account"
  type         = "AzureAccount"
  is_sensitive = false
  lifecycle {
    ignore_changes = all
  }
}
