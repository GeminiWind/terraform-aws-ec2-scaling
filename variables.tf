
# ---------------------------------------------------------------------------------------------------------------------
# AWS Provider Configuration
# ---------------------------------------------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-southeast-2"
}


# ---------------------------------------------------------------------------------------------------------------------
# Application Configuration
# ---------------------------------------------------------------------------------------------------------------------
variable "app" {
  description = "Identifed application name"
}

variable "stage" {
  description = "Stage where app should be deployed like dev, staging or prod."
  default = "dev"
}

# ---------------------------------------------------------------------------------------------------------------------
# Launch Configuration
# ---------------------------------------------------------------------------------------------------------------------

variable "image_id" {
  description = "The EC2 image ID to launch."
}

variable "instance_type" {
  description = "EC2 instance type to be lauched. For e.g: t2.micro."
  default     = "t2.micro"
}

variable "user_data" {
  description = "(Optional) The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  default     = ""
}
variable "user_data_base64" {
  description = "(Optional) Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  default     = ""
}

variable "enable_monitoring" {
  description = "(Optional) Enables/disables detailed monitoring. This is enabled by default."
  type        = bool
  default     = true
}

variable "ebs_optimized" {
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "SSH Key name to connect your EC2."
}

variable "instance_ingress" {
  type        = list(object({
                from_port = number
                to_port = number
                protocol = string
                cidr_blocks = list(string)
              }))
  description = "Ingress rule for security group of the instance"
}

variable "instance_egress" {
  type        = list(object({
                from_port = number
                to_port = number
                protocol = string
                cidr_blocks = list(string)
              }))
  description = "Egress rule for security group of the instance"
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS EC2 AUTO SCALING GROUP
# ---------------------------------------------------------------------------------------------------------------------

variable "max_size" {
  description = "The maximum size of the auto scale group."
  type        = number
  default     = 2
}

variable "min_size" {
  description = "The minimum size of the auto scale group. (See also Waiting for Capacity.)"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "(Optional) The number of Amazon EC2 instances that should be running in the group. (See also Waiting for Capacity.)"
  type        = number
  default     = 1
}

variable "default_cooldown" {
  description = "(Optional, Default: 300) Time (in seconds) after a scaling activity completes before another scaling activity can start."
  type        = number
  default     = 300

}
variable "health_check_grace_period" {
  description = "(Optional, Default: 300) Time (in seconds) after instance comes into service before checking health."
  type        = number
  default     = 300
}

variable "health_check_type" {
  description = "(Optional) \"EC2\" or \"ELB\". Controls how health checking is done."
  default     = "EC2"
}

variable "force_delete" {
  description = "(Optional) Allows deleting the autoscaling group without waiting for all instances in the pool to terminate. You can force an autoscaling group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling."
  type        = bool
  default     = false
}

variable "high_cpu_threshold" {
  description = "The threshold for CPUusage metric to define it is high (%). Default: 80%"
  default     = 80
}

variable "low_cpu_threshold" {
  description = "The threshold for CPUusage metric to define it is low (%). Default: 10%"
  default     = 10
}

variable "sns_topic_arn" {
  description = "(Optional)SNS Topic ARN to send notification. If no SNS Topic ARN was provided, please specify sns_topic_name to create new one"
  default     = ""
  type        = string
}

variable "sns_topic_name" {
  description = "SNS Topic name to send notification"
  type        = string
}

variable "emails" {
  description = "List of email addresses to be retrieved notification, seperated by space"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS LOAD BALANCER
# ---------------------------------------------------------------------------------------------------------------------

variable "subnets" {
  description = "A list of subnet id to launch load balancer"
  type        = list(string)
}

variable "lb_ingress" {
  type        = list(object({
                from_port = number
                to_port = number
                protocol = string
                cidr_blocks = list(string)
              }))
  description = "Ingress rule for security group of the load balancer"
}

variable "lb_egress" {
  type        = list(object({
                from_port = number
                to_port = number
                protocol = string
                cidr_blocks = list(string)
              }))
  description = "Egress rule for security group of the load balancer"
}


