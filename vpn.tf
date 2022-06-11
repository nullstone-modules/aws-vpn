data "ns_connection" "ca" {
  name     = "ca"
  type     = "ca/internal/aws"
  contract = "datastore/aws/ca:internal"
}

locals {
  client_ca_cert_arn = data.ns_connection.ca.outputs.root_acm_cert_arn
}

resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = local.block_name
  client_cidr_block      = var.user_range
  split_tunnel           = true
  server_certificate_arn = aws_acm_certificate_validation.server_cert.certificate_arn
  tags                   = local.tags
  vpc_id                 = local.vpc_id
  security_group_ids     = [aws_security_group.vpn.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = local.client_ca_cert_arn
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_ec2_client_vpn_network_association" "vpn_subnets" {
  for_each = toset(local.public_subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  target_network_cidr    = local.vpc_cidr
  authorize_all_groups   = true
}
