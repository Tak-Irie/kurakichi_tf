resource "aws_kms_key" "kurakichi" {
  description             = "kurakichi Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "kurakichi" {
  name          = "alias/kurakichi"
  target_key_id = aws_kms_key.kurakichi.key_id
}
