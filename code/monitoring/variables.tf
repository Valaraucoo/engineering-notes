variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the specified threshold"
  type        = number
  default     = 2
}

variable "period" {
  description = "The period in seconds over which the specified statistic is applied"
  type        = number
  default     = 300
}

variable "threshold" {
  description = "The maximum size of the s3 bucket (in bytes)"
  type        = number
  default     = 100
}

variable "email" {
  description = "Email address to send alerts to"
  type        = string
}
