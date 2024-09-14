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
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
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

  owners = ["137112412989"] # Amazon's official account ID for Amazon Linux AMIs
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # SSM Permissions
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

# Bastion Host EC2 instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id # Use the fetched AMI ID
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id # Subnet should be a public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  # Attach the IAM role for SSM
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  # No key pair needed
  key_name = null # This disables SSH key-pair access

  user_data_replace_on_change = true
  user_data                   = <<-EOF
    #!/bin/bash

# Update the system
yum -y update

# Install zsh
yum -y install zsh

# Install util-linux-user to use the 'chsh' command
yum -y install util-linux-user

# Install git and wget, needed for Oh My Zsh installation
yum -y install git wget

# Function to install Oh My Zsh for a given user
install_oh_my_zsh() {
    local user=$1
    local user_home=$2

    # Clone Oh My Zsh repository
    sudo -u $user git clone https://github.com/ohmyzsh/ohmyzsh.git $user_home/.oh-my-zsh

    # Copy the zshrc template provided by Oh My Zsh
    sudo -u $user cp $user_home/.oh-my-zsh/templates/zshrc.zsh-template $user_home/.zshrc

    # Set the ownership of the .zshrc file to the user
    chown $user:$user $user_home/.zshrc
}

# Loop through each user and update their shell and install Oh My Zsh
for user in $(awk -F: '{ if ($7 != "/sbin/nologin" && $7 != "/bin/false" && $1 != "root") print $1 }' /etc/passwd); do
    user_home=$(eval echo ~$user)

    # Change the shell to zsh for each user
    chsh -s "$(which zsh)" $user

    # Check if the user home directory exists
    if [ -d "$user_home" ]; then
        # Install Oh My Zsh for this user
        install_oh_my_zsh $user $user_home
    fi
done

# Optionally, also change the shell for the root user and install Oh My Zsh
chsh -s "$(which zsh)" root
root_home=$(eval echo ~root)
install_oh_my_zsh root $root_home

# Print a message indicating completion
echo "Shell for all users has been updated to zsh, and Oh My Zsh installed."

# Install kubectl
    curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.14/2022-09-21/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin

    # Install ArgoCD CLI
    curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    chmod +x ./argocd
    sudo mv ./argocd /usr/local/bin

    # Ensure /usr/local/bin is in the PATH (although typically it is by default)
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    source ~/.bashrc

       EOF

  tags = {
    Name = "${var.tags["Environment"]}-bastion-instance"
  }
}
