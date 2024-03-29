
resource "github_repository" "arxiv" {
  name        = "arxiv"
  description = "Rendered forever frozen content and location PDF files"

  has_issues             = false
  has_discussions        = false
  has_projects           = false
  has_wiki               = false
  is_template            = false
  delete_branch_on_merge = true
  visibility             = "public"
  web_commit_signoff_required = false
}

resource "github_repository_collaborators" "arxiv" {
  repository = github_repository.arxiv.name
  user {
    permission = "admin"
    username   = data.github_user.docs.username
  }
}

