terraform {
 backend "gcs" {
   bucket  = var.project_id
   prefix  = "tfstate"
 }
}
