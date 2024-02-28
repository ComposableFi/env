
data "github_repository" "composable-vm" {
  full_name = "ComposableFi/composable-vm"
}


resource "github_repository_collaborators" "composable-vm" {
  repository = data.github_repository.composable-vm.name
  user {
    permission = "admin"
    username   = data.github_user.mantis.name
  }
  user {
    permission = "push"
    username =  data.github_user.python_1.username
  }
  user {
    permission = "push"
    username =  data.github_user.python_3.username
  }
  user {
    permission = "push"
    username =  data.github_user.algorithmist_1.username
  }
  user {
    permission = "push"
    username =  data.github_user.python_2.username
  }

  user {
    permission = "push"
    username =  data.github_user.docs.usernamew
  }

  user {
    permission = "pull"
    username =  data.github_user.solver_1.usernames
  }

  user {
    permission = "push"
    username =  data.github_user.solver_2.username
  }
}

resource "github_branch_protection_v3" "composable-vm" {
  repository     = data.github_repository.composable-vm.name
  branch         = "main"
  enforce_admins = true

    required_status_checks {
    strict   = false
    checks = [
      "main / check"
    ]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews = true

    bypass_pull_request_allowances {
      users = [data.github_user.mantis.name]
    }
  }
}