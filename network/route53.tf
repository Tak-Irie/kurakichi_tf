resource "aws_route53_zone" "kurakichi" {
  name = "kurakichi.org"
}

resource "aws_route53_record" "kurakichi_top_level_domain" {
  zone_id = aws_route53_zone.kurakichi.zone_id
  name    = aws_route53_zone.kurakichi.name
  type    = "A"

  alias {
    name                   = aws_lb.kurakichi.dns_name
    zone_id                = aws_lb.kurakichi.zone_id
    evaluate_target_health = true
  }
}
