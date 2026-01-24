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
}

