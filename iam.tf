##Para que la instancia ec2 que vamos a crear, pueda hacer un pull a la imagen subida a ECR de manera nativa se precisa un instance profile con un rol especifico##
##Las instancias ec2 no consumen roles directamente,sino a través de un instance profile. Es como que asumen un permiso especifico para una accion determinada##
##La jerarquia es asi: ec2 -> instance profile -> rol -> policy##

##Aca vamos a definir un rol que indica que las ec2 pueden asumir roles##
resource "aws_iam_role" "ec2_role" {
  name = "proyecto1-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
##Creamos la policy custom que sólo permite el pull de ECR##
resource "aws_iam_policy" "ecr_pull_policy" {
  name = "proyecto1-ecr-pull-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "*"
      }
    ]
  })
}
##Atachamos el rol a la policy##
resource "aws_iam_role_policy_attachment" "attach_ecr_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
}
##Se crea instance profile. Esto es lo que se asocia cuando se cree la instancia ec2##
##Para que la instancia ec2 pueda asumir el rol de hacer un pull de una imagen de ECR, se precisan éstas definiciones##
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "proyecto1-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

