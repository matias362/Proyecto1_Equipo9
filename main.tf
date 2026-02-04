##Alta de instancia EC2 + Pull imagen docker desde ECR + Docker Run de imagen##

resource "aws_instance" "app" {
  ami                         = var.ami_id ##variable de la Ami que vamos a usar.. compatible con free tier##
  instance_type               = var.instance_type ##variable del tipo de instancia que vamos a usar.. compatible con free tier##
  subnet_id                   = data.aws_subnets.default.ids[0] ##Esto te da el primer valor del atributo id sacado del segmento data que devuvelve las subnets##
  vpc_security_group_ids      = [aws_security_group.app_sg.id] ##Asocia la sg generada en el network.tf##
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name ##La instancia ec2 se va a crear con el instance profile que tiene el rol para hacer pull a ECR##
  key_name                    = var.key_name ##par de claves para luego conectarse por ssh##
  associate_public_ip_address = true
  ##Segmento donde se define un input como si fuera un usuario. Instala docker y deja corriendo la imagen de ECR##
  ##Los comandos que se pasan luego del sleep, son como si el usuario administrador del servidor configurara la cli de aws e hiciera el pull manualmente##
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              sleep 30

              aws ecr get-login-password --region ${var.aws_region} \
              | docker login --username AWS \
              --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

              docker pull ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:latest

              docker run -d \
                --name app \
                -p 3000:3000 \
                ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repository}:latest

              sleep 30

              mkdir -p /usr/local/lib/docker/cli-plugins
              curl -SL https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64 \
              -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

              mkdir -p /opt/monitoring
              cd /opt/monitoring
                        
              cat <<EOT > prometheus.yml
              global:
                scrape_interval: 15s

              scrape_configs:
                - job_name: "node-app-health"
                  metrics_path: /health
                  static_configs:
                    - targets:
                        - localhost:3000
              EOT

              cat <<EOT > docker-compose.yml

              services:
                prometheus:
                  image: prom/prometheus:latest
                  container_name: prometheus
                  volumes:
                    - ./prometheus.yml:/etc/prometheus/prometheus.yml
                  ports:
                    - "9090:9090"

                grafana:
                  image: grafana/grafana:latest
                  container_name: grafana
                  ports:
                    - "3001:3000"
                  depends_on:
                    - prometheus
              EOT

              docker compose up -d              
            
              EOF

  tags = {
    Name = "proyecto1-ec2-app"
  }
}
