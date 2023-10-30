resource "google_storage_bucket" "_" {
  project                     = var.project_id
  name                        = format("%s-%s", var.name, var.environment)
  location                    = var.region
  uniform_bucket_level_access = true

  labels = {
    "env"     = var.environment
    "project" = var.name
  }
}
