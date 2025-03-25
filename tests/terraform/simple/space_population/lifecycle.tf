resource "octopusdeploy_lifecycle" "simple_lifecycle" {
  description = "A test lifecycle"
  name        = "Simple"

  release_retention_policy {
    quantity_to_keep    = 1
    should_keep_forever = false
    unit                = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Items"
  }

  phase {
    automatic_deployment_targets = []
    optional_deployment_targets  = [octopusdeploy_environment.environment_development.id]
    name                         = octopusdeploy_environment.environment_development.name

    release_retention_policy {
      quantity_to_keep    = 1
      should_keep_forever = false
      unit                = "Days"
    }

    tentacle_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Items"
    }
  }

  phase {
    automatic_deployment_targets = []
    optional_deployment_targets  = [octopusdeploy_environment.environment_production.id]
    name                         = octopusdeploy_environment.environment_production.name

    release_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Days"
    }

    tentacle_retention_policy {
      quantity_to_keep    = 30
      should_keep_forever = false
      unit                = "Items"
    }
  }
}