resource "google_project_service" "services" {
  for_each = toset(var.services)
  service  = each.value
  project  = var.project_id
  disable_dependent_services = true
}

