resource "tls_private_key" "main_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "todo-app-key-tf"
  public_key = tls_private_key.main_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.main_key.private_key_pem
  filename        = "${path.module}/todo-app-key.pem"
  file_permission = "0400" 
}