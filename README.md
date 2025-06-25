<!-- BEGINNING OF PRE-COMMIT-OPENTOFU DOCS HOOK -->
# Azure Firewall Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-blue.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![OpenTofu Registry](https://img.shields.io/badge/opentofu-registry-yellow.svg)](https://search.opentofu.org/module/CloudAstro/azure-firewall/azurerm/)

This module manages the creation and configuration of Azure Firewall resources in Microsoft Azure. It supports advanced features such as custom rule collections, policy association, threat intelligence settings, and IP configurations.

## Features

- **Firewall Deployment**: Provision Azure Firewall in a specified virtual network and subnet (`AzureFirewallSubnet`).
- **IP Configuration**: Support for both public and private IP configurations.
- **Firewall Policies**: Attach Azure Firewall Policies to centralize rule and configuration management.
- **Rule Collections**: Define network, application, and NAT rule collections directly within the module.
- **Threat Intelligence**: Enable threat intelligence-based filtering to detect and block traffic from known malicious IP addresses.

## Example Usage

This example demonstrates how to deploy an Azure Firewall with custom rule collections and optional policy association.

```hcl
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
```
<!-- markdownlint-disable MD033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_application_rule_collection.app_rule_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_application_rule_collection) | resource |
| [azurerm_firewall_nat_rule_collection.nat_rule_collection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_nat_rule_collection) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

