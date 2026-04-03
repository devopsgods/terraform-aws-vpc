locals {
    common_tags = {
    project = var.project
    enviornment= var.enviornment
    terraform = "true"
}
vpc_final_tags = merge(
    local.common_tags,
    {
         Name = "${var.project}-${var.enviornment}"
    },
    var.vpc_tags
  )

  igw_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}"
    }
  )
  
  igw_tags = var.igw_tags
  
  
    az_names = slice(data_aws_availability_zones.available.names, 0,2)
    public_subnet_tags
      
}