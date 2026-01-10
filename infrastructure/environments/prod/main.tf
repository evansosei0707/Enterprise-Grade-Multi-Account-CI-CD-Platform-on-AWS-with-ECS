#------------------------------------------------------------------------------
# Prod Environment - Module Orchestration
#------------------------------------------------------------------------------

module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project_name = var.project_name
  environment  = var.environment
}

module "iam" {
  source = "../../modules/iam"

  project_name       = var.project_name
  environment        = var.environment
  tooling_account_id = var.tooling_account_id
}

module "logging" {
  source = "../../modules/logging"

  project_name       = var.project_name
  environment        = var.environment
  log_retention_days = var.log_retention_days
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = var.vpc_id
  alb_security_group_id = var.alb_security_group_id
  container_port        = var.container_port
}

module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = var.vpc_id
  public_subnet_ids     = var.public_subnet_ids
  alb_security_group_id = var.alb_security_group_id
  container_port        = var.container_port
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

module "ecs_service" {
  source = "../../modules/ecs-service"

  project_name            = var.project_name
  environment             = var.environment
  ecs_cluster_id          = module.ecs_cluster.cluster_id
  ecs_cluster_name        = module.ecs_cluster.cluster_name
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn           = module.iam.task_role_arn
  ecr_repository_url      = var.ecr_repository_url
  image_tag               = var.image_tag
  container_port          = var.container_port
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  private_subnet_ids      = var.private_subnet_ids
  ecs_security_group_id   = module.security_groups.ecs_service_security_group_id
  target_group_arn        = module.alb.target_group_arn
  desired_count           = var.desired_count
  dynamodb_table_name     = module.dynamodb.table_name
  log_group_name          = module.logging.log_group_name
  enable_autoscaling      = var.enable_autoscaling
  min_capacity            = var.min_capacity
  max_capacity            = var.max_capacity
}
