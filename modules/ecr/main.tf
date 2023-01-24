variable "environment" {
  type    = string
  default = "local"
}

resource "aws_ecrpublic_repository" "bebop_ecr" {

  repository_name = "bebop-ecr-${var.environment}"

  catalog_data {
    about_text        = "Public container registry for Bebop"
    architectures     = ["ARM 64"]
    description       = "Public container registry for Bebop"
    operating_systems = ["Linux"]
  }

  tags = {
    name        = "bebop-tfstate-${var.environment}"
    app         = "bebop"
    environment = var.environment
    repository  = "github.com/crerwin/bebop-tf"
  }
}
