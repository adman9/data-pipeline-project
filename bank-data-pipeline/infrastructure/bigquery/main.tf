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

resource "google_bigquery_data_transfer_config" "scheduled_queries" {
  
  for_each                   = local.queries

  project                    = var.project_id
  service_account_name       = var.service_account_name  
  location                   = var.location
  data_source_id             = var.data_source_id
  notification_pubsub_topic  = var.notification_pubsub_topic
  display_name               = each.value.display_name
  schedule                   = each.value.schedule
  params                     = each.value.params
  schedule_options {
    start_time               = each.value.start_time
  }
}