resource "google_dataplex_lake" "lake" {
  name         = "lake-${var.name}"
  display_name = "lake-${var.name}"
  location     = var.region
  project      = var.project_id
  labels = {
    "env"   = var.environment
    project = var.name
  }
}

resource "google_dataplex_zone" "dataplex-bronze" {
  for_each     = { for zone in var.zones : zone.name => zone }
  name         = format("dataplex-%s-%s", each.value.name, var.name)
  display_name = each.value.name
  location     = var.region
  project      = var.project_id
  lake         = google_dataplex_lake.lake.name
  type         = each.value.type

  discovery_spec {
    enabled = false
  }

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  labels = {
    "env"   = var.environment
    project = var.name
  }
}
