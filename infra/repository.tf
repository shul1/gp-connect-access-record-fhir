resource "aws_ecr_repository" "mock_provider_registry" {
  name = local.prefix
}

resource "aws_ecr_repository" "lambda_image_registry" {
  name = local.validation_ecr_name
}
