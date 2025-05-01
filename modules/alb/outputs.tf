
output "arn" {
  value       = aws_alb.alb.arn
  description = "elb arn"
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_alb.alb.dns_name
}

output "magento_tg_arn" {
  value       = aws_alb_target_group.magento.arn
  description = "elb arn"
}


output "name" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_alb.alb.name
}

#output "zone_id" {
 # description = "The zone_id of the load balancer."
  #value       = aws_alb.alb.zone_id
#}
#output "web_tg_arn" {
#  value = aws_lb_target_group.web_tg.arn
#}

