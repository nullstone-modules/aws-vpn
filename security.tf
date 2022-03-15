resource "aws_security_group" "vpn" {
  name   = local.resource_name
  vpc_id = local.vpc_id
  tags   = merge(local.tags, { Name = local.resource_name })
}

resource "aws_security_group_rule" "this-from-users" {
  description       = "Incoming VPN connections"
  security_group_id = aws_security_group.vpn.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "this-to_world" {
  security_group_id = aws_security_group.vpn.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
