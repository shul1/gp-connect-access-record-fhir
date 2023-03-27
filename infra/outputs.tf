output "zone_domain" {
  value = aws_route53_zone.project_zone.name
}

output "vpc_id" {
  value = local.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets[*].subnet_id
}

output "private_subnet_ids" {
  value = module.private_subnets[*].subnet_id
}

output "fargate_subnet_ids" {
  value = module.private_subnets[*].subnet_id
}

output "vpc_link_id" {
  value = aws_apigatewayv2_vpc_link.alb_vpc_link.id
}

output "validation_ecr_name" {
    value = aws_ecr_repository.lambda_image_registry.name
}

output "validation_ecr_url" {
    value = aws_ecr_repository.lambda_image_registry.repository_url
}
