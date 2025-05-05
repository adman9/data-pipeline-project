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
  default     = "bnk-trans-bucket"
}

variable "archival_bucket_name" {
  description = "The name of the Cloud Storage bucket for archival."
  type        = string
  default     = "bnk-trans-bucket-archieve"
}

variable "docker_repository_id" {
  description = "The ID of the Docker repository."
  type        = string
}

variable "source_code_bucket" {
  description = "The name of the source code bucket"
  type        = string
}

variable "source_code_name" {
  description = "The name of the source code"
  type        = string
}