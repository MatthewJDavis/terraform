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

resource "okta_user" "terraform_application" {
  login = "svc_terraform@example.com"
  email = "svc_terraform@example.com"
  first_name = "Terraform"
  last_name = "Application Automation"
  password = var.password
  admin_roles = [ "APP_ADMIN" ]
}

resource "okta_user" "terraform_application_svc" {
  login = "matthewdavis111+tokt@gmail.com"
  email = "matthewdavis111+tokt@gmail.com"
  first_name = "Terraform"
  last_name = "Application Automation"
  password = var.password
  admin_roles = [ "APP_ADMIN" ]
}