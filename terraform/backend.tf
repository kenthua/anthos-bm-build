terraform {
 backend "gcs" {
   bucket  = "PROJECT_ID"
   prefix  = "tfstate"
 }
}
