resource "azurerm_resource_group" "private_fapp" {
  name     = "private-fapp-rg"
  location = "uksouth"
}


resource "azurerm_virtual_network" "private_fapp" {
  name                = "private-fapp-vnet"
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_resource_group.private_fapp.location
  resource_group_name = azurerm_resource_group.private_fapp.name
}

resource "azurerm_subnet" "pendp" {
  name                 = "pendp"
  resource_group_name  = azurerm_resource_group.private_fapp.name
  virtual_network_name = azurerm_virtual_network.private_fapp.name
  address_prefixes     = ["192.168.1.0/27"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "fapp" {
  name                 = "fapp"
  resource_group_name  = azurerm_resource_group.private_fapp.name
  virtual_network_name = azurerm_virtual_network.private_fapp.name
  address_prefixes     = ["192.168.1.32/27"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_storage_account" "private_fapp" {
  name                     = "dantprivatefapp"
  resource_group_name      = azurerm_resource_group.private_fapp.name
  location                 = azurerm_resource_group.private_fapp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_private_endpoint" "private_fapp_blob" {
  name                = "fapp-blob-storage-endpoint"
  location            = azurerm_resource_group.private_fapp.location
  resource_group_name = azurerm_resource_group.private_fapp.name
  subnet_id           = azurerm_subnet.pendp.id

  private_service_connection {
    name                           = "fapp-blob-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.private_fapp.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.private_fapp.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "blob-to-fapp-vnet"
  resource_group_name   = azurerm_resource_group.private_fapp.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.private_fapp.id
}

resource "azurerm_app_service_plan" "private_fapp" {
  name                = "azure-functions-test-service-plan"
  location            = azurerm_resource_group.private_fapp.location
  resource_group_name = azurerm_resource_group.private_fapp.name
  kind                = "Windows"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "private_fapp" {
  app_service_id = azurerm_function_app.private_fapp.id
  subnet_id      = azurerm_subnet.fapp.id
}

resource "azurerm_function_app" "private_fapp" {
  name                       = "test-private-fapp"
  location                   = azurerm_resource_group.private_fapp.location
  resource_group_name        = azurerm_resource_group.private_fapp.name
  app_service_plan_id        = azurerm_app_service_plan.private_fapp.id
  storage_account_name       = azurerm_storage_account.private_fapp.name
  storage_account_access_key = azurerm_storage_account.private_fapp.primary_access_key

  app_settings = {
    "WEBSITE_VNET_ROUTE_ALL"      = "1"
    "WEBSITE_DNS_SERVER"          = "168.63.129.16"
    "FUNCTIONS_EXTENSION_VERSION" = "~3"
  }
}