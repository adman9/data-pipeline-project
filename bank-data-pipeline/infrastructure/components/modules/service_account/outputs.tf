output "service_account_email" {
  description = "The email of the service account used"
  value       = google_service_account.cloud_function_sa.email
}
