variable "ECR_URI" {
  description = ""
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "SECRET_ARN" {
  description = "API key ARN for lambda instance"
  type        = string
}
