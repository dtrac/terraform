
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