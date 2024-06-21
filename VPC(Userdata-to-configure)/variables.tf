## Variables 

variable "cidr_vpc01" {
  description = "cidr block to be used by the VPC in Mumbai"
}

variable "cidr_vpc02" {
  description = "cidr block to be used by the VPC in Virginia"
}

variable "cidr_pubsub_vpc01" {
  description = "cidr block to be used by the public subnet in VPC Mumbai"
}

variable "cidr_prvsub_vpc01" {
  description = "cidr block to be used by the private subnet in VPC Mumbai"
}

variable "cidr_pubsub_vpc02" {
  description = "cidr block to be used by the public subnet in VPC Virginia"
}

variable "cidr_prvsub_vpc02" {
  description = "cidr block to be used by the private subnet in VPC Virginia"
}

variable "us-east-ami" {
  description = "AMI of the instance to be used in Virginia"
}

variable "ap-south-ami" {
  description = "AMI of the instance to be used in Mumbai"
}

variable "us-east-instance" {
  description = "Instance Type of Virginia"
}

variable "ap-south-instance" {
  description = "Instance Type of Mumbai"
}
