locals {
    common_tags = {
    project = var.project
    enviornment= var.enviornment
    terraform = "true"
}
vpc_fianl_tags = merge{
    local.common_tags,
    {
         Name = "${var.project}-${var.environment}"
    },
    var.vpc_tags
  }
}