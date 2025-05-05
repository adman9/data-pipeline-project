terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.56.0"
    }
  }
}

data "google_project" "project" {
}

resource "google_service_account" "cloud_function_sa" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_project_iam_member" "cloud_function_sa_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "google_project_iam_member" "eventarc_event_receiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
}

resource "google_service_account_iam_binding" "cloud_function_sa_use" {
  service_account_id = google_service_account.cloud_function_sa.name
  role    = "roles/iam.serviceAccountUser"
  members  = [
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
    "serviceAccount:sa-cicd@favorable-kiln-458413-r9.iam.gserviceaccount.com",
  ]
  
}


