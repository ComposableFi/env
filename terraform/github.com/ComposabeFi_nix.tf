
resource "github_repository" "nix" {
  name        = "nix"
  description = "New devnet without garbage (migrate nix from composable polkadot repo)"

  has_issues = false
  has_discussions = false
  has_projects = false
  has_wiki = false
  is_template = false
  delete_branch_on_merge = true
  visibility = "public"
}

