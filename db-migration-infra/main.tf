terraform {
  backend "s3" {
    bucket = "terraform-state-db-migration"
    key    = "db_migration_stack/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}
