provider "docker" {
  host = "ssh://ubuntu@${aws_instance.app_server.public_ip}:22"
}

resource "docker_network" "todo_net" { name = "todo_network" }
resource "docker_volume" "postgres_data" { name = "postgres_data" }
resource "docker_volume" "minio_data"    { name = "minio_data" }
resource "docker_volume" "keycloak_data" { name = "keycloak_data" }
resource "docker_volume" "grafana_data" { name = "grafana_data" }
resource "docker_volume" "prometheus_data" { name = "prometheus_data" }


resource "docker_container" "database" {
  name  = "database"
  image = "postgres:latest"
  networks_advanced { name = docker_network.todo_net.name }
  env = [
    "POSTGRES_USER=userdb",
    "POSTGRES_PASSWORD=passdb",
    "POSTGRES_DB=todo-app"
  ]
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql"
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "docker_container" "minio" {
  name  = "minio"
  image = "minio/minio:latest"
  command = ["server", "/data"]
  networks_advanced { name = docker_network.todo_net.name }

  ports {
    internal = 9000
    external = 9090
  }

  env = [
    "MINIO_ROOT_USER=minioadmin",
    "MINIO_ROOT_PASSWORD=minioadmin",
  ]

  volumes {
    volume_name    = docker_volume.minio_data.name
    container_path = "/data"
  }
}

resource "docker_container" "keycloak" {
  name  = "keycloak"
  image = "keycloak/keycloak:latest"
  command = ["start-dev"]
  networks_advanced { name = docker_network.todo_net.name }
  env = [
    "KC_HTTP_ENABLED=true",
    "KC_HTTP_RELATIVE_PATH=/auth",
    "KC_BOOTSTRAP_ADMIN_USERNAME=admin",
    "KC_BOOTSTRAP_ADMIN_PASSWORD=admin",
    "KC_PROXY_HEADERS=xforwarded"
  ]
  volumes {
    volume_name    = docker_volume.keycloak_data.name
    container_path = "/opt/keycloak/data"
  }
}

resource "docker_container" "backend" {
  name  = "backend"
  image = "mateusznasewicz/todo-app-backend:20260125-210012"
  networks_advanced { name = docker_network.todo_net.name }
  
  depends_on = [docker_container.database, minio_s3_bucket.bucket]

  env = [
    "DB_URL=database",
    "DB_PORT=5432",
    "DB_NAME=todo-app",
    "DB_USER=userdb",
    "DB_PASSWORD=passdb",
    "SERVER_PORT=8080",
    "MINIO_ENDPOINT=http://minio:9000",
    "MINIO_PUBLIC_ENDPOINT=https://${aws_instance.app_server.public_ip}:9000",
    "DOMAIN=${aws_instance.app_server.public_dns}",
    "MINIO_ACCESS_KEY=${minio_iam_service_account.app_user_creds.access_key}", 
    "MINIO_SECRET_KEY=${minio_iam_service_account.app_user_creds.secret_key}",
    "MINIO_BUCKET_NAME=${minio_s3_bucket.bucket.id}",
    "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUER_URI=https://${aws_instance.app_server.public_dns}/auth/realms/todo-app-realm",
    "SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI=http://keycloak:8080/auth/realms/todo-app-realm/protocol/openid-connect/certs"
  ]
}

resource "docker_container" "frontend" {
  name  = "frontend"
  image = "mateusznasewicz/todo-app-frontend:20260125-212914"
  networks_advanced { name = docker_network.todo_net.name }
}

resource "docker_container" "proxy" {
  name  = "proxy"
  image = "nginx:latest"
  networks_advanced { name = docker_network.todo_net.name }
  
  upload {
    content = tls_self_signed_cert.self_signed_cert.cert_pem
    file    = "/etc/ssl/certs/server.crt"
  }

  upload {
    content = tls_private_key.main_key.private_key_pem
    file    = "/etc/ssl/private/server.key"
  }

  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 9000
    external = 9000
  }

  upload {
    content = file("${path.module}/../proxy.conf")
    file = "/etc/nginx/conf.d/default.conf"
  }
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"
  networks_advanced { name = docker_network.todo_net.name }

  upload {
    content = file("${path.module}/../prometheus.yml")
    file = "/etc/prometheus/prometheus.yml"
  }

  volumes {
    volume_name      =  docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"
  networks_advanced { name = docker_network.todo_net.name }

  env = [
    "GF_SERVER_DOMAIN=${aws_instance.app_server.public_dns}",
    "GF_SERVER_ROOT_URL=%(protocol)s://%(domain)s:%(http_port)s/grafana/",
    "GF_SERVER_SERVE_FROM_SUB_PATH=true"
  ]

  upload {
    content = file("${path.module}/../grafana_datasource.yml")
    file = "/etc/grafana/provisioning/datasources/datasource.yaml"
  }

  volumes {
    volume_name = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }
}