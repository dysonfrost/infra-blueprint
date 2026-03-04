variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
  default     = "eu-north-1"

}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "dataiku-assignment"

}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}
