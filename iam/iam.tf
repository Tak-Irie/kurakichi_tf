variable "name" {}
variable "policy" {}
variable "identifier" {}

resource "aws_iam_role" "kurakichi" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.identifier]
    }
  }
}

resource "aws_iam_policy" "kurakichi" {
  name   = var.name
  policy = var.policy
}

resource "aws_iam_role_policy_attachment" "kurakichi" {
  role       = aws_iam_role.kurakichi.name
  policy_arn = aws_iam_policy.kurakichi.arn
}

