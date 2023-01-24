variable "environment" {
  type    = string
  default = "local"
}

resource "aws_ecrpublic_repository" "bebop_ecr" {

  repository_name = "bebop"

  catalog_data {
    about_text        = "Public container registry for Bebop"
    architectures     = ["ARM 64"]
    description       = "Public container registry for Bebop"
    operating_systems = ["Linux"]
  }

  tags = {
    name        = "bebop-ecr-${var.environment}"
    app         = "bebop"
    environment = var.environment
    repository  = "github.com/crerwin/bebop-tf"
  }
}

output "ecr_arn" {
  value = aws_ecrpublic_repository.bebop_ecr.arn
}
