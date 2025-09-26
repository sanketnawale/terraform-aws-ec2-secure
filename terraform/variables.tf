variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-3"
  
  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.region))
    error_message = "Region must be a valid AWS region format."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition = contains(["t3.micro", "t3.small", "t2.micro"], var.instance_type)
    error_message = "Only cost-optimized instance types are allowed."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-ec2-secure"
}

