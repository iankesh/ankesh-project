terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "devsecfinops"

    workspaces {
      prefix = "ankesh-"
    }
  }
}
