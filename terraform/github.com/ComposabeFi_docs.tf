
resource "github_repository" "docs" {
  name        = "docs"
  description = "Docs which are not specific to any underlying coding domain (biz side)"

  has_issues             = false
  has_discussions        = false
  has_projects           = false
  has_wiki               = false
  is_template            = false
  delete_branch_on_merge = true
  visibility             = "public"
  web_commit_signoff_required = false
}

resource "github_repository_collaborators" "docs" {
  repository = github_repository.docs.name
  user {
    permission = "admin"
    username   = data.github_user.docs.username
  }
}

