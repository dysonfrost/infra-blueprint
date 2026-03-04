variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources into"
  default     = "eu-north-1"

}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "infra-blueprint"

}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "key_pair_name" {
  type        = string
  description = "Name of the pre-existing EC2 key pair"
  default     = "infra-blueprint-keypair"
}

variable "domain_name" {
  type        = string
  description = "Existing domain name"
  default     = "will-it-scale.in"
}
