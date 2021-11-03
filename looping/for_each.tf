
# Using a Map/Object

variable "location" {
  type        = map(string)
  description = "(optional) describe your variable"
  default = {
    rg01 = "uksouth"
    rg02 = "ukwest"
  }
}

resource "azurerm_resource_group" "rg_map" {
  for_each = var.location

  name     = each.key
  location = each.value
}

# Using a more complex Map/Object

variable "complex_obj" {
  type = map(object({
    location = string
    name     = string
    tags     = map(string)
  }))
  default = {
    "rg03" = {
      location = "uksouth"
      name     = "rg03"
      tags = {
        "key" = "value"
      }
    }
    "rg04" = {
      location = "ukwest"
      name     = "rg04"
      tags = {
        "key" = "value"
      }
    }
  }
}

resource "azurerm_resource_group" "rg_complex_map" {
  for_each = var.complex_obj

  name     = each.value["name"]
  location = each.value["location"]

  tags = each.value["tags"]
}

# Using a set (list) of strings

variable "name" {
  type        = list(string)
  description = "(optional) describe your variable"
  default     = ["john", "paul", "george", "ringo"]
}

resource "azurerm_resource_group" "rg_set" {
  for_each = toset(var.name)

  name     = each.key
  location = "uksouth"
}