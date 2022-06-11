data "ns_connection" "network" {
  name     = "network"
  type     = "network/aws"
  contract = "network/aws/vpc"
}

locals {
  vpc_id            = data.ns_connection.network.outputs.vpc_id
  vpc_cidr          = data.ns_connection.network.outputs.vpc_cidr
  public_subnet_ids = data.ns_connection.network.outputs.public_subnet_ids
}
