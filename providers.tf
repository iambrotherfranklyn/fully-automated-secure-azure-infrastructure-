terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "=3.0.0"
      version = "~>3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}



