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
