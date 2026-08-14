################################################################################
# DB01 Oracle Data Volume
################################################################################

resource "aws_ebs_volume" "oracle_data" {

  availability_zone = var.availability_zone

  size = 150

  type = "gp3"

  encrypted = true

  tags = merge(
    local.common_tags,
    {
      Name = "tinacloud-db01-data"
    }
  )

}

################################################################################
# DB01 Volume Attachment
################################################################################

resource "aws_volume_attachment" "oracle_data" {

  device_name = "/dev/sdf"

  volume_id = aws_ebs_volume.oracle_data.id

  instance_id = aws_instance.tinacloud_db01.id

}

################################################################################
# DB02 Oracle Data Volume
################################################################################

resource "aws_ebs_volume" "oracle_data_db02" {

  availability_zone = var.availability_zone

  size = 150

  type = "gp3"

  encrypted = true

  tags = merge(
    local.common_tags,
    {
      Name = "tinacloud-db02-data"
    }
  )

}

################################################################################
# DB02 Volume Attachment
################################################################################

resource "aws_volume_attachment" "oracle_data_db02" {

  device_name = "/dev/sdf"

  volume_id = aws_ebs_volume.oracle_data_db02.id

  instance_id = aws_instance.tinacloud_db02.id

}