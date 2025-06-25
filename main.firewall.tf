resource "azurerm_firewall" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id
  dns_servers         = var.dns_servers
  dns_proxy_enabled   = var.dns_proxy_enabled
  private_ip_ranges   = var.private_ip_ranges
  threat_intel_mode   = var.threat_intel_mode
  zones               = var.zones
  tags                = var.tags

  dynamic "ip_configuration" {
    for_each = var.ip_configuration != null ? var.ip_configuration : {}

    content {
      name                 = ip_configuration.value.name
      subnet_id            = ip_configuration.value.subnet_id
      public_ip_address_id = ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "management_ip_configuration" {
    for_each = var.management_ip_configuration != null ? [var.management_ip_configuration] : []

    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub == null ? [] : [var.virtual_hub]

    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = virtual_hub.value.public_ip_count
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "app_rule_collection" {
  for_each = var.application_rule_collection != null ? var.application_rule_collection : {}

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  dynamic "rule" {
    for_each = each.value.rules != null ? each.value.rules : []

    content {
      name             = rule.value.name
      description      = rule.value.description
      source_addresses = rule.value.source_addresses
      source_ip_groups = rule.value.source_ip_groups
      target_fqdns     = rule.value.target_fqdns
      fqdn_tags        = rule.value.fqdn_tags

      dynamic "protocol" {
        for_each = rule.value.protocols != null ? rule.value.protocols : []

        content {
          type = protocol.value.type
          port = protocol.value.port
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_firewall_nat_rule_collection" "nat_rule_collection" {
  for_each = var.nat_rule_collection != null ? var.nat_rule_collection : {}

  name                = each.value.name
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = each.value.priority
  action              = each.value.action

  dynamic "rule" {
    for_each = each.value.rules != null ? each.value.rules : []

    content {
      name                  = rule.value.name
      description           = rule.value.description
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
      source_addresses      = rule.value.source_addresses
      source_ip_groups      = rule.value.source_ip_groups
      translated_address    = rule.value.translated_address
      translated_port       = rule.value.translated_port
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      read   = timeouts.value.read
      delete = timeouts.value.delete
    }
  }
}