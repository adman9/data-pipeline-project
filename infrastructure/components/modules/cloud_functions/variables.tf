variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "region" {
  description = "The region in which to deploy the Cloud Function."
  type        = string
}

variable "service_account_email" {
  description = "The email of the service account."
  type        = string
}

variable "function_name" {
  description = "The name of the Cloud Function."
  type        = string
  default     = "my-function-docker"
}

variable "runtime" {
  description = "The runtime environment."
  type        = string
  default     = "python311"
}


variable "docker_repository" {
  description = "The full path to the Docker repository."
  type        = string
}


variable "max_instance_count" {
  description = "Maximum number of instances."
  type = number
  default = 10
}

variable "available_memory" {
  description = "Amount of memory available to the function."
  type = string
  default = "512Mi"
}

variable "timeout_seconds" {
  description = "Timeout for the function."
  type = number
  default = 300
}

variable "allow_all_users" {
  description = "Whether to allow all users to invoke the function."
  type        = string
  default     = "allUsers"
}

variable "trigger_bucket_name" {
  description = "The name of the Cloud Storage bucket that triggers the function."
  type        = string
}

variable "archival_bucket_name" {
  description = "The name of the Cloud Storage bucket for archival."
  type        = string
  default     = "bnk-trans-bucket-archieve"
}

variable "source_code_bucket" {
  description = "The Image name of the docker."
  type        = string
}

variable "source_code_name" {
  description = "The Image name of the docker."
  type        = string
}