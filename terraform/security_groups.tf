resource "aws_security_group" "vpn_sg" {
  name        = "vpn-sg"
  description = "Allow VPN traffic"
  vpc_id      = aws_vpc.hybrid_vpc.id

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OpenVPN UDP port"
  }

  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "WireGuard UDP port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-sg"
  }
}

resource "aws_network_interface_sg_attachment" "vpn_sg_attachment" {
  security_group_id    = aws_security_group.vpn_sg.id
  network_interface_id = aws_instance.vpn_server.primary_network_interface_id
}
