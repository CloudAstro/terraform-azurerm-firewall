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