<!-- markdownlint-disable MD013 -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | * `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.<br/> <br/>  Example Input:<pre>location = "germanywestcentral"</pre> | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | * `name` - (Required) Specifies the name of the Firewall. Changing this forces a new resource to be created. <br/> <br/>  Example Input:<pre>name = "fw-gwc-dev"</pre> | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | * `resource_group_name` - (Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created. <br/><br/>  Example Input:<pre>resource_group_name = "rg-azure-firewall-dev"</pre> | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | * `sku_name` - (Required) SKU name of the Firewall. Possible values are `AZFW_Hub` and `AZFW_VNet`. Changing this forces a new resource to be created.<br/> <br/>  Example Input:<pre>sku_name = "AZFW_Hub"</pre> | `string` | n/a | yes |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | * `sku_tier` - (Required) SKU tier of the Firewall. Possible values are `Premium`, `Standard` and `Basic`.<br/> <br/>  Example Input:<pre>sku_tier = "Standard"</pre> | `string` | n/a | yes |
| <a name="input_application_rule_collection"></a> [application\_rule\_collection](#input\_application\_rule\_collection) | * `firewall_application_rule_collection` - Manages an Application Rule Collection within an Azure Firewall.<br/>  * `name` - (Required) Specifies the name of the Application Rule Collection which must be unique within the Firewall. Changing this forces a new resource to be created.<br/>  * `azure_firewall_name` - (Required) Specifies the name of the Firewall in which the Application Rule Collection should be created. Changing this forces a new resource to be created.<br/>  * `resource_group_name` - (Required) Specifies the name of the Resource Group in which the Firewall exists. Changing this forces a new resource to be created.<br/>  * `priority` - (Required) Specifies the priority of the rule collection. Possible values are between `100` - `65000`.<br/>  * `action` - (Required) Specifies the action the rule will apply to matching traffic. Possible values are `Allow` and `Deny`.<br/>  * `rule` - (Required) One or more `rule` blocks as defined below.<br/>   * `name` - (Required) Specifies the name of the rule.<br/>   * `description` - (Optional) Specifies a description for the rule.<br/>   * `source_addresses` - (Optional) A list of source IP addresses and/or IP ranges.<br/>   * `source_ip_groups` - (Optional) A list of source IP Group IDs for the rule.<br/> <br/>     -> **NOTE** At least one of `source_addresses` and `source_ip_groups` must be specified for a rule.<br/>   * `fqdn_tags` - (Optional) A list of FQDN tags. Possible values are `AppServiceEnvironment`, `AzureBackup`, `AzureKubernetesService`, `HDInsight`, `MicrosoftActiveProtectionService`, `WindowsDiagnostics`, `WindowsUpdate` and `WindowsVirtualDesktop`.<br/>   * `target_fqdns` - (Optional) A list of FQDNs.<br/>   * `protocol` - (Optional) One or more `protocol` blocks as defined below.<br/>    * `port` - (Required) Specify a port for the connection.<br/>    * `type` - (Required) Specifies the type of connection. Possible values are `Http`, `Https` and `Mssql`.<br/><br/>  Example Input:<pre>application_rule_collection = {<br/>   app-rules = {<br/>    name                = "my-application-rule-collection"<br/>    azure_firewall_name = azurerm_firewall.firewall.name<br/>    resource_group_name = azurerm_resource_group.firewall_rg.name<br/>    priority            = 100<br/>    action              = "Allow"<br/>    rules = [<br/>      {<br/>        name             = "AllowWebTraffic"<br/>        description      = "Allow web traffic to example.com"<br/>        source_addresses = ["*"]<br/>        protocols = [<br/>          { type = "Http",  port = 80 },<br/>          { type = "Https", port = 443 },<br/>        ]<br/>        target_fqdns = ["www.example.com"]<br/>        fqdn_tags    = null<br/>      },<br/>      {<br/>        name             = "AllowSQLTraffic"<br/>        description      = "Allow SQL traffic to database.example.com"<br/>        source_ip_groups = ["/subscriptions/xxxx/resourceGroups/rg-example/providers/Microsoft.Network/ipGroups/app-ips"]<br/>        protocols = [<br/>          { type = "Mssql", port = 1433 }<br/>        ]<br/>        target_fqdns = ["database.example.com"]<br/>        fqdn_tags    = null<br/>      }<br/>    ]<br/>   }<br/>  }</pre> | <pre>map(object({<br/>    name                = string<br/>    resource_group_name = string<br/>    priority            = number<br/>    action              = string<br/>    rules = list(object({<br/>      name             = string<br/>      description      = optional(string)<br/>      source_addresses = optional(list(string))<br/>      source_ip_groups = optional(list(string))<br/>      protocols = optional(list(object({<br/>        type = string<br/>        port = number<br/>      })))<br/>      target_fqdns = optional(list(string))<br/>      fqdn_tags    = optional(list(string))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | The following arguments are supported:<br/>  * `name` - (Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created.<br/><br/>   -> **NOTE:** If the name is set to 'service' it will not be possible to fully delete the diagnostic setting. This is due to legacy API support.<br/>  * `target_resource_id` - (Required) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created.<br/>  * `eventhub_name` - (Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent.<br/><br/>   -> **NOTE:** If this isn't specified then the default Event Hub will be used.<br/>  * `eventhub_authorization_rule_id` - (Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data.<br/><br/>   -> **NOTE:** This can be sourced from [the `azurerm_eventhub_namespace_authorization_rule` resource](eventhub\_namespace\_authorization\_rule.html) and is different from [a `azurerm_eventhub_authorization_rule` resource](eventhub\_authorization\_rule.html).<br/><br/>   -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `enabled_log` - (Optional) One or more `enabled_log` blocks as defined below.<br/><br/>   -> **NOTE:** At least one `enabled_log` or `metric` block must be specified. At least one type of Log or Metric must be enabled.<br/>   * `category` - (Optional) The name of a Diagnostic Log Category for this Resource.<br/><br/>    -> **NOTE:** The Log Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor\_diagnostic\_categories.html) or [list of service specific schemas](https://docs.microsoft.com/azure/azure-monitor/platform/resource-logs-schema#service-specific-schemas) to identify which categories are available for a given Resource.<br/>   * `category_group` - (Optional) The name of a Diagnostic Log Category Group for this Resource.<br/><br/>    -> **NOTE:** Not all resources have category groups available.<br/><br/>    -> **NOTE:** Exactly one of `category` or `category_group` must be specified.<br/>  * `log_analytics_workspace_id` - (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.<br/><br/>  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `enabled_metric` - (Optional) One or more `enabled_metric` blocks as defined below.<br/><br/>   -> **Note:** At least one `enabled_log` or `enabled_metric` block must be specified.<br/>   * `category` - (Required) The name of a Diagnostic Metric Category for this Resource.<br/><br/>    -> **Note:** The Metric Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor\_diagnostic\_categories.html) to identify which categories are available for a given Resource.<br/>  * `storage_account_id` - (Optional) The ID of the Storage Account where logs should be sent.<br/><br/>   -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `log_analytics_destination_type` - (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to `Dedicated`, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.<br/><br/>   -> **NOTE:** This setting will only have an effect if a `log_analytics_workspace_id` is provided. For some target resource type (e.g., Key Vault), this field is unconfigurable. Please see [resource types](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types) for services that use each method. Please [see the documentation](https://docs.microsoft.com/azure/azure-monitor/platform/diagnostic-logs-stream-log-store#azure-diagnostics-vs-resource-specific) for details on the differences between destination types.<br/>  * `partner_solution_id` - (Optional) The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, [click to learn more about partner integration](https://learn.microsoft.com/en-us/azure/partner-solutions/overview).<br/><br/>   -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.<br/>  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>    * `create` - (Defaults to 30 minutes) Used when creating the Diagnostics Setting.<br/>    * `read` - (Defaults to 5 minutes) Used when retrieving the Diagnostics Setting.<br/>    * `update` - (Defaults to 30 minutes) Used when updating the Diagnostics Setting.<br/>    * `delete` - (Defaults to 1 hour) Used when deleting the Diagnostics Setting.<br/><br/>  Example Input:<pre>diagnostic_settings = {<br/>    diagnostic = {<br/>      name                           = "diagnostic"<br/>      log_analytics_workspace_id     = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.OperationalInsights/workspaces/myLogAnalyticsWorkspace"<br/>      storage_account_id             = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"<br/>      log_analytics_destination_type = "Dedicated"<br/>      eventhub_authorization_rule_id = null<br/>      eventhub_name                  = null<br/>      partner_solution_id            = null<br/>      enabled_log = [<br/>        {<br/>          category       = null<br/>          category_group = "allLogs"<br/>        }<br/>      ]<br/>      enabled_metric = {<br/>        category = "AllMetrics"<br/>      }<br/>      timeouts = {<br/>       create  = "30m"<br/>       read    = "5m"<br/>       update  = "30m"<br/>       delete  = "1h"<br/>      }<br/>    }<br/>  }</pre> | <pre>map(object({<br/>    name                           = optional(string)<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string, "Dedicated")<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    partner_solution_id            = optional(string)<br/>    enabled_log = optional(list(object({<br/>      category       = optional(string)<br/>      category_group = optional(string)<br/>    })))<br/>    metric = optional(object({<br/>      category = optional(string, "AllMetrics")<br/>      enabled  = optional(bool)<br/>    }))<br/>    timeouts = object({<br/>      create = optional(string, "30")<br/>      read   = optional(string, "5")<br/>      update = optional(string, "30")<br/>      delete = optional(string, "1")<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_dns_proxy_enabled"></a> [dns\_proxy\_enabled](#input\_dns\_proxy\_enabled) | * `dns_proxy_enabled` - (Optional) Whether DNS proxy is enabled. It will forward DNS requests to the DNS servers when set to `true`. It will be set to `true` if `dns_servers` provided with a not empty list.<br/><br/>  Example Input:<pre>dns_proxy_enabled = true</pre> | `bool` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | * `dns_servers` - (Optional) A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution.<br/><br/>  Example Input:<pre>dns_servers = ["8.8.8.8", "8.8.4.4"]</pre> | `list(string)` | `null` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | * `firewall_policy_id` - (Optional) The ID of the Firewall Policy applied to this Firewall.<br/> <br/>  Example Input:<pre>firewall_policy_id = "/subscriptions/12345678-9abc-def0-1234-56789abcdef0/resourceGroups/rg-firewall/providers/Microsoft.Network/firewallPolicies/fw-policy-default"</pre> | `string` | `null` | no |
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | * `ip_configuration` - (Optional) An `ip_configuration` block as documented below.<br/>  * `name` - (Required) Specifies the name of the IP Configuration.<br/>  * `subnet_id` - (Optional) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.<br/><br/>   -> **NOTE** The Subnet used for the Firewall must have the name `AzureFirewallSubnet` and the subnet mask must be at least a `/26`.<br/> <br/>   -> **NOTE** At least one and only one `ip_configuration` block may contain a `subnet_id`.<br/>  * `public_ip_address_id` - (Optional) The ID of the Public IP Address associated with the firewall.<br/><br/>   -> **NOTE** A public ip address is required unless a `management_ip_configuration` block is specified.<br/> <br/>   -> **NOTE** When multiple `ip_configuration` blocks with `public_ip_address_id` are configured, `terraform apply` will raise an error when one or some of these `ip_configuration` blocks are removed. because the `public_ip_address_id` is still used by the `firewall` resource until the `firewall` resource is updated. and the destruction of `azurerm_public_ip` happens before the update of firewall by default. to destroy of `azurerm_public_ip` will cause the error. The workaround is to set `create_before_destroy=true` to the `azurerm_public_ip` resource `lifecycle` block. See more detail: [destroying.md#create-before-destroy](https://github.com/hashicorp/terraform/blob/main/docs/destroying.md#create-before-destroy)<br/> <br/>   -> **NOTE** The Public IP must have a `Static` allocation and `Standard` SKU.<br/><br/>  Example Input:<pre>ip_configuration = {<br/>    "primary" = {<br/>      name                 = "ipconfig1"<br/>      subnet_id            = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/mySubnet"<br/>      public_ip_address_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/publicIPAddresses/myPublicIPAdresses"<br/>    }<br/>  }</pre> | <pre>map(object({<br/>    name                 = string<br/>    subnet_id            = optional(string)<br/>    public_ip_address_id = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_lock"></a> [lock](#input\_lock) | * `managment_lock` -  Manages a Management Lock which is scoped to a Subscription, Resource Group or Resource.<br/>    * `name` - (Required) Specifies the name of the Management Lock. Changing this forces a new resource to be created.<br/>    * `scope` - (Required) Specifies the scope at which the Management Lock should be created. Changing this forces a new resource to be created.<br/>    * `lock_level` - (Required) Specifies the Level to be used for this Lock. Possible values are `CanNotDelete` and `ReadOnly`. Changing this forces a new resource to be created.<br/><br/>     ~> **Note:** `CanNotDelete` means authorized users are able to read and modify the resources, but not delete. `ReadOnly` means authorized users can only read from a resource, but they can't modify or delete it.<br/>    * `notes` - (Optional) Specifies some notes about the lock. Maximum of 512 characters. Changing this forces a new resource to be created.<br/><br/> Example Input:<pre>lock = {<br/>   kind  = "CanNotDelete"<br/>   name  = "prevent-deletion-lock"<br/>   scope = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/my-vm"<br/>   notes = "This lock prevents accidental deletion of the VM."<br/>  }</pre> | <pre>object({<br/>    kind = string<br/>    name = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_management_ip_configuration"></a> [management\_ip\_configuration](#input\_management\_ip\_configuration) | * `management_ip_configuration` - (Optional) A `management_ip_configuration` block as documented below, which allows force-tunnelling of traffic to be performed by the firewall. Adding or removing this block or changing the `subnet_id` in an existing block forces a new resource to be created. Changing this forces a new resource to be created.<br/>  * `name` - (Required) Specifies the name of the IP Configuration.<br/>  * `subnet_id` - (Required) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.<br/> <br/>   -> **NOTE** The Management Subnet used for the Firewall must have the name `AzureFirewallManagementSubnet` and the subnet mask must be at least a `/26`.<br/>  * `public_ip_address_id` - (Required) The ID of the Public IP Address associated with the firewall.<br/> <br/>   -> **NOTE** The Public IP must have a `Static` allocation and `Standard` SKU.<br/><br/>  Example Input:<pre>management_ip_configuration = {<br/>    name                 = "managementIpConfig"<br/>    subnet_id            = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/mySubnet"<br/>    public_ip_address_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/publicIPAddresses/myPublicIPAdresses"<br/>  }</pre> | <pre>object({<br/>    name                 = string<br/>    subnet_id            = string<br/>    public_ip_address_id = string<br/>  })</pre> | `null` | no |
| <a name="input_nat_rule_collection"></a> [nat\_rule\_collection](#input\_nat\_rule\_collection) | * `firewall_nat_rule_collection` - Manages a NAT Rule Collection within an Azure Firewall.<br/>  * `name` - (Required) Specifies the name of the NAT Rule Collection which must be unique within the Firewall. Changing this forces a new resource to be created.<br/>  * `azure_firewall_name` - (Required) Specifies the name of the Firewall in which the NAT Rule Collection should be created. Changing this forces a new resource to be created.<br/>  * `resource_group_name` - (Required) Specifies the name of the Resource Group in which the Firewall exists. Changing this forces a new resource to be created.<br/>  * `priority` - (Required) Specifies the priority of the rule collection. Possible values are between `100` - `65000`.<br/>  * `action` - (Required) Specifies the action the rule will apply to matching traffic. Possible values are `Dnat` and `Snat`.<br/>  * `rule` - (Required) One or more `rule` blocks as defined below.<br/>    * `name` - (Required) Specifies the name of the rule.<br/>    * `description` - (Optional) Specifies a description for the rule.<br/>    * `destination_addresses` - (Required) A list of destination IP addresses and/or IP ranges.<br/>    * `destination_ports` - (Required) A list of destination ports.<br/>    * `protocols` - (Required) A list of protocols. Possible values are `Any`, `ICMP`, `TCP` and `UDP`. If `action` is `Dnat`, protocols can only be `TCP` and `UDP`.<br/>    * `source_addresses` - (Optional) A list of source IP addresses and/or IP ranges.<br/>    * `source_ip_groups` - (Optional) A list of source IP Group IDs for the rule.<br/> <br/>     -> **NOTE** At least one of `source_addresses` and `source_ip_groups` must be specified for a rule.<br/>    * `translated_address` - (Required) The address of the service behind the Firewall.<br/>    * `translated_port` - (Required) The port of the service behind the Firewall.<br/><br/>  Example Input:<pre>nat_rule_collection = {<br/>   nat-rules = {<br/>    name                = "my-nat-rule-collection"<br/>    azure_firewall_name = azurerm_firewall.firewall.name<br/>    resource_group_name = azurerm_resource_group.firewall_rg.name<br/>    priority            = 200<br/>    action              = "Dnat"<br/>    rules = [<br/>      {<br/>        name                  = "DNAT-SSH"<br/>        description           = "DNAT rule for SSH access"<br/>        source_addresses      = ["*"]<br/>        destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]<br/>        destination_ports     = ["22"]<br/>        protocols             = ["TCP"]<br/>        translated_address    = "10.0.0.4"<br/>        translated_port       = 22<br/>      },<br/>      {<br/>        name                  = "DNAT-HTTP"<br/>        description           = "DNAT rule for HTTP traffic"<br/>        source_addresses      = ["*"]<br/>        destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]<br/>        destination_ports     = ["80"]<br/>        protocols             = ["TCP"]<br/>        translated_address    = "10.0.0.5"<br/>        translated_port       = 8080<br/>      }<br/>    ]<br/>   }<br/>  }</pre> | <pre>map(object({<br/>    name                = string<br/>    resource_group_name = string<br/>    priority            = number<br/>    action              = string<br/>    rules = list(object({<br/>      name                  = string<br/>      description           = optional(string)<br/>      destination_addresses = list(string)<br/>      destination_ports     = list(string)<br/>      protocols             = list(string)<br/>      source_addresses      = optional(list(string))<br/>      source_ip_groups      = optional(list(string))<br/>      translated_address    = string<br/>      translated_port       = number<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | * `private_ip_ranges` - (Optional) A list of SNAT private CIDR IP ranges, or the special string IANAPrivateRanges, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918.<br/> <br/> Example Input:<pre>private_ip_ranges = ["10.20.0.0/24", "192.168.0.0/16"]</pre> | `list(string)` | `null` | no |
| <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments) | * `role_assignments` - Assigns a given Principal (User or Group) to a given Role.<br/>  * `name` - (Optional) A unique UUID/GUID for this Role Assignment - one will be generated if not specified. Changing this forces a new resource to be created.<br/>  * `scope` - (Required) The scope at which the Role Assignment applies to, such as `/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333`, `/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup`, or `/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup/providers/Microsoft.Compute/virtualMachines/myVM`, or `/providers/Microsoft.Management/managementGroups/myMG`. Changing this forces a new resource to be created.<br/>  * `role_definition_id` - (Optional) The Scoped-ID of the Role Definition. Changing this forces a new resource to be created. Conflicts with `role_definition_name`.<br/>  * `role_definition_name` - (Optional) The name of a built-in Role. Changing this forces a new resource to be created. Conflicts with `role_definition_id`.<br/>  * `principal_id` - (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.<br/><br/>   * ~> **NOTE:** The Principal ID is also known as the Object ID (ie not the "Application ID" for applications).<br/>  * `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.<br/><br/>   * ~> **NOTE:** If one of `condition` or `condition_version` is set both fields must be present.<br/>  * `condition` - (Optional) The condition that limits the resources that the role can be assigned to. Changing this forces a new resource to be created.<br/>  * `condition_version` - (Optional) The version of the condition. Possible values are `1.0` or `2.0`. Changing this forces a new resource to be created.<br/>  * `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.<br/><br/>   * ~> **NOTE:** this field is only used in cross tenant scenario.<br/>  * `description` - (Optional) The description for this Role Assignment. Changing this forces a new resource to be created.<br/>  * `skip_service_principal_aad_check` - (Optional) If the `principal_id` is a newly provisioned `Service Principal` set this value to `true` to skip the `Azure Active Directory` check which may fail due to replication lag. This argument is only valid if the `principal_id` is a `Service Principal` identity. Defaults to `false`.<br/><br/>   * ~> **NOTE:** If it is not a `Service Principal` identity it will cause the role assignment to fail.<br/>  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>   * `create` - (Defaults to 30 minutes) Used when creating the Role Assignment.<br/>   * `read` - (Defaults to 5 minutes) Used when retrieving the Role Assignment.<br/>   * `delete` - (Defaults to 30 minutes) Used when deleting the Role Assignment.<br/><br/>  Example Input:<pre>role_assignments = {<br/>    assignment1 = {<br/>      name                                   = "AppRoleContributor"<br/>      scope                                  = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup"<br/>      role_definition_name                   = "Contributor"<br/>      principal_id                           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"<br/>      principal_type                         = "User"<br/>      condition                              = "resource.type == 'Microsoft.Storage/storageAccounts'"<br/>      condition_version                      = "2.0"<br/>      delegated_managed_identity_resource_id = null<br/>      description                            = "Contributor role assignment for the application team"<br/>      skip_service_principal_aad_check       = false<br/>      timeouts = {<br/>       create  = "30m"<br/>       read    = "5m"<br/>       delete  = "30m"<br/>      }<br/>    }<br/>  }</pre> | <pre>map(object({<br/>    name                                   = optional(string)<br/>    role_definition_id                     = optional(string)<br/>    role_definition_name                   = optional(string)<br/>    principal_id                           = string<br/>    principal_type                         = optional(string)<br/>    condition                              = optional(string)<br/>    condition_version                      = optional(string)<br/>    delegated_managed_identity_resource_id = optional(string)<br/>    description                            = optional(string)<br/>    skip_service_principal_aad_check       = optional(bool, false)<br/>    timeouts = object({<br/>      create = optional(string, "30")<br/>      read   = optional(string, "5")<br/>      delete = optional(string, "30")<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | * `tags` - (Optional) A mapping of tags to assign to the resource.<br/><br/>  Example Input:<pre>tags = {<br/>    env     = test<br/>    region  = gwc<br/>  }</pre> | `map(string)` | `null` | no |
| <a name="input_threat_intel_mode"></a> [threat\_intel\_mode](#input\_threat\_intel\_mode) | * `threat_intel_mode` - (Optional) The operation mode for threat intelligence-based filtering. Possible values are: `Off`, `Alert` and `Deny`. Defaults to `Alert`.<br/> <br/>  Example Input:<pre>threat_intel_mode = "Alert"</pre> | `string` | `"Alert"` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:<br/>    * `create` - (Defaults to 90 minutes) Used when creating the Firewall.<br/>    * `read` - (Defaults to 5 minutes) Used when retrieving the Firewall.<br/>    * `update` - (Defaults to 90 minutes) Used when updating the Firewall.<br/>    * `delete` - (Defaults to 90 minutes) Used when deleting the Firewall.<br/><br/>  Example Input:<pre>timeouts = {<br/>    create = "90m"<br/>    update = "5m"<br/>    read   = "90m"<br/>    delete = "90m"<br/>  }</pre> | <pre>object({<br/>    create = optional(string, "90")<br/>    read   = optional(string, "5")<br/>    update = optional(string, "90")<br/>    delete = optional(string, "90")<br/>  })</pre> | `null` | no |
| <a name="input_virtual_hub"></a> [virtual\_hub](#input\_virtual\_hub) | * `virtual_hub` - (Optional) A `virtual_hub` block as documented below.<br/>  * `virtual_hub_id` - (Required) Specifies the ID of the Virtual Hub where the Firewall resides in.<br/>  * `public_ip_count` - (Optional) Specifies the number of public IPs to assign to the Firewall. Defaults to `1`.<br/><br/>  Example Input:<pre>virtual_hub = {<br/>    virtual_hub_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup//providers/Microsoft.Network/virtualHubs/myVirtualHub"<br/>    public_ip_count = 2<br/>  }</pre> | <pre>object({<br/>    virtual_hub_id  = string<br/>    public_ip_count = optional(number, 1)<br/>  })</pre> | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | * `zones` - (Optional) Specifies a list of Availability Zones in which this Azure Firewall should be located. Changing this forces a new Azure Firewall to be created.<br/> <br/>   -> **Please Note**: Availability Zones are [only supported in several regions at this time](https://docs.microsoft.com/azure/availability-zones/az-overview).<br/><br/>  Example Input:<pre>zones = ["1", "2", "3"]</pre> | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall"></a> [firewall](#output\_firewall) | * `name` - (Required) Specifies the name of the Firewall. Changing this forces a new resource to be created.<br/>  * `resource_group_name` - (Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created.<br/>  * `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.<br/>  * `sku_name` - (Required) SKU name of the Firewall. Possible values are `AZFW_Hub` and `AZFW_VNet`. Changing this forces a new resource to be created.<br/>  * `sku_tier` - (Required) SKU tier of the Firewall. Possible values are `Premium`, `Standard` and `Basic`.<br/>  * `firewall_policy_id` - (Optional) The ID of the Firewall Policy applied to this Firewall.<br/>  * `dns_servers` - (Optional) A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution.<br/>  * `dns_proxy_enabled` - (Optional) Whether DNS proxy is enabled. It will forward DNS requests to the DNS servers when set to `true`. It will be set to `true` if `dns_servers` provided with a not empty list.<br/>  * `private_ip_ranges` - (Optional) A list of SNAT private CIDR IP ranges, or the special string `IANAPrivateRanges`, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918.<br/>  * `threat_intel_mode` - (Optional) The operation mode for threat intelligence-based filtering. Possible values are: `Off`, `Alert` and `Deny`. Defaults to `Alert`.<br/>  * `zones` - (Optional) Specifies a list of Availability Zones in which this Azure Firewall should be located. Changing this forces a new Azure Firewall to be created.<br/>  * `tags` - (Optional) A mapping of tags to assign to the resource.<br/><br/>  An `ip_configuration` block supports the following:<br/>    * `name` - (Required) Specifies the name of the IP Configuration.<br/>    * `subnet_id` - (Optional) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.<br/>    * `public_ip_address_id` - (Optional) The ID of the Public IP Address associated with the firewall.<br/><br/>  A `management_ip_configuration` block supports the following:<br/>    * `name` - (Required) Specifies the name of the IP Configuration.<br/>    * `subnet_id` - (Required) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.<br/>    * `public_ip_address_id` - (Required) The ID of the Public IP Address associated with the firewall.<br/><br/>  A `virtual_hub` block supports the following:<br/>    * `virtual_hub_id` - (Required) Specifies the ID of the Virtual Hub where the Firewall resides in.<br/>    * `public_ip_count` - (Optional) Specifies the number of public IPs to assign to the Firewall. Defaults to `1`.<br/><br/> Example output:<pre>output "name" {<br/>    value = module.module_name.firewall.name<br/>  }</pre> |

## Modules

No modules.


## Additional Information
For more information about Azure Firewall and configurations, refer to the [Azure Firewall documentation](https://learn.microsoft.com/en-us/azure/firewall/). This module is designed to manage an Azure Firewall, including configurations for RBAC, network access, and rule assignments.

## Resources
- [AzureRM Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall)
- [Azure Firewall  Overview](https://learn.microsoft.com/en-us/azure/firewall/overview)

## Notes
- Prioritize rules with high traffic to enhance performance.
- Select the appropriate SKU (Standard or Premium) for your workload.
- Monitor firewall throughput and adjust configurations as needed.
- Deploy Azure Firewall across multiple availability zones for higher resilience.
- Implement least privilege access by configuring minimal, necessary traffic rules.
- Organize rule collections efficiently to reduce evaluation time.
- Activate threat intelligence-based filtering for advanced protection.
- Validate your Terraform configuration to ensure that Azure Firewall is created and configured correctly, including diagnostic settings and role assignments.

## License
This module is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.
<!-- END OF PRE-COMMIT-OPENTOFU DOCS HOOK -->