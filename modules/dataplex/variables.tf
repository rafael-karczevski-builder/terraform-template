variable "project_id" {
  type        = string
  description = "The project ID to manage"
}

variable "name" {
  type        = string
  description = "Subnet name"
}

variable "region" {
  type        = string
  description = "Region of subnet"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "zones" {
  type = list(object({
    name = string,
    type = string
  }))
  description = "List of zone names"
}
