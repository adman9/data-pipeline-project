variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources."
  type        = string
}

variable "trigger_bucket_name" {
  description = "The name of the Cloud Storage bucket that triggers the function."
  type        = string
}

variable "archival_bucket_name" {
  description = "The name of the Cloud Storage bucket for archival."
  type        = string
}

