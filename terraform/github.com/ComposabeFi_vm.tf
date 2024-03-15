


resource "github_repository" "composable-vm" {
  description = "Interchain Atomicity, Blockbuilding and Routing via Composable VM"
  name        = "composable-vm"
  has_issues             = true
  has_discussions        = false
  has_projects           = false
  has_wiki               = false
  is_template            = false
  visibility             = "public"
  delete_branch_on_merge      = false
  has_downloads               = false
  homepage_url                = "https://mantis.app"  
  vulnerability_alerts = false
  web_commit_signoff_required = false
}



resource "github_repository_collaborators" "composable-vm" {
  repository = github_repository.composable-vm.name
  user {
    permission = "admin"
    username   = data.github_user.mantis.username
  }
  user {
    permission = "push"
    username   = data.github_user.python_1.username
  }
  user {
    permission = "push"
    username   = data.github_user.python_3.username
  }
  user {
    permission = "push"
    username   = data.github_user.algorithmist_1.username
  }
  user {
    permission = "push"
    username   = data.github_user.python_2.username
  }

  user {
    permission = "push"
    username   = data.github_user.docs.username
  }

  user {
    permission = "pull"
    username   = data.github_user.solver_1.username
  }

  user {
    permission = "push"
    username   = data.github_user.solver_2.username
  }
}

# resource "github_branch_protection_v3" "composable-vm" {

#   repository     = github_repository.composable-vm.name
#   branch         = "main"
#   enforce_admins = true

#   required_status_checks {
#     strict = false
#     checks = [
#       "main / check"
#     ]
#   }

#   required_pull_request_reviews {
#     dismiss_stale_reviews = true

#     bypass_pull_request_allowances {
#       users = [data.github_user.mantis.name]
#     }
#   }
# }