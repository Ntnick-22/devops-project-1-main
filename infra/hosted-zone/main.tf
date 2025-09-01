variable "domain_name" {}
variable "aws_lb_dns_name" {}
variable "aws_lb_zone_id" {}

data "aws_route53_zone" "nt_nick_link_zone" {
  name         = "nt-nick.link."
  private_zone = false
}

resource "aws_route53_record" "lb_record" {
  zone_id = data.aws_route53_zone.nt_nick_link_zone.zone_id
  name    = var.domain_name  # This should be "app.nt-nick.link" from your variables
  type    = "A"
  
  alias {
    name                   = var.aws_lb_dns_name
    zone_id                = var.aws_lb_zone_id
    evaluate_target_health = true
  }
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.nt_nick_link_zone.zone_id
}