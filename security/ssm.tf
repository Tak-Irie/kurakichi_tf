resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  value       = "bowlby"
  type        = "String"
  description = "くらきちPostgreSQLのユーザーネーム"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/db/password"
  value       = "tempolarydummyfortf"
  type        = "SecureString"
  description = "くらきちPSQLのテラフォーム用ダミーパスワード。AWS-CLIで上書きして下さい"
  lifecycle {
    ignore_changes = [value]
  }
}
