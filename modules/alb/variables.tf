variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "name_prefix" {
  type        = string
  default     = "app"
  description = "Prefix for naming resources"
}