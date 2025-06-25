output "firewall" {
  value       = azurerm_firewall.this
  description = <<DESCRIPTION
  * `name` - (Required) Specifies the name of the Firewall. Changing this forces a new resource to be created.
  * `resource_group_name` - (Required) The name of the resource group in which to create the resource. Changing this forces a new resource to be created.
  * `location` - (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.
  * `sku_name` - (Required) SKU name of the Firewall. Possible values are `AZFW_Hub` and `AZFW_VNet`. Changing this forces a new resource to be created.
  * `sku_tier` - (Required) SKU tier of the Firewall. Possible values are `Premium`, `Standard` and `Basic`.
  * `firewall_policy_id` - (Optional) The ID of the Firewall Policy applied to this Firewall.
  * `dns_servers` - (Optional) A list of DNS servers that the Azure Firewall will direct DNS traffic to the for name resolution.
  * `dns_proxy_enabled` - (Optional) Whether DNS proxy is enabled. It will forward DNS requests to the DNS servers when set to `true`. It will be set to `true` if `dns_servers` provided with a not empty list.
  * `private_ip_ranges` - (Optional) A list of SNAT private CIDR IP ranges, or the special string `IANAPrivateRanges`, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918.
  * `threat_intel_mode` - (Optional) The operation mode for threat intelligence-based filtering. Possible values are: `Off`, `Alert` and `Deny`. Defaults to `Alert`.
  * `zones` - (Optional) Specifies a list of Availability Zones in which this Azure Firewall should be located. Changing this forces a new Azure Firewall to be created.
  * `tags` - (Optional) A mapping of tags to assign to the resource.

  An `ip_configuration` block supports the following:
    * `name` - (Required) Specifies the name of the IP Configuration.
    * `subnet_id` - (Optional) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.
    * `public_ip_address_id` - (Optional) The ID of the Public IP Address associated with the firewall.

  A `management_ip_configuration` block supports the following:
    * `name` - (Required) Specifies the name of the IP Configuration.
    * `subnet_id` - (Required) Reference to the subnet associated with the IP Configuration. Changing this forces a new resource to be created.
    * `public_ip_address_id` - (Required) The ID of the Public IP Address associated with the firewall.

  A `virtual_hub` block supports the following:
    * `virtual_hub_id` - (Required) Specifies the ID of the Virtual Hub where the Firewall resides in.
    * `public_ip_count` - (Optional) Specifies the number of public IPs to assign to the Firewall. Defaults to `1`.

 Example output:
 ```
  output "name" {
    value = module.module_name.firewall.name
  }
 ```
 DESCRIPTION
}
