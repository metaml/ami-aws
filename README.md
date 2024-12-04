## ami-aws

### Terraform provisioning for AMI.

Manual intervention was required to enable/disable some features due to not being able to find a terraform way to automate:

* under Systems Manager > Fleet Manager > Managed nodes
  * enable Configure Default Host Management


### AWS ec2 instances are managed in ./etc/nixos:

* edit configuration.nix in above local directory

* "make rebuild" to deply and switch nixos configuration


references:

* [Terraform Cloud Getting Started Guide](https://learn.hashicorp.com/terraform/cloud-gettingstarted/tfc_overview).

* [Configure instance permissions required for Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html)