terraform {
  backend "s3" {
    bucket         = "ekelola-tfstate" # created by bootstrap
    key            = "prod/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "ekelola-tflock" # created by bootstrap
    encrypt        = true
  }
}
