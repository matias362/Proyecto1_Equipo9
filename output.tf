output "ec2_public_ip" {
  description = "IP pública de la EC2 donde corre la app"
  value       = aws_instance.app.public_ip
}
