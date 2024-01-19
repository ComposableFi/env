data "github_repository" "composable" {
  full_name = "ComposableFi/composable"
}

data "github_repository" "env" {
  full_name = "ComposableFi/env"
}



data "github_repository" "cometbft" {
  full_name = "ComposableFi/cometbft"
}

data "github_organization" "ComposableFi" {
  name = "ComposableFi"
}

data "github_repository" "ibc-apps" {
  name = "ibc-apps"
}