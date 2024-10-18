terraform {
  backend "s3" {
    bucket         = "backendtfstate"
    key            = "crescendo/crescendo.tfstate"
    region         = "us-west-2"
    dynamodb_table = "backendlockstate"
  }
}