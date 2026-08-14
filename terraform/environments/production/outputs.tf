################################################################################
# Oracle Database
################################################################################

output "database_private_ip" {

  description = "Oracle Database Private IP"

  value = aws_instance.tinacloud_db01.private_ip

}

output "database_instance_id" {

  description = "Oracle Database Instance ID"

  value = aws_instance.tinacloud_db01.id

}

################################################################################
# Oracle WebLogic
################################################################################

output "application_private_ip" {

  description = "Oracle WebLogic Private IP"

  value = aws_instance.tinacloud_app01.private_ip

}

output "application_instance_id" {

  description = "Oracle WebLogic Instance ID"

  value = aws_instance.tinacloud_app01.id

}