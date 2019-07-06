# Wireguard Peer Updater


This module is to be used as an addon to the `terraform-aws-wireguard` module.
It provides functionality to automatically add / remove / update wireguard peer configuration.


## Inputs

| Name | Required | Description |
| ---- | -------- | ----------- |
| name | True     | Name given to the Wireguard stack. This should match the `name` variable in the *terraform-aws-wireguard* module. |

## Usage

```hcl
module "wireguard_peer_refresh" {
  source = "../terraform-aws-wireguard-peer-update"
  name   = "test"
}
```