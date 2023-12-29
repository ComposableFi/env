
data "github_user" "docs" {
  username = "JafarAz"
}

data "github_team" "sre" {
  slug = "sre"
}

data "github_team" "devs" {
  slug = "developers"
}

data "github_team" "product" {
  slug = "product-mgmt"
}




resource "github_repository_collaborators" "cvm" {
  repository = data.github_repository.cvm.name
  user {
    permission = "admin"
    username   = data.github_user.mantis.name
  }
  user {
    permission = "push"
    username =  data.github_user.python.username
  }

  user {
    permission = "pull"
    username =  data.github_user.solver_1.username
  }

  user {
    permission = "pull"
    username =  data.github_user.solver_2.username
  }
}

resource "github_repository_collaborators" "composable" {
  repository = data.github_repository.composable.name

  team {
    permission = "push"
    team_id    = data.github_team.devs.slug
  }

  user {
    permission = "push"
    username =  data.github_user.python.username
  }
  user {
    permission = "admin"
    username   = data.github_user.mantis.name
  }

  user {
    permission = "maintain"
    username   = "JafarAz"
  }

  user {
    permission = "admin"
    username   = "kkast"
  }

  user {
    permission = "maintain"
    username   = "RustNinja"
  }

  team {
    permission = "maintain"
    team_id    = data.github_team.product.slug
  }

  team {
    permission = "maintain"
    team_id    = data.github_team.sre.slug
  }
}
