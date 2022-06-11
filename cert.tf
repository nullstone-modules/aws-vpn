data "ns_connection" "subdomain" {
  name     = "subdomain"
  type     = "subdomain/aws"
  contract = "subdomain/aws/route53"
}

locals {
  subdomain_name    = trimsuffix(try(data.ns_connection.subdomain.outputs.fqdn, ""), ".")
  subdomain_zone_id = try(data.ns_connection.subdomain.outputs.zone_id, "")
}

resource "aws_acm_certificate" "server" {
  domain_name               = local.subdomain_name
  validation_method         = "DNS"
  subject_alternative_names = []
  tags                      = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "server_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.server.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.subdomain_zone_id
}

resource "aws_acm_certificate_validation" "server_cert" {
  certificate_arn         = aws_acm_certificate.server.arn
  validation_record_fqdns = [for cv in aws_route53_record.server_cert_validation : cv.fqdn]

  timeouts {
    create = "1m"
  }
}
