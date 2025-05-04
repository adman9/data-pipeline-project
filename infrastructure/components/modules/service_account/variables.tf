variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account."
  type        = string
  default     = "cloud-function-sa"
}

variable "service_account_display_name" {
  description = "The display name of the service account."
  type        = string
  default     = "Cloud Function Service Account"
}