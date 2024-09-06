# aip-aws

Terraform provisioning for AIP.

Manual intervention was required to enable/disable some features due to not being able to find the terraform feature to automate said feature:

* under Systems Manager > Fleet Manager > Managed nodes
  * enable Configure Default Host Management

references:

* [Terraform Cloud Getting Started Guide](https://learn.hashicorp.com/terraform/cloud-gettingstarted/tfc_overview).

* [Configure instance permissions required for Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html)