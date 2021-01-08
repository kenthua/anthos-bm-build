terraform {
  required_version = ">=0.14, <0.15"
}

provider "google" {
  version = "~>3.51.1"
}

provider "google-beta" {
  version = "~>3.51.1"
}