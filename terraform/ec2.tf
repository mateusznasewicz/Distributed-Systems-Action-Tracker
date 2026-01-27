resource "aws_key_pair" "deployer" {
  key_name   = "todo-app-key"
  public_key = tls_private_key.main_key.public_key_openssh
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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
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
  depends_on = [ aws_key_pair.deployer ]
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.medium"
  
  key_name      = "todo-app-key" 

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
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