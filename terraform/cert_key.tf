resource "tls_private_key" "main_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.main_key.private_key_pem
  filename        = "${path.module}/todo-app-key.pem"
  file_permission = "0400" 
}

resource "tls_self_signed_cert" "self_signed_cert" {
  private_key_pem = tls_private_key.main_key.private_key_pem

  subject {
    common_name = "todo-app" 
  }
  
  ip_addresses = [ local.target_ip ]

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}