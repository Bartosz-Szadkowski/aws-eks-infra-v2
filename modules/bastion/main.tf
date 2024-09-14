resource "aws_security_group" "bastion_sg" {
  vpc_id      = var.vpc_id
  description = "Security group for the Bastion Host"

  tags = {
    Name = "${var.tags["Environment"]}-bastion-sg"
  }
} 

# Egress rule: Allow all outbound traffic 
resource "aws_vpc_security_group_egress_rule" "bastion_egress" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4       =  "0.0.0.0/0"
  ip_protocol          = "-1"
  description       = "Allow all outbound traffic from bastion"
}

# Fetch the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]  # Amazon's official account ID for Amazon Linux AMIs
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"  # SSM Permissions
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# Bastion Host EC2 instance
resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id  # Use the fetched AMI ID
  instance_type = var.instance_type
  subnet_id     = var.subnet_id  # Subnet should be a public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  # Attach the IAM role for SSM
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  # No key pair needed
  key_name = null  # This disables SSH key-pair access

  tags = {
    Name = "${var.tags["Environment"]}-bastion-instance"
  }
}
