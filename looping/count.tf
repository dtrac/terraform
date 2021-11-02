data "azuread_client_config" "current" {}

resource "azuread_user" "user" {

  count = 3

  user_principal_name = "upn${count.index}@trace.com"
  display_name        = "UPN ${count.index}"

}

resource "azuread_group" "group" {

  count = 2

  display_name     = "group${count.index}"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

}