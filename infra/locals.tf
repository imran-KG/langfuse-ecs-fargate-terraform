locals {
  create_vpc = var.vpc_id == null

  vpc_id                 = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  public_subnet_ids      = var.public_subnet_ids != null ? var.public_subnet_ids : module.vpc[0].public_subnet_ids
  private_subnet_ids     = var.private_subnet_ids != null ? var.private_subnet_ids : module.vpc[0].private_subnet_ids
  private_route_table_id = local.create_vpc ? module.vpc[0].private_route_table_id : null

  langfuse_web_image    = "${module.ecr.web_url}:${var.langfuse_web_image_tag}"
  langfuse_worker_image = "${module.ecr.worker_url}:${var.langfuse_worker_image_tag}"
  clickhouse_image      = "${module.ecr.clickhouse_url}:${var.clickhouse_image_tag}"
}
