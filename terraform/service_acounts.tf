#
resource "google_service_account" "connect_agent_svc_account" {
  account_id   = var.connect_sa
  display_name = "Connect"
  project      = var.project_id
}

resource "google_project_iam_member" "connect_agent_svc_account_gkehubconnect" {
  project = var.project_id
  role    = "roles/gkehub.connect"
  member  = "serviceAccount:${google_service_account.connect_agent_svc_account.email}"
}

#
resource "google_service_account" "connect_register_svc_account" {
  account_id   = var.connect_register_sa
  display_name = "Register"
  project      = var.project_id
}

resource "google_project_iam_member" "connect_register_svc_account_gkehubadmin" {
  project = var.project_id
  role    = "roles/gkehub.admin"
  member  = "serviceAccount:${google_service_account.connect_register_svc_account_gkehubadmin.email}"
}

#
resource "google_service_account" "logging_monitoring_svc_account" {
  account_id   = var.logging_monitoring_sa
  display_name = "Logging Monitoring"
  project      = var.project_id
}

resource "google_project_iam_member" "logging_monitoring_svc_account_logwriter" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.logging_monitoring_svc_account.email}"
}

resource "google_project_iam_member" "logging_monitoring_svc_account_metricwriter" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.logging_monitoring_svc_account.email}"
}

resource "google_project_iam_member" "logging_monitoring_svc_account_resourcemetadatawriter" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.logging_monitoring_svc_account.email}"
}

resource "google_project_iam_member" "logging_monitoring_svc_account_dashboardeditor" {
  project = var.project_id
  role    = "roles/monitoring.dashboardEditor"
  member  = "serviceAccount:${google_service_account.logging_monitoring_svc_account.email}"
}


# generate/download keys
resource "google_service_account_key" "connect_agent_svc_account_key" {
  service_account_id = google_service_account.connect_agent_svc_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "connect_agent_svc_account_key_file" {
  content  = base64decode(google_service_account_key.connect_agent_svc_account_key.private_key)
  filename = "connect_agent_svc_account_key.json"
}

resource "google_storage_bucket_object" "connect_agent_svc_account_key_file_object" {
  name       = "sa/connect_agent_svc_account_key.json"
  source     = "connect_agent_svc_account_key.json"
  bucket     = var.project_id
  depends_on = [
    local_file.connect_agent_svc_account_key_file
  ]
}

#
resource "google_service_account_key" "connect_register_svc_account_key" {
  service_account_id = google_service_account.connect_register_svc_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "connect_register_svc_account_key_file" {
  content  = base64decode(google_service_account_key.connect_register_svc_account_key.private_key)
  filename = "connect_register_svc_account_key.json"
}

resource "google_storage_bucket_object" "connect_register_svc_account_key_file_object" {
  name       = "sa/connect_register_svc_account_key.json"
  source     = "connect_register_svc_account_key.json"
  bucket     = var.project_id
  depends_on = [
    local_file.connect_register_svc_account_key_file
  ]
}

resource "google_service_account_key" "logging_monitoring_svc_account_key" {
  service_account_id = google_service_account.logging_monitoring_svc_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "logging_monitoring_svc_account_key_file" {
  content  = base64decode(google_service_account_key.logging_monitoring_svc_account_key.private_key)
  filename = "logging_monitoring_svc_account_key.json"
}

resource "google_storage_bucket_object" "logging_monitoring_svc_account_key_file_object" {
  name       = "sa/logging_monitoring_svc_account_key.json"
  source     = "logging_monitoring_svc_account_key.json"
  bucket     = var.project_id
  depends_on = [
    local_file.logging_monitoring_svc_account_key_file
  ]
}