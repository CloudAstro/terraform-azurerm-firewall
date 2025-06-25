variable "diagnostic_settings" {
  type = map(object({
    name                           = optional(string)
    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string, "Dedicated")
    storage_account_id             = optional(string)
    eventhub_authorization_rule_id = optional(string)
    eventhub_name                  = optional(string)
    partner_solution_id            = optional(string)
    enabled_log = optional(list(object({
      category       = optional(string)
      category_group = optional(string)
    })))
    metric = optional(object({
      category = optional(string, "AllMetrics")
      enabled  = optional(bool)
    }))
    timeouts = object({
      create = optional(string, "30")
      read   = optional(string, "5")
      update = optional(string, "30")
      delete = optional(string, "1")
    })
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
  The following arguments are supported:
  * `name` - (Required) Specifies the name of the Diagnostic Setting. Changing this forces a new resource to be created.

   -> **NOTE:** If the name is set to 'service' it will not be possible to fully delete the diagnostic setting. This is due to legacy API support.
  * `target_resource_id` - (Required) The ID of an existing Resource on which to configure Diagnostic Settings. Changing this forces a new resource to be created.
  * `eventhub_name` - (Optional) Specifies the name of the Event Hub where Diagnostics Data should be sent.

   -> **NOTE:** If this isn't specified then the default Event Hub will be used.
  * `eventhub_authorization_rule_id` - (Optional) Specifies the ID of an Event Hub Namespace Authorization Rule used to send Diagnostics Data.

   -> **NOTE:** This can be sourced from [the `azurerm_eventhub_namespace_authorization_rule` resource](eventhub_namespace_authorization_rule.html) and is different from [a `azurerm_eventhub_authorization_rule` resource](eventhub_authorization_rule.html).

   -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `enabled_log` - (Optional) One or more `enabled_log` blocks as defined below.

   -> **NOTE:** At least one `enabled_log` or `metric` block must be specified. At least one type of Log or Metric must be enabled.
   * `category` - (Optional) The name of a Diagnostic Log Category for this Resource.

    -> **NOTE:** The Log Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor_diagnostic_categories.html) or [list of service specific schemas](https://docs.microsoft.com/azure/azure-monitor/platform/resource-logs-schema#service-specific-schemas) to identify which categories are available for a given Resource.
   * `category_group` - (Optional) The name of a Diagnostic Log Category Group for this Resource.

    -> **NOTE:** Not all resources have category groups available.

    -> **NOTE:** Exactly one of `category` or `category_group` must be specified.
  * `log_analytics_workspace_id` - (Optional) Specifies the ID of a Log Analytics Workspace where Diagnostics Data should be sent.

  -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `enabled_metric` - (Optional) One or more `enabled_metric` blocks as defined below.

   -> **Note:** At least one `enabled_log` or `enabled_metric` block must be specified.
   * `category` - (Required) The name of a Diagnostic Metric Category for this Resource.

    -> **Note:** The Metric Categories available vary depending on the Resource being used. You may wish to use [the `azurerm_monitor_diagnostic_categories` Data Source](../d/monitor_diagnostic_categories.html) to identify which categories are available for a given Resource.
  * `storage_account_id` - (Optional) The ID of the Storage Account where logs should be sent.

   -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `log_analytics_destination_type` - (Optional) Possible values are `AzureDiagnostics` and `Dedicated`. When set to `Dedicated`, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy `AzureDiagnostics` table.

   -> **NOTE:** This setting will only have an effect if a `log_analytics_workspace_id` is provided. For some target resource type (e.g., Key Vault), this field is unconfigurable. Please see [resource types](https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics#resource-types) for services that use each method. Please [see the documentation](https://docs.microsoft.com/azure/azure-monitor/platform/diagnostic-logs-stream-log-store#azure-diagnostics-vs-resource-specific) for details on the differences between destination types.
  * `partner_solution_id` - (Optional) The ID of the market partner solution where Diagnostics Data should be sent. For potential partner integrations, [click to learn more about partner integration](https://learn.microsoft.com/en-us/azure/partner-solutions/overview).

   -> **NOTE:** At least one of `eventhub_authorization_rule_id`, `log_analytics_workspace_id`, `partner_solution_id` and `storage_account_id` must be specified.
  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
    * `create` - (Defaults to 30 minutes) Used when creating the Diagnostics Setting.
    * `read` - (Defaults to 5 minutes) Used when retrieving the Diagnostics Setting.
    * `update` - (Defaults to 30 minutes) Used when updating the Diagnostics Setting.
    * `delete` - (Defaults to 1 hour) Used when deleting the Diagnostics Setting.

  Example Input:
  ```
  diagnostic_settings = {
    diagnostic = {
      name                           = "diagnostic"
      log_analytics_workspace_id     = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.OperationalInsights/workspaces/myLogAnalyticsWorkspace"
      storage_account_id             = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Storage/storageAccounts/myStorageAccount"
      log_analytics_destination_type = "Dedicated"
      eventhub_authorization_rule_id = null
      eventhub_name                  = null
      partner_solution_id            = null
      enabled_log = [
        {
          category       = null
          category_group = "allLogs"
        }
      ]
      enabled_metric = {
        category = "AllMetrics"
      }
      timeouts = {
       create  = "30m"
       read    = "5m"
       update  = "30m"
       delete  = "1h"
      }
    }
  }
  ```
  DESCRIPTION
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
  * `managment_lock` -  Manages a Management Lock which is scoped to a Subscription, Resource Group or Resource.
    * `name` - (Required) Specifies the name of the Management Lock. Changing this forces a new resource to be created.
    * `scope` - (Required) Specifies the scope at which the Management Lock should be created. Changing this forces a new resource to be created.
    * `lock_level` - (Required) Specifies the Level to be used for this Lock. Possible values are `CanNotDelete` and `ReadOnly`. Changing this forces a new resource to be created.

     ~> **Note:** `CanNotDelete` means authorized users are able to read and modify the resources, but not delete. `ReadOnly` means authorized users can only read from a resource, but they can't modify or delete it.
    * `notes` - (Optional) Specifies some notes about the lock. Maximum of 512 characters. Changing this forces a new resource to be created.

 Example Input:
 ```
 lock = {
   kind  = "CanNotDelete"
   name  = "prevent-deletion-lock"
   scope = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/my-vm"
   notes = "This lock prevents accidental deletion of the VM."
  }
 ```
 DESCRIPTION
  validation {
    condition     = var.lock == null || contains(["CanNotDelete", "ReadOnly"], try(var.lock.kind, ""))
    error_message = "If lock is set, 'kind' must be either 'CanNotDelete' or 'ReadOnly'."
  }
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string)
    role_definition_id                     = optional(string)
    role_definition_name                   = optional(string)
    principal_id                           = string
    principal_type                         = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    description                            = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
    timeouts = object({
      create = optional(string, "30")
      read   = optional(string, "5")
      delete = optional(string, "30")
    })
  }))
  default     = {}
  description = <<DESCRIPTION
 * `role_assignments` - Assigns a given Principal (User or Group) to a given Role.
  * `name` - (Optional) A unique UUID/GUID for this Role Assignment - one will be generated if not specified. Changing this forces a new resource to be created.
  * `scope` - (Required) The scope at which the Role Assignment applies to, such as `/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333`, `/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup`, or `/subscriptions/0b1f6471-1bf0-4dda-aec3-111122223333/resourceGroups/myGroup/providers/Microsoft.Compute/virtualMachines/myVM`, or `/providers/Microsoft.Management/managementGroups/myMG`. Changing this forces a new resource to be created.
  * `role_definition_id` - (Optional) The Scoped-ID of the Role Definition. Changing this forces a new resource to be created. Conflicts with `role_definition_name`.
  * `role_definition_name` - (Optional) The name of a built-in Role. Changing this forces a new resource to be created. Conflicts with `role_definition_id`.
  * `principal_id` - (Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to. Changing this forces a new resource to be created.

   * ~> **NOTE:** The Principal ID is also known as the Object ID (ie not the "Application ID" for applications).
  * `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

   * ~> **NOTE:** If one of `condition` or `condition_version` is set both fields must be present.
  * `condition` - (Optional) The condition that limits the resources that the role can be assigned to. Changing this forces a new resource to be created.
  * `condition_version` - (Optional) The version of the condition. Possible values are `1.0` or `2.0`. Changing this forces a new resource to be created.
  * `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.

   * ~> **NOTE:** this field is only used in cross tenant scenario.
  * `description` - (Optional) The description for this Role Assignment. Changing this forces a new resource to be created.
  * `skip_service_principal_aad_check` - (Optional) If the `principal_id` is a newly provisioned `Service Principal` set this value to `true` to skip the `Azure Active Directory` check which may fail due to replication lag. This argument is only valid if the `principal_id` is a `Service Principal` identity. Defaults to `false`.

   * ~> **NOTE:** If it is not a `Service Principal` identity it will cause the role assignment to fail.
  * `timeouts` - The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/language/resources/syntax#operation-timeouts) for certain actions:
   * `create` - (Defaults to 30 minutes) Used when creating the Role Assignment.
   * `read` - (Defaults to 5 minutes) Used when retrieving the Role Assignment.
   * `delete` - (Defaults to 30 minutes) Used when deleting the Role Assignment.

  Example Input:
  ```
  role_assignments = {
    assignment1 = {
      name                                   = "AppRoleContributor"
      scope                                  = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/myResourceGroup"
      role_definition_name                   = "Contributor"
      principal_id                           = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
      principal_type                         = "User"
      condition                              = "resource.type == 'Microsoft.Storage/storageAccounts'"
      condition_version                      = "2.0"
      delegated_managed_identity_resource_id = null
      description                            = "Contributor role assignment for the application team"
      skip_service_principal_aad_check       = false
      timeouts = {
       create  = "30m"
       read    = "5m"
       delete  = "30m"
      }
    }
  }
  ```
  DESCRIPTION
}
