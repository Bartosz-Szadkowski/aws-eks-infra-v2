resource "aws_security_group" "bastion_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for the Bastion Host"

  tags = {
    Name = "${var.tags["Environment"]}-bastion-sg"
  }
} 

resource "aws_instance" "bastion" {
  ami               = var.bastion_ami
  instance_type     = var.instance_type
  subnet_id         = var.subnet_id  # Subnet should be a public subnet
  key_name          = var.ssh_key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = var.tags
}
