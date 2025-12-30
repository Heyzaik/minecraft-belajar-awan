resource "aws_instance" "minecraft_ec2" {
  ami                    = "ami-0474eefc99186cb7d" # replace with Amazon Linux 2023 AMI in ap-southeast-5
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = "minecraft-keypair"

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = { Name = var.instance_name }
}