# AWS конфигурация
aws_region   = "eu-central-1"
project_name = "lab6-project"

# Сетевая конфигурация
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# EC2 конфигурация
instance_type = "t3.micro"

# Auto Scaling конфигурация
min_size         = 2
max_size         = 4
desired_capacity = 2
cpu_target_value = 50

# Безопасность - ОБЯЗАТЕЛЬНО УКАЖИТЕ ВАШ IP!
# Узнать можно командой: curl ifconfig.me
my_ip = "188.237.179.186/32"  # Замените на ваш IP адрес