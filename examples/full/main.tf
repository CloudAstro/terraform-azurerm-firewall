resource "azurerm_resource_group" "rg" {
  name     = "rg-nic-example"
  location = "germanywestcentral"
}

module "vnet" {
  source = "CloudAstro/virtual-network/azurerm"

  name                = "vnet-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "snet" {
  source = "CloudAstro/subnet/azurerm"

  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "management_snet" {
  source = "CloudAstro/subnet/azurerm"

  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = module.vnet.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

module "public_ip_fw" {
  source = "CloudAstro/public-ip/azurerm"

  name                = "public-ip-fw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]
}

module "public_ip_mgmt" {
  source = "CloudAstro/public-ip/azurerm"

  name                = "public-ip-mgmt"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  zones               = ["1", "2", "3"]
}

module "firewall" {
  source = "../.."

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "fw-hub"
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  zones               = ["1", "2", "3"]
  firewall_policy_id  = null
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  dns_proxy_enabled   = true
  private_ip_ranges   = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  threat_intel_mode   = "Alert"

  ip_configuration = {
    ipconfig = {
      name                 = "fw-ipconfig"
      subnet_id            = module.snet.subnet.id
      public_ip_address_id = module.public_ip_fw.publicip.id
    }
  }

  management_ip_configuration = {
    name                 = "fw-mgmt"
    subnet_id            = module.management_snet.subnet.id
    public_ip_address_id = module.public_ip_mgmt.publicip.id
  }

  application_rule_collection = {
    app_rules = {
      name                = "fw-app-rules"
      resource_group_name = azurerm_resource_group.rg.name
      priority            = 100
      action              = "Allow"
      rules = [
        {
          name             = "rule1"
          description      = "Allow example traffic"
          source_addresses = ["10.0.0.0/24"]
          target_fqdns     = ["example.com"]
          protocols = [{
            type = "Http"
            port = 80
            },
            {
              type = "Https"
              port = 443
          }]
        }
      ]
    }
  }

  nat_rule_collection = {
    nat_rules = {
      name                = "fw-nat-rules"
      resource_group_name = azurerm_resource_group.rg.name
      priority            = 100
      action              = "Dnat"
      rules = [
        {
          name                  = "nat-rule1"
          description           = "NAT rule example"
          source_addresses      = ["0.0.0.0/0"]
          destination_addresses = [module.public_ip_fw.publicip.ip_address]
          destination_ports     = ["80"]
          protocols             = ["TCP"]
          translated_address    = "10.0.1.10"
          translated_port       = 8080
        }
      ]
    }
  }

  tags = {
    environment = "production"
    team        = "network"
  }
}
