resource "google_bigquery_dataset" "_" {
  project       = var.project_id
  dataset_id    = local.tier_name
  friendly_name = local.tier_name
  description   = local.tier_name
  location      = var.region

  max_time_travel_hours = 168
  labels = {
    "env"                      = var.environment
    "project"                  = var.name
    "goog-dataplex-asset-id"   = local.asset_tier_name
    "goog-dataplex-lake-id"    = "lake-${var.name}"
    "goog-dataplex-project-id" = var.project_id
    "goog-dataplex-zone-id"    = local.zone_tier_name
  }
}
