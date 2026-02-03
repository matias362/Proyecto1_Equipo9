##Seguir viendo ésto. Falta definir el data para la ami, agregar las variables que faltan, configurar la key_name y ver el tema del Dockerfile

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              aws ecr get-login-password --region ${var.aws_region} \
              | docker login --username AWS \
              --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

              docker pull ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:latest

              docker run -d \
                -p 3000:3000 \
                -p 9090:9090 \
                -p 3001:3001 \
                ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:latest
              EOF

  tags = {
    Name = "proyecto1-ec2-app"
  }
}
