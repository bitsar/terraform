# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create Terraform backend resource for state management
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  backend "s3" {
    encrypt = true
    bucket = "terraform-state-repo"
    dynamodb_table = "terraform_state_lock"
    region = "ap-southeast-2"
    key = "terraform.tfstate"
  }
}
