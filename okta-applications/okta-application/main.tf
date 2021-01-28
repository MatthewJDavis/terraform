terraform {
  required_providers {
    okta = {
      source = "oktadeveloper/okta"
      version = "~> 3.6"
    }
  }
}

# Configure the Okta Provider - API token set in env var.
provider "okta" {
  org_name  = var.org_name
  base_url  = var.base_url
}

resource "okta_app_oauth" "demo_app" {
  label = "Sample DotNet OIDC"
  type = "web"
  consent_method = "REQUIRED"
  login_uri = "https://localhost:5001/authorization-code/callback"
  post_logout_redirect_uris = ["https://localhost:5001/signout-callback-oidc"]
  redirect_uris = ["https://localhost:5001/signin-oidc"]
  omit_secret = false
  grant_types = ["authorization_code"]
  response_types = ["code"]
  groups = ["00g3yu4bj4Akjp4c25d6", "00g4688yfvdtKHYx05d6"]
}