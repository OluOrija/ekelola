data "aws_route53_zone" "primary" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "caa_amazon" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.root_domain   # or "" to target the zone apex
  type    = "CAA"
  ttl     = 300
  records = [
    "0 issue \"amazon.com\"",
    "0 issue \"amazontrust.com\"",
    "0 issue \"awstrust.com\"",
    "0 issue \"amazonaws.com\"",
  ]
}
