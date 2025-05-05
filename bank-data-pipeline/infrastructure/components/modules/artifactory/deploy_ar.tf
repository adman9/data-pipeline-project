terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.56.0"
    }
  }
}

resource "google_project_service" "artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "my_docker_repository" {
  project      = var.project_id
  location     = var.region
  repository_id = var.docker_repository_id
  format       = "DOCKER"
}
