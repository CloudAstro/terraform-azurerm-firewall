
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
