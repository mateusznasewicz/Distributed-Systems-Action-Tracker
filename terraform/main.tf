terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = "5.6.0"
    }
    minio = {
      source = "aminueza/minio"
      version = "3.12.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
  skip_credentials_validation = var.deployment_target == "local" ? true : false
  skip_requesting_account_id  = var.deployment_target == "local" ? true : false
  skip_metadata_api_check     = var.deployment_target == "local" ? true : false
}

module "infrastructure" {
  source = "./modules/aws_infra"
  count  = var.deployment_target == "aws" ? 1 : 0
}

locals {
  target_ip = var.deployment_target == "local" ? "127.0.0.1" : module.infrastructure[0].instance_ip
  docker_host = var.deployment_target == "local" ? "unix:///var/run/docker.sock" : "ssh://ubuntu@${local.target_ip}:22"
  proxy_config_path = var.deployment_target == "local" ? abspath("${path.module}/../proxy.conf") : "/home/ubuntu/app/proxy.conf"
  current_dns = var.deployment_target == "local" ? "proxy" : module.infrastructure.public_dns
}

