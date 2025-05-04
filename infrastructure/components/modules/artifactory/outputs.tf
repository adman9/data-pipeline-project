output "docker_repository" {
  description = "The full path to the Docker repository."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.docker_repository_id}/${var.image_name}:latest"
}
