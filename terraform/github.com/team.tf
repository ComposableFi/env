
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

resource "github_repository_collaborators" "env" {
  repository = data.github_repository.env.name
  user {
    permission = "pull"
    username   = data.github_user.nikita.username
  }
  user {
    permission = "pull"
    username   = data.github_user.sre_2.username
  }
}



resource "github_repository_collaborators" "cometbft" {
  repository = data.github_repository.cometbft.name

  user {
    permission = "maintain"
    username   = data.github_user.nikita.username
  }
}

resource "github_repository_collaborators" "composable" {
  repository = data.github_repository.composable.name

  team {
    permission = "push"
    team_id    = data.github_team.devs.slug
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
    permission = "push"
    username   = data.github_user.sre_2.username
  }

  user {
    permission = "admin"
    username   = "kkast"
  }

  user {
    permission = "maintain"
    username   = data.github_user.nikita.username
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

resource "github_repository_collaborators" "ibc-apps" {
  repository = data.github_repository.ibc-apps.name
  user {
    permission = "push"
    username   = data.github_user.candidate_1.username
  }
}