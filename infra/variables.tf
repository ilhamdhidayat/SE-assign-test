variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "app_name" {
  default = "demo-api"
  type    = string
}

# Database password used by the application.
variable "db_password" {
  type    = string
}

variable "image_tag" {
  default = "latest"
  type    = string
}
