
data "aws_region" "current" {}

data "aws_iam_policy_document" "ssm_wg_peer_updater_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}


data "aws_iam_policy_document" "ssm_wg_peer_updater" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = [
      "arn:aws:ssm:*:*:document/${aws_ssm_document.update_wg_peers.name}"
    ]
  }
}
