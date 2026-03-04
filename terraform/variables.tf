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

variable "key_pair_name" {
  type        = string
  description = "Name of the pre-existing EC2 key pair"
  default     = "dataiku-assignment-keypair"
}

variable "ssh_public_ip" {
  type        = string
  description = "Own public IP from env"
  sensitive   = true
}
