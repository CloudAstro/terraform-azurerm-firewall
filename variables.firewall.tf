# Variables for azurerm_firewall
variable "name" {
  type        = string
  description = <<DESCRIPTION
  * `name` - (Required) Specifies the name of the Firewall. Changing this forces a new resource to be created. 
 
  Example Input:
  ```
  name = "fw-gwc-dev"
  ```
  DESCRIPTION
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
  * `resource_group_name` - (Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created. 
  
  Example Input:
  ```
  resource_group_name = "rg-azure-firewall-dev"
  ```
  DESCRIPTION
}

variable "location" {
  type        = string
  description = <<DESCRIPTION
  * `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
 
  Example Input:
  ```
  location = "germanywestcentral"
  ```
  DESCRIPTION
}

variable "sku_name" {
  type        = string
  description = <<DESCRIPTION
  * `sku_name` - (Required) SKU name of the Firewall. Possible values are `AZFW_Hub` and `AZFW_VNet`. Changing this forces a new resource to be created.
 
  Example Input:
  ```
  sku_name = "AZFW_Hub"
  ```
  DESCRIPTION
}

variable "sku_tier" {
  type        = string
  description = <<DESCRIPTION
  * `sku_tier` - (Required) SKU tier of the Firewall. Possible values are `Premium`, `Standard` and `Basic`.
 
  Example Input:
  ```
  sku_tier = "Standard"
  ```
  DESCRIPTION
}

variable "firewall_policy_id" {
  type        = string
  default     = null
  description = <<DESCRIPTION
  * `firewall_policy_id` - (Optional) The ID of the Firewall Policy applied to this Firewall.
 
  Example Input:
  ```
  firewall_policy_id = "/subscriptions/12345678-9abc-def0-1234-56789abcdef0/resourceGroups/rg-firewall/providers/Microsoft.Network/firewallPolicies/fw-policy-default"
  ```
  DESCRIPTION
}

variable "dns_servers" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
  * `dns_servers` - (Optional) A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution.
  
  Example Input:
  ```
  dns_servers = ["8.8.8.8", "8.8.4.4"]
  ```
  DESCRIPTION
}

variable "dns_proxy_enabled" {
  type        = bool
  default     = null
  description = <<DESCRIPTION
  * `dns_proxy_enabled` - (Optional) Whether DNS proxy is enabled. It will forward DNS requests to the DNS servers when set to `true`. It will be set to `true` if `dns_servers` provided with a not empty list.  
  
  Example Input:
  ```
  dns_proxy_enabled = true
  ```
  DESCRIPTION
}

variable "private_ip_ranges" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
  * `private_ip_ranges` - (Optional) A list of SNAT private CIDR IP ranges, or the special string IANAPrivateRanges, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918.
 
 Example Input:
  ```
  private_ip_ranges = ["10.20.0.0/24", "192.168.0.0/16"]
  ```
  DESCRIPTION
}

variable "threat_intel_mode" {
  type        = string
  default     = "Alert"
  description = <<DESCRIPTION
  * `threat_intel_mode` - (Optional) The operation mode for threat intelligence-based filtering. Possible values are: `Off`, `Alert` and `Deny`. Defaults to `Alert`.
 
  Example Input:
  ```
  threat_intel_mode = "Alert"
  ```
  DESCRIPTION
}

variable "zones" {
  type        = list(string)
  default     = null
  description = <<DESCRIPTION
  * `zones` - (Optional) Specifies a list of Availability Zones in which this Azure Firewall should be located. Changing this forces a new Azure Firewall to be created.
   
   -> **Please Note**: Availability Zones are [only supported in several regions at this time](https://docs.microsoft.com/azure/availability-zones/az-overview).
  
  Example Input:
  ```
  zones = ["1", "2", "3"]
  ```
  DESCRIPTION
}

variable "ip_configuration" {
  type = map(object({
    name                 = string
    subnet_id            = optional(string)
    public_ip_address_id = optional(string)
  }))
  default     = {}
  description = <<DESCRIPTION
 * `ip_configuration` - (Optional) An `ip_configuration` block as documented below.
  * `name` - (Required) Specifies the name of the IP Configuration.
  * `subnet_id` - (Optional) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.
  
   -> **NOTE** The Subnet used for the Firewall must have the name `AzureFirewallSubnet` and the subnet mask must be at least a `/26`.
   
   -> **NOTE** At least one and only one `ip_configuration` block may contain a `subnet_id`.
  * `public_ip_address_id` - (Optional) The ID of the Public IP Address associated with the firewall.
  
   -> **NOTE** A public ip address is required unless a `management_ip_configuration` block is specified.
   
   -> **NOTE** When multiple `ip_configuration` blocks with `public_ip_address_id` are configured, `terraform apply` will raise an error when one or some of these `ip_configuration` blocks are removed. because the `public_ip_address_id` is still used by the `firewall` resource until the `firewall` resource is updated. and the destruction of `azurerm_public_ip` happens before the update of firewall by default. to destroy of `azurerm_public_ip` will cause the error. The workaround is to set `create_before_destroy=true` to the `azurerm_public_ip` resource `lifecycle` block. See more detail: [destroying.md#create-before-destroy](https://github.com/hashicorp/terraform/blob/main/docs/destroying.md#create-before-destroy)
   
   -> **NOTE** The Public IP must have a `Static` allocation and `Standard` SKU.
  
  Example Input:
  ```
  ip_configuration = {
    "primary" = {
      name                 = "ipconfig1"
      subnet_id            = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/mySubnet"
      public_ip_address_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/publicIPAddresses/myPublicIPAdresses"
    }
  }
  ```
  DESCRIPTION
}

variable "management_ip_configuration" {
  type = object({
    name                 = string
    subnet_id            = string
    public_ip_address_id = string
  })
  default     = null
  description = <<DESCRIPTION
 * `management_ip_configuration` - (Optional) A `management_ip_configuration` block as documented below, which allows force-tunnelling of traffic to be performed by the firewall. Adding or removing this block or changing the `subnet_id` in an existing block forces a new resource to be created. Changing this forces a new resource to be created.
  * `name` - (Required) Specifies the name of the IP Configuration.
  * `subnet_id` - (Required) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.
   
   -> **NOTE** The Management Subnet used for the Firewall must have the name `AzureFirewallManagementSubnet` and the subnet mask must be at least a `/26`.
  * `public_ip_address_id` - (Required) The ID of the Public IP Address associated with the firewall.
   
   -> **NOTE** The Public IP must have a `Static` allocation and `Standard` SKU.  
  
  Example Input:
  ```
  management_ip_configuration = {
    name                 = "managementIpConfig"
    subnet_id            = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/mySubnet"
    public_ip_address_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Network/publicIPAddresses/myPublicIPAdresses"
  }
  ```
  DESCRIPTION
}

variable "virtual_hub" {
  type = object({
    virtual_hub_id  = string
    public_ip_count = optional(number, 1)
  })
  default     = null
  description = <<DESCRIPTION
 * `virtual_hub` - (Optional) A `virtual_hub` block as documented below.
  * `virtual_hub_id` - (Required) Specifies the ID of the Virtual Hub where the Firewall resides in.
  * `public_ip_count` - (Optional) Specifies the number of public IPs to assign to the Firewall. Defaults to `1`.
  
  Example Input:
  ```
  virtual_hub = {
    virtual_hub_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup//providers/Microsoft.Network/virtualHubs/myVirtualHub"
    public_ip_count = 2
  }
  ```
  DESCRIPTION
}

variable "application_rule_collection" {
  type = map(object({
    name                = string
    resource_group_name = string
    priority            = number
    action              = string
    rules = list(object({
      name             = string
      description      = optional(string)
      source_addresses = optional(list(string))
      source_ip_groups = optional(list(string))
      protocols = optional(list(object({
        type = string
        port = number
      })))
      target_fqdns = optional(list(string))
      fqdn_tags    = optional(list(string))
    }))
  }))
  default     = null
  description = <<DESCRIPTION
 * `firewall_application_rule_collection` - Manages an Application Rule Collection within an Azure Firewall.
  * `name` - (Required) Specifies the name of the Application Rule Collection which must be unique within the Firewall. Changing this forces a new resource to be created.
  * `azure_firewall_name` - (Required) Specifies the name of the Firewall in which the Application Rule Collection should be created. Changing this forces a new resource to be created.
  * `resource_group_name` - (Required) Specifies the name of the Resource Group in which the Firewall exists. Changing this forces a new resource to be created.
  * `priority` - (Required) Specifies the priority of the rule collection. Possible values are between `100` - `65000`.
  * `action` - (Required) Specifies the action the rule will apply to matching traffic. Possible values are `Allow` and `Deny`.
  * `rule` - (Required) One or more `rule` blocks as defined below.
   * `name` - (Required) Specifies the name of the rule.
   * `description` - (Optional) Specifies a description for the rule.
   * `source_addresses` - (Optional) A list of source IP addresses and/or IP ranges.
   * `source_ip_groups` - (Optional) A list of source IP Group IDs for the rule.
     
     -> **NOTE** At least one of `source_addresses` and `source_ip_groups` must be specified for a rule.
   * `fqdn_tags` - (Optional) A list of FQDN tags. Possible values are `AppServiceEnvironment`, `AzureBackup`, `AzureKubernetesService`, `HDInsight`, `MicrosoftActiveProtectionService`, `WindowsDiagnostics`, `WindowsUpdate` and `WindowsVirtualDesktop`.
   * `target_fqdns` - (Optional) A list of FQDNs.
   * `protocol` - (Optional) One or more `protocol` blocks as defined below.
    * `port` - (Required) Specify a port for the connection.
    * `type` - (Required) Specifies the type of connection. Possible values are `Http`, `Https` and `Mssql`.  
  
  Example Input:
  ```
  application_rule_collection = {
   app-rules = {
    name                = "my-application-rule-collection"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.firewall_rg.name
    priority            = 100
    action              = "Allow"
    rules = [
      {
        name             = "AllowWebTraffic"
        description      = "Allow web traffic to example.com"
        source_addresses = ["*"]
        protocols = [
          { type = "Http",  port = 80 },
          { type = "Https", port = 443 },
        ]
        target_fqdns = ["www.example.com"]
        fqdn_tags    = null
      },
      {
        name             = "AllowSQLTraffic"
        description      = "Allow SQL traffic to database.example.com"
        source_ip_groups = ["/subscriptions/xxxx/resourceGroups/rg-example/providers/Microsoft.Network/ipGroups/app-ips"]
        protocols = [
          { type = "Mssql", port = 1433 }
        ]
        target_fqdns = ["database.example.com"]
        fqdn_tags    = null
      }
    ]
   }
  }
  ```
  DESCRIPTION
}

variable "nat_rule_collection" {
  type = map(object({
    name                = string
    resource_group_name = string
    priority            = number
    action              = string
    rules = list(object({
      name                  = string
      description           = optional(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
      translated_address    = string
      translated_port       = number
    }))
  }))
  default     = null
  description = <<DESCRIPTION
 * `firewall_nat_rule_collection` - Manages a NAT Rule Collection within an Azure Firewall.
  * `name` - (Required) Specifies the name of the NAT Rule Collection which must be unique within the Firewall. Changing this forces a new resource to be created.
  * `azure_firewall_name` - (Required) Specifies the name of the Firewall in which the NAT Rule Collection should be created. Changing this forces a new resource to be created.
  * `resource_group_name` - (Required) Specifies the name of the Resource Group in which the Firewall exists. Changing this forces a new resource to be created.
  * `priority` - (Required) Specifies the priority of the rule collection. Possible values are between `100` - `65000`.
  * `action` - (Required) Specifies the action the rule will apply to matching traffic. Possible values are `Dnat` and `Snat`.
  * `rule` - (Required) One or more `rule` blocks as defined below.
    * `name` - (Required) Specifies the name of the rule.
    * `description` - (Optional) Specifies a description for the rule.
    * `destination_addresses` - (Required) A list of destination IP addresses and/or IP ranges.
    * `destination_ports` - (Required) A list of destination ports.
    * `protocols` - (Required) A list of protocols. Possible values are `Any`, `ICMP`, `TCP` and `UDP`. If `action` is `Dnat`, protocols can only be `TCP` and `UDP`.
    * `source_addresses` - (Optional) A list of source IP addresses and/or IP ranges.
    * `source_ip_groups` - (Optional) A list of source IP Group IDs for the rule.
     
     -> **NOTE** At least one of `source_addresses` and `source_ip_groups` must be specified for a rule.
    * `translated_address` - (Required) The address of the service behind the Firewall.
    * `translated_port` - (Required) The port of the service behind the Firewall.  
  
  Example Input:
  ```
  nat_rule_collection = {
   nat-rules = {
    name                = "my-nat-rule-collection"
    azure_firewall_name = azurerm_firewall.firewall.name
    resource_group_name = azurerm_resource_group.firewall_rg.name
    priority            = 200
    action              = "Dnat"
    rules = [
      {
        name                  = "DNAT-SSH"
        description           = "DNAT rule for SSH access"
        source_addresses      = ["*"]
        destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]
        destination_ports     = ["22"]
        protocols             = ["TCP"]
        translated_address    = "10.0.0.4"
        translated_port       = 22
      },
      {
        name                  = "DNAT-HTTP"
        description           = "DNAT rule for HTTP traffic"
        source_addresses      = ["*"]
        destination_addresses = [azurerm_public_ip.firewall_pip.ip_address]
        destination_ports     = ["80"]
        protocols             = ["TCP"]
        translated_address    = "10.0.0.5"
        translated_port       = 8080
      }
    ]
   }
  }
  ```
  DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  * `tags` - (Optional) A mapping of tags to assign to the resource.

  Example Input:
  ```
  tags = {
    env     = test
    region  = gwc
  }
  ```
  DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string, "90")
    read   = optional(string, "5")
    update = optional(string, "90")
    delete = optional(string, "90")
  })
  default     = null
  description = <<DESCRIPTION
  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
    * `create` - (Defaults to 90 minutes) Used when creating the Firewall.
    * `read` - (Defaults to 5 minutes) Used when retrieving the Firewall.
    * `update` - (Defaults to 90 minutes) Used when updating the Firewall.
    * `delete` - (Defaults to 90 minutes) Used when deleting the Firewall.

  Example Input: 
  ```
  timeouts = {
    create = "90m"
    update = "5m"
    read   = "90m"
    delete = "90m"
  }
  ```
  DESCRIPTION
}