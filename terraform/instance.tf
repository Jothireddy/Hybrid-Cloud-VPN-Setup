resource "aws_instance" "vpn_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name

  tags = {
    Name = "hybrid-vpn-server"
  }
}
