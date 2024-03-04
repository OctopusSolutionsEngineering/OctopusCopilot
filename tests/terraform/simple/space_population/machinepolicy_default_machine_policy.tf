data "octopusdeploy_machine_policies" "default_machine_policy" {
  ids          = null
  partial_name = "Default Machine Policy"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a machine policy called \"default_machine_policy\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.machine_policies) != 0
    }
  }
}
