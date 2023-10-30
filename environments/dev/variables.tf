variable "name" {
  type        = string
  description = "The used in resources, can be Org or Project Name"
}

variable "project_id" {
  type        = string
  description = "The project ID to manage"
}

variable "region" {
  type        = string
  description = "Region"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "github_token" {
  type        = string
  description = "Token of github to clone Dags"
  sensitive   = true
}

variable "dags_repo" {
  type        = string
  description = "Dafault user mail for Aitflow"
}

variable "airflow_user" {
  type        = string
  description = "Dafault user for Aitflow"
}

variable "airflow_pass" {
  type        = string
  description = "Dafault user password for Aitflow"
  sensitive   = true
}

variable "airflow_mail" {
  type        = string
  description = "Dafault user mail for Aitflow"
}
