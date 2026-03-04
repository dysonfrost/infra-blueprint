data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical offical AWS account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "main" {
  name          = "main-lt"
  image_id      = data.aws_ami.ubuntu_24_04.id
  instance_type = "t3.micro"
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm.name
  }

  vpc_security_group_ids = [aws_security_group.ec2.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-lt"
    }
  )
}

resource "aws_autoscaling_group" "main" {
  name                      = "main-asg"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = [for subnet in aws_subnet.public : subnet.id]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.main.arn]

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${var.project_name}-asg-instance" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
