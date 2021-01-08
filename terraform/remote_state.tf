data "terraform_remote_state" "services" {
  backend = "gcs"

  config = {
    bucket  = var.project_id
    prefix  = "tfstate"
  }
}
