terraform {
  backend "gcs" {
    bucket = "bank-data-pipeline-tfstate"
    prefix = "cloud_functions"
  }
}