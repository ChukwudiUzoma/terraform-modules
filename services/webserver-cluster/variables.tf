# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  type = string
  description = "The name to use for all the cluster resources "
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type eg t2.micro, m4.large depending on env necessity"

}

variable "min_size" {
  type        = number
  description = "The minimum number of EC2 instances in the Auto Scaling Group, ASG"
}

variable "max_size" {
  type        = number
  description = "The maximum number of EC2 instances in the Auto Scaling Group, ASG"
} 

variable "server_port" {
  default = 8080
  type    = number
  description = "The server port used by the web server for http connection"
}

variable "elb_port" {
  default = 80
  type    = number
  description = "The port the ELB will use for HTTP requests"
}
