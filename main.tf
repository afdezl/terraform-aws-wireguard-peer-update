
resource "aws_cloudwatch_event_rule" "catch_peers_update" {
  name        = "capture-wireguard-peers-update"
  description = "Captures updates to the Wireguard peers parameter"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ssm"
  ],
  "detail-type": [
    "Parameter Store Change"
  ],
  "detail": {
    "name": [
      "/wireguard/peers"
    ],
    "operation": [
      "Update"
    ]
  }
}
PATTERN
}


resource "aws_iam_role" "ssm_wg_peer_updater" {
  name = "SSMWireguardUpdater"
  assume_role_policy = data.aws_iam_policy_document.ssm_wg_peer_updater_trust.json
}

resource "aws_iam_policy" "ssm_wg_peer_updater" {
  name = "SSMWireguardUpdater"
  policy = data.aws_iam_policy_document.ssm_wg_peer_updater.json
}


resource "aws_iam_role_policy_attachment" "ssm_wg_peer_updater" {
  policy_arn = aws_iam_policy.ssm_wg_peer_updater.arn
  role = aws_iam_role.ssm_wg_peer_updater.name
}


resource "aws_cloudwatch_event_target" "ssm" {
  rule = aws_cloudwatch_event_rule.catch_peers_update.name
  arn = aws_ssm_document.update_wg_peers.arn
  target_id = "UpdateWireguardPeers"
  role_arn = aws_iam_role.ssm_wg_peer_updater.arn

  run_command_targets {
    key = "tag:Name"
    values = ["${var.name}-wireguard"]
  }
}


resource "aws_ssm_document" "update_wg_peers" {
  name = "wireguardUpdatePeers"
  document_type = "Command"
  document_format = "YAML"
  content = <<DOC
---

schemaVersion: '2.2'
description: Dynamically adds peer configuration to WireGuard
parameters:
  region:
    type: String
    default: eu-west-1
mainSteps:
- action: aws:runShellScript
  name: reconfigureWireguard
  inputs:
    runCommand:
    - "sudo python3 /opt/wireguard/wg_config_creator.py {{ region }} > /tmp/wg0-updated.conf"
    - "sudo wg-quick strip /tmp/wg0-updated.conf > /tmp/wg0-stripped.conf"
    - "sudo wg setconf wg0 /tmp/wg0-stripped.conf"
    - "sudo wg-quick save wg0"
    - "sudo systemctl restart  wg-quick@wg0.service"
    - "sudo rm -rf /tmp/wg0-updated.conf /tmp/wg0-stripped.conf"

DOC
}

