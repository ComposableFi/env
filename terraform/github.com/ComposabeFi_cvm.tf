
data "github_repository" "cvm" {
  full_name = "ComposableFi/cvm"
}


resource "github_repository_collaborators" "cvm" {
  repository = data.github_repository.cvm.name
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
    username =  data.github_user.python_2.username
  }

  user {
    permission = "pull"
    username =  data.github_user.solver_1.username
  }

  user {
    permission = "push"
    username =  data.github_user.solver_2.username
  }
}

resource "github_branch_protection_v3" "name" {
  repository     = data.github_repository.cvm.name
  branch         = "main"
  enforce_admins = true

    required_status_checks {
    strict   = false
    checks = [
      "ci/check"
    ]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews = true

    bypass_pull_request_allowances {
      users = [data.github_user.mantis.name]
    }
  }
}