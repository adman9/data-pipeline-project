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

resource "google_storage_bucket" "trigger_bucket" {
  name     = var.trigger_bucket_name
  location = var.region
}

resource "google_storage_bucket" "archival_bucket" {
  name     = var.archival_bucket_name
  location = var.region
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7
    }
  }
}

module "service_account" {
  source                  = "./modules/service_account"
  project_id              = var.project_id
  service_account_id      = "gcf-bank-transaction-gcs-bq-sa"
  service_account_display_name = "Cloud Function Service Account"
}

module "artifact_registry" {
  source                = "./modules/artifactory"
  project_id            = var.project_id
  region                = var.region
  docker_repository_id  = var.docker_repository_id
  image_name            = var.image_name
}

module "cloud_function" {
  source                = "./modules/cloud_functions"
  project_id            = var.project_id
  region                = var.region
  service_account_email = module.service_account.service_account_email
  docker_repository     = module.artifact_registry.docker_repository
  storage_source_bucket = var.source_code_bucket
  storage_source_name   = var.source_code_name
  function_name         = "gcf-bank-transaction-gcs-bq-v1"
  runtime               = "python311"
  max_instance_count = 10
  available_memory = "512Mi"
  timeout_seconds = 300
  allow_all_users = "allUsers"
  trigger_bucket_name = google_storage_bucket.trigger_bucket.name
}

output "function_name" {
  value = module.cloud_function.function_name
}


output "service_account_email" {
  value = module.service_account.service_account_email
}

output "docker_repository" {
  value = module.artifact_registry.docker_repository
}
