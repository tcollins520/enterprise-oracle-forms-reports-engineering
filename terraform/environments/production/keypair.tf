################################################################################
# SSH Key Pair
################################################################################

resource "aws_key_pair" "tinacloud_bastion" {

  key_name = "tinacloud-bastion"

  public_key = file("C:/Users/Administrator/.ssh/tinacloud-bastion.pub")

}