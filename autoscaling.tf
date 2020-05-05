resource "aws_launch_template" "SRSLC" {
  name_prefix   = "SRSLC"
  image_id      = "ami-1a2b3c"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_policy" "UP" {
  name                   = "terraform-test"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 100
  autoscaling_group_name = "${aws_autoscaling_group.SRSASG.name}"
}

resource "aws_autoscaling_group" "SRSASG" {
  availability_zones        = ["us-east-1a"]
  name                      = "terraform-test"
  max_size                  = 1
  min_size                  = 1
  desired_capacity   		= 1
  health_check_grace_period = 100
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.SRSLC.name}"
}
