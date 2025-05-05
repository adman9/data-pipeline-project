variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources."
  type        = string
  default     = "us-central1"
}

variable "docker_repository_id" {
  description = "The ID of the Docker repository."
  type        = string
}
