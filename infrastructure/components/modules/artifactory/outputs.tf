output "docker_repository" {
  description = "The full path to the Docker repository."
  value       = "projects/${var.project_id}/locations/${var.region}/repositories/${var.docker_repository_id}"
}

output "image" {
  description = "The full path to the Docker repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.docker_repository_id}/${var.image_name}:latest"
}