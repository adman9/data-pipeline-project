terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.56.0"
    }
  }
}

resource "google_cloudfunctions2_function" "my_cloud_function" { 
  name                  = var.function_name
  runtime               = var.runtime
  service_account_email = var.service_account_email
  event_trigger {
    event_type = "google.cloud.storage.object.v1.finalized"
    bucket = var.trigger_bucket_name
  }
  build_config {
    docker_repository = var.docker_repository
  }
  service_config {
    max_instance_count = var.max_instance_count
    available_memory = var.available_memory
    timeout_seconds = var.timeout_seconds
  }
  environment_variables = {
    "PROJECT_ID" = var.project_id
    "REGION" = var.region
    "DATASET" = "BNK_DATA"
    "ARCHIVE_BUCKET" = var.archival_bucket_name
    "SPLITTER" = ","
  }
  depends_on = [
    google_artifact_registry_repository.my_docker_repository,
  ]
}

resource "google_cloudfunctions2_function_iam_member" "member" {
  project = google_cloudfunctions2_function.my_cloud_function.project
  location = google_cloudfunctions2_function.my_cloud_function.location
  cloud_function = google_cloudfunctions2_function.my_cloud_function.name
  role = "roles/cloudfunctions.invoker"
  member = var.allow_all_users
}
