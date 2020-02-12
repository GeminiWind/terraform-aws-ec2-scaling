output "private_key" {
  value     = "${tls_private_key.privkey.private_key_pem}"
  description = "Public key to connect your EC2 instances"
  sensitive = true
}

output "lb_dns" {
  value ="${aws_lb.alb.dns_name}"
  description = "DNS of Application Load Balancer"
}