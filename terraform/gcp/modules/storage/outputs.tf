output "private_bucket_name" {
  value = google_storage_bucket.storage_bucket_private.name
  description = "The name of the private storage bucket"
}

output "private_bucket_url" {
  value = google_storage_bucket.storage_bucket_private.url
  description = "The URL of the private storage bucket"
}

output "public_bucket_name" {
  value = google_storage_bucket.storage_bucket_public.name
  description = "The name of the public storage bucket"
}

output "public_bucket_url" {
  value = google_storage_bucket.storage_bucket_public.url
  description = "The URL of the public storage bucket"
}

