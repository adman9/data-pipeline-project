variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "region" {
  description = "The region in which to deploy resources."
  type        = string
}


variable "pool_id" {
  type = string
  default = "data-pipeline-project-cicd"
}

variable "pool_display_name" {
  type = string
  default = "data-pipeline-project-cicd"
}

variable "pool_description" {
  type = string
  default = "Work identity pool to connect Git"
}

variable "provider_id" {
  type = string
  default = "github-identity-provider"
}

variable "provider_display_name" {
  type = string
  default = "github-identity-provider"
}

variable "provider_description" {
  type = string
  default = "to authenticate git hub call"
}

variable "allowed_audiences" {
  type        = list(string)
  description = "Workload Identity Pool Provider allowed audiences."
  default     = []
}

variable "attribute_condition" {
type = string
description = "To restrict access on WIP Provider"
default = "attribute.repository in ['adman9/data-pipeline-project']"

}

variable "ref" {
description = "service account needs to be created to deploy cloud services"
default = "sa-cicd"
}

