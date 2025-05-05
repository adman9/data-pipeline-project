output "function_name" {
  description = "The name of the Cloud Function."
  value       = google_cloudfunctions2_function.my_cloud_function.name 
}
