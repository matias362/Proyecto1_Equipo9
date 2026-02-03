##Seguir viendo ésto. Pensar el tema del Dockerfile

resource "aws_instance" "app" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0] ##Esto te da el primer valor del atributo id sacado del segmento data que devuvelve las subnets##
  vpc_security_group_ids      = [aws_security_group.app_sg.id] 
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name ##La instancia ec2 se va a crear con el instance profile que tiene el rol para hacer pull a ECR##
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              sleep 10

              aws ecr get-login-password --region ${var.aws_region} \
              | docker login --username AWS \
              --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

              docker pull ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:latest

              docker run -d \
                -p 3000:3000 \
                ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:latest
              EOF

  tags = {
    Name = "proyecto1-ec2-app"
  }
}
