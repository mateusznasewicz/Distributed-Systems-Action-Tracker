provider "keycloak" {
    client_id     = "admin-cli"
    username      = "admin"
    password      = "admin"
    url           = "http://proxy/auth"
}

resource "keycloak_realm" "realm" {
  realm   = "todo-app-realm"
  enabled = true
  display_name = "To Do Application"
  registration_allowed = true
  attributes = {
    "userProfileEnabled" = "true"
  }
}

resource "keycloak_realm_user_profile" "userprofile" {
  realm_id = keycloak_realm.realm.id

  attribute {
    name = "username"
    permissions {
      view = ["admin", "user"]
      edit = ["admin", "user"]
    }
  }

  # WYŁĄCZENIE EMAILA
  attribute {
    name = "email"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }

  attribute {
    name = "firstName"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }

  attribute {
    name = "lastName"
    permissions {
      view = ["admin"]
      edit = ["admin"]
    }
  }
}

resource "keycloak_openid_client" "frontend_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "todo-app-frontend"
  name                = "Todo Frontend"
  enabled             = true
  access_type         = "PUBLIC"
  standard_flow_enabled = true
  
  valid_redirect_uris = [
    "http://proxy/*"
  ]
  web_origins = ["*"]
}