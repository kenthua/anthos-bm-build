resource "google_project_service" "project" {
  service = "servicemanagement.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "project" {
  service = "servicecontrol.googleapis.com"
  disable_dependent_services = true
}