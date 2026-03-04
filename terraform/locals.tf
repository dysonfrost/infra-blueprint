locals {
  common_tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "terraform"
  }
  selected_azs = slice(sort(data.aws_availability_zones.available.names), 0, 2)
}
