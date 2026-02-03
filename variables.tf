variable aws_region {
  type        = string
  description = "Region AWS"
}
variable "ami_id" {
  description = "El ID de la AMI a usar"
  type        = string
}
variable "instance_type" {
  description = "Tipo de instancia a usar"
  type        = string
}
variable "key_name" {
  description = "Llave publica para acceder a la instancia"
  type        = string
}
variable "aws_account_id" {
  description = "ID de cuenta de AWS"
  type        = string
}
variable "ecr_repository" {
  description = "Nombre repositorio ECR"
  type        = string
}