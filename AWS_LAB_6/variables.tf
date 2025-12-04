variable "aws_region" {
  description = "AWS регион для развертывания"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Название проекта"
  type        = string
  default     = "lab6-project"
}

variable "vpc_cidr" {
  description = "CIDR блок для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR блоки для публичных подсетей"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR блоки для приватных подсетей"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Зоны доступности"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "Тип EC2 инстанса"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "Минимальное количество инстансов в ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Максимальное количество инстансов в ASG"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Желаемое количество инстансов в ASG"
  type        = number
  default     = 2
}

variable "cpu_target_value" {
  description = "Целевое значение CPU для auto scaling (в процентах)"
  type        = number
  default     = 50
}

variable "your_ip" {
  description = "Ваш IP адрес для SSH доступа (формат: x.x.x.x/32)"
  type        = string
  # Замените на ваш IP или используйте terraform.tfvars
}