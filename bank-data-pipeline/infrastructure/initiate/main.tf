terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.56.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}


resource "google_iam_workload_identity_pool" "main" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = var.pool_display_name
  description               = var.pool_description
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "main" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.main.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = var.provider_display_name
  description                        = var.provider_description
  attribute_condition                = var.attribute_condition
  attribute_mapping                  = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    allowed_audiences = var.allowed_audiences
    issuer_uri        = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "wif_service_account" {
  account_id   = var.ref
  display_name = var.ref
  description  = "serive account to provide OIDC access via work load identity federation"
  project      = var.project_id
}

resource "google_service_account_iam_member" "wif-sa" {
  service_account_id = google_service_account.wif_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.main.name}/attribute.repository/adman9/data-pipeline-project"
}