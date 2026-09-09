variable "aws_region" {
  description = "AWS Region for all project resources."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Prefix used for resource names."
  type        = string
  default     = "quickcart-orders"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention."
  type        = number
  default     = 14
}

variable "consumer_max_concurrency" {
  description = "Maximum concurrent consumer Lambda invocations from this SQS source."
  type        = number
  default     = 10
}


variable "vpc_cidr" {
  description = "CIDR for the project VPC."
  type        = string
  default     = "10.20.0.0/16"
}
variable "public_subnet_a_cidr" {
  type    = string
  default = "10.20.0.0/24"
}
variable "public_subnet_b_cidr" {
  type    = string
  default = "10.20.1.0/24"
}
variable "private_subnet_a_cidr" {
  type    = string
  default = "10.20.10.0/24"
}
variable "private_subnet_b_cidr" {
  type    = string
  default = "10.20.11.0/24"
}

variable "enable_pitr" {
  description = "Enable DynamoDB point-in-time recovery. Recommended for production; false by default for the prototype."
  type        = bool
  default     = false
}
