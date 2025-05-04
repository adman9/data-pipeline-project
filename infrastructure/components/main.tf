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
}

resource "google_storage_bucket_lifecycle_policy" "archival_bucket_lifecycle" {
  bucket = google_storage_bucket.archival_bucket.name
  rule {
    action {
      type = "Delete"
    }
    condition {
      age_in_days = 7
    }
  }
}

module "service_account" {
  source                  = "./modules/service-account"
  project_id              = var.project_id
  service_account_id      = var.service_acount
  service_account_display_name = "Cloud Function Service Account"
}

module "artifact_registry" {
  source                = "./modules/artifact-registry"
  project_id            = var.project_id
  region                = var.region
  docker_repository_id  = var.docker_repository_id
}

module "cloud_function" {
  source                = "./modules/cloud-function"
  project_id            = var.project_id
  region                = var.region
  service_account_email = module.service_account.service_account_email
  docker_repository     = module.artifact_registry.docker_repository
  function_name         = var.function_name
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

output "function_url" {
  value     = module.cloud_function.function_url
  sensitive = true
}

output "service_account_email" {
  value = module.service_account.service_account_email
}

output "docker_repository" {
  value = module.artifact_registry.docker_repository
}
