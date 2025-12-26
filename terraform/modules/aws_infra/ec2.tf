data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "app_sg" {
  name        = "todo-app-security-group"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  
  key_name      = "todo-app-key" 

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io docker-compose
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = local_file.private_key.content
        host        = self.public_ip
    }

    provisioner "file" {
        source      = "../docker-compose.yml"
        destination = "/home/ubuntu/docker-compose.yml"
    }

    provisioner "file" {
        source      = "../proxy.conf"
        destination = "/home/ubuntu/proxy.conf"
    }

    provisioner "file" {
        source      = "../default.conf"
        destination = "/home/ubuntu/default.conf"
    }

  tags = {
    Name = "Todo-App-Instance"
  }
}