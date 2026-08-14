terraform {
  backend "s3" {
    bucket       = "tinacloud-oracle-weblogic-platform-tf-state"
    key          = "enterprise-oracle-weblogic/production/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
