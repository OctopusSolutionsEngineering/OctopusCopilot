terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeployLabs/octopusdeploy", version = "0.21.5" }
  }

  backend "azurerm" {
  }

  required_version = ">= 1.6.0"
}
