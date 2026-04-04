
resource "aws_vpc_peering_connection" "default" {
    count = var.is_peering_required ? 1 : 0
  vpc_id        = aws_vpc.main.id      # Requester VPC
  peer_vpc_id   = data.aws_vpc.default.id      # Accepter VPC
  auto_accept   = true

    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    requester {
        allow_remote_vpc_dns_resolution = true
    }
  tags = merge(
    local.commom_tags,
     {
        Name = "${var.project}-${var.enviornment}-default"
    }
  )
}