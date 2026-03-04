terraform {
  backend "s3" {
    bucket       = "infra-blueprint-terraform-state-en3to"
    key          = "infra/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
