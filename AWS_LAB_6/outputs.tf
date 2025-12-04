output "vpc_id" {
  description = "ID созданной VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "ID публичных подсетей"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "ID приватных подсетей"
  value       = aws_subnet.private[*].id
}

output "alb_dns_name" {
  description = "DNS имя Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_url" {
  description = "URL для доступа к приложению"
  value       = "http://${aws_lb.main.dns_name}"
}

output "load_test_url" {
  description = "URL для нагрузочного тестирования"
  value       = "http://${aws_lb.main.dns_name}/load?seconds=60"
}

output "alb_zone_id" {
  description = "Zone ID Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN Target Group"
  value       = aws_lb_target_group.main.arn
}

output "autoscaling_group_name" {
  description = "Имя Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "launch_template_id" {
  description = "ID Launch Template"
  value       = aws_launch_template.main.id
}

output "cloudwatch_dashboard_url" {
  description = "URL для CloudWatch Dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "security_group_alb_id" {
  description = "ID Security Group для ALB"
  value       = aws_security_group.alb.id
}

output "security_group_web_id" {
  description = "ID Security Group для веб-серверов"
  value       = aws_security_group.web.id
}