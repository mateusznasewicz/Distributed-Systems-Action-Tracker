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
  }
}

