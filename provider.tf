
provider "aws" {
  region = var.region
  shared_credentials_files = ["~/.aws/credentials"]
  profile = "default"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

