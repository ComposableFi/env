variable "GITHUB_TOKEN" {
  type      = string
  sensitive = true
}

variable "CACHIX_AUTH_TOKEN" {
  type      = string
  sensitive = true
}

data "github_repository" "self" {
  full_name = "ComposibleFi/composable"
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 5.23.0"
    }
  }
}

provider "github" {
  owner = "ComposableFi"
  token = var.GITHUB_TOKEN
}

terraform {
  backend "s3" {
    bucket = "composablefi-env-terraform-github-com"
    key = "default"
    region = "eu-central-1"
  }
}

resource "github_actions_secret" "CACHIX_AUTH_TOKEN" {
  repository       = "composable"
  secret_name      = "CACHIX_AUTH_TOKEN"
  plaintext_value  = var.CACHIX_AUTH_TOKEN
}

resource "github_actions_secret" "cvm_CACHIX_AUTH_TOKEN" {
  repository       = "cvm"
  secret_name      = "CACHIX_AUTH_TOKEN"
  plaintext_value  = var.CACHIX_AUTH_TOKEN
}