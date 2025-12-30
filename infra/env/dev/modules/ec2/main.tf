resource "aws_instance" "minecraft_ec2" {
  ami                    = "ami-0474eefc99186cb7d"
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = "minecraft-keypair"

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update and install Java
              sudo yum update -y
              sudo amazon-linux-extras install java-openjdk17 -y

              # Create server folder
              mkdir -p /home/ec2-user/server
              cd /home/ec2-user/server

              # Download Minecraft server
              curl -O https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar

              # Accept EULA
              echo "eula=true" > eula.txt

              # Make jar executable
              chmod +x server.jar

              # Create systemd service for auto-start
              cat <<EOT | sudo tee /etc/systemd/system/minecraft.service
              [Unit]
              Description=Minecraft Server
              After=network.target

              [Service]
              User=ec2-user
              WorkingDirectory=/home/ec2-user/server
              ExecStart=/usr/bin/java -Xmx4G -Xms2G -jar server.jar nogui
              Restart=always
              RestartSec=20
              StandardOutput=append:/home/ec2-user/server/server.log
              StandardError=append:/home/ec2-user/server/server.log

              [Install]
              WantedBy=multi-user.target
              EOT

              sudo systemctl daemon-reload
              sudo systemctl enable minecraft.service
              sudo systemctl start minecraft.service
              EOF

  tags = {
    Name = var.instance_name
  }
}
