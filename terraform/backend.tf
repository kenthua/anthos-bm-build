terraform {
 backend "gcs" {
   bucket  = "kenthua-dev"
   prefix  = "tfstate"
 }
}
