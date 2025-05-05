terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.56.0"
    }
  }
}

resource "google_cloudfunctions2_function" "my_cloud_function" {
  name = var.function_name
  location = var.region
  description = "cloud Function to load the files from storage to big query"

  build_config {
    runtime     = var.runtime
    entry_point = "data_loading"
    source {
      storage_source {
        bucket = var.source_code_bucket
        object = var.source_code_name
      }
    }
  }

  service_config {
    max_instance_count  = var.max_instance_count
    available_memory    = var.available_memory
    timeout_seconds     = var.timeout_seconds
    environment_variables = {
      "PROJECT_ID" = var.project_id
      "REGION" = var.region
      "DATASET" = "BNK_DATA"
      "ARCHIVE_BUCKET" = var.archival_bucket_name
      "SPLITTER" = ","
    }
    service_account_email = var.service_account_email
  }

  event_trigger {
    event_type = "google.cloud.storage.object.v1.finalized"
    event_filters {
      attribute = "bucket"
      value = var.trigger_bucket_name
    }
  }
}

resource "google_cloudfunctions2_function_iam_member" "member" {
  project = google_cloudfunctions2_function.my_cloud_function.project
  location = google_cloudfunctions2_function.my_cloud_function.location
  cloud_function = google_cloudfunctions2_function.my_cloud_function.name
  role = "roles/cloudfunctions.invoker"
  member = var.allow_all_users
}

resource "google_cloudfunctions2_function_iam_member" "member_run" {
  project = google_cloudfunctions2_function.my_cloud_function.project
  location = google_cloudfunctions2_function.my_cloud_function.location
  cloud_function = google_cloudfunctions2_function.my_cloud_function.name
  role = "roles/run.invoker"
  member = var.allow_all_users
}
