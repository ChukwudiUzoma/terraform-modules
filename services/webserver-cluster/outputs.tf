 ############ OUTPUTS:

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "Public IP of this EC2 instance (The Web Server)"
}

output "clb_dns_name" {
  value       = aws_elb.example.dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.example.name
  description = "The name of the Auto Scaling Group"
}
