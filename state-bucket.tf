resource "aws_s3_bucket" "terraform_state_repo" {
  bucket = "terraform-state-repo"

  versioning {
    enabled = true
  }

}
