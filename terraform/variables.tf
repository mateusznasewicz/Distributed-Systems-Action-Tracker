variable "deployment_target" {
  type        = string
  description = "Gdzie wdrażać: 'aws' lub 'local'"
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}
