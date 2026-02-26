terraform {
    backend "s3" {
    bucket       = "gavin-open-webui-12345"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
