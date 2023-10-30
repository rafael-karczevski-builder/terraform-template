#region VPC
module "vpc" {
  source = "../../modules/vpc"

  project_id = var.project_id
  name       = "${var.name}-net"
}
#endregion

#region Subnet
module "subnet" {
  source     = "../../modules/subnet"
  project_id = var.project_id
  region     = var.region
  name       = "${var.name}-subnet"
  network    = module.vpc.id
  cidr       = "10.126.0.0/20"
}
#endregion Subnet

#region Firewall
module "allow-airflow" {
  source     = "../../modules/firewall"
  project_id = var.project_id
  network    = module.vpc.id
  name       = "allow-airflow"

  ports = ["8080"]

  target_tags = ["airflow-http"]
  source_ranges = [
    "179.95.52.244/32"
  ]
}

module "allow-rdp" {
  source     = "../../modules/firewall"
  project_id = var.project_id
  network    = module.vpc.id
  name       = "allow-rdp"

  ports = ["3389"]

  target_tags = ["allow-rdp"]
  source_ranges = [
    "179.95.52.244/32"
  ]
}
#endregion

#region IAM
module "iam_dags_sync_git_actions" {
  source = "../../modules/iam"

  project_id  = var.project_id
  id          = "DagsSyncGitActionsCustomRoleTF"
  title       = "Dags Sync Git Actions Custom Role"
  description = "Dags Sync Git Actions Custom Role"
  permissions = [
    "storage.objects.list",
    "storage.objects.delete",
    "storage.objects.create"
  ]
}
#endregion IAM

#region Compute Instance
module "airflow-vm" {
  source = "../../modules/compute_instance"

  project_id   = var.project_id
  zone         = var.zone
  name         = "vm-airflow"
  machine_type = "n2-standard-2"
  tags = [
    "airflow-http"
  ]

  environment = "dev"
  image       = "debian-cloud/debian-11"
  disk_size   = 50

  network         = module.vpc.id
  subnet          = module.subnet.id
  external_access = true

  startup_script = data.template_file.init-airflow.rendered
}

module "airflow-power-bi" {
  source = "../../modules/compute_instance"

  project_id   = var.project_id
  zone         = var.zone
  name         = "vm-power-bi"
  machine_type = "n2-custom-4-19712"
  tags = [
    "airflow-rdp"
  ]

  environment = "dev"
  image       = "windows-cloud/windows-2022"
  disk_size   = 100

  network         = module.vpc.id
  subnet          = module.subnet.id
  external_access = true
}
#endregion

#region BigQuery
module "bronze" {
  source      = "../../modules/big_query"
  environment = "dev"
  name        = var.name
  project_id  = var.project_id

  tier   = "bronze"
  region = var.region
}

module "silver" {
  source      = "../../modules/big_query"
  environment = "dev"
  name        = var.name
  project_id  = var.project_id

  tier   = "silver"
  region = var.region
}

module "gold" {
  source      = "../../modules/big_query"
  environment = "dev"
  name        = var.name
  project_id  = var.project_id

  tier   = "gold"
  region = var.region
}
#endregion

#region Storage
module "lake" {
  source      = "../../modules/storage"
  environment = "dev"
  name        = "lake"
  project_id  = var.project_id

  region = var.region
}

module "lake-inputs" {
  source      = "../../modules/storage"
  environment = "dev"
  name        = "lake-inputs"
  project_id  = var.project_id

  region = var.region
}
#endregion

#region Dataplex
module "datalake" {
  source      = "../../modules/dataplex"
  environment = "dev"
  name        = "lake"
  project_id  = var.project_id

  region = var.region

  zones = [
    {
      name = "bronze",
      type = "RAW"
    },
    {
      name = "silver",
      type = "CURATED"
    }
  ]
}
#endregion

data "template_file" "init-airflow" {
  vars = {
    github_token = var.github_token
    airflow_user = var.airflow_user
    airflow_pass = var.airflow_pass
    airflow_mail = var.airflow_mail
    dags_repo    = var.dags_repo
  }

  template = file("../../scripts/init-airflow.sh")
}
