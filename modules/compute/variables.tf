variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID of ALB"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instances"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable "user_data" {
  type        = string
  default     = ""
  description = "User data script to run on EC2 launch"
}

variable "name_prefix" {
  type        = string
  default     = "app"
  description = "Prefix for naming resources"
}