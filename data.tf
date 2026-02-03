##Declaramos infraestructura ya existente de la cuenta de AWS##
##En la VPC por default, hay varias subredes. Cada una tiene una AZ diferente##
##Para éste TP utilizamos valores por defecto. Sin especificar una subred o az en particular##

##Se obtiene la vpc por default##
data "aws_vpc" "default" {
  default = true
}
##Se obtienen las subnets cuyo vpc-id sea igual al ID de la VPC default que encontró antes terraform##
##Esto se lee asi: del segmento data.aws_vpc que se llama default dame el atributo id##
##Básicamente devuelve el listado de subnets filtrando por la vpc por default##
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
##Se obtienen las AZ cuyo estado sea "available"
data "aws_availability_zones" "available" {
  state = "available"
}