data "aws_subnet_ids" "web_subnets" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = [var.filter_subnet]  #public subnet
  }
}

data "aws_subnet_ids" "app_subnets" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["KPMG-test-app-subnet-*"] #private subnet
  }
}

resource "aws_launch_configuration" "web_launch" {
  name_prefix = "web-"
  image_id = var.ami_id
  instance_type = "t2.micro"
  key_name = var.key_name
  security_groups = [var.web_sg]    #A list of associated security group 

  user_data = <<-USER_DATA
#!/bin/bash
sudo -i

cat > /var/www/html/index.php <<'END'
<?php
$instance_hostname = file_get_contents("http://169.254.169.254/latest/meta-data/hostname");
echo "Hello World! coming from - $instance_hostname";
?>
END

systemctl start httpd && systemctl enable httpd
  USER_DATA

  lifecycle {
    create_before_destroy = true    #The create_before_destroy setting controls the order in which resources are recreated. The default order is to delete the old resource and then create the new one.
  }
}

resource "aws_alb_target_group" "target_group_1" {
  name = "target-group-1"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  lifecycle { create_before_destroy=true }

  health_check {
    path = "/"
    port = 80
    healthy_threshold = 6
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"
  }
}

resource "aws_alb" "web_alb" {
  name = "web-alb"
  security_groups = [var.elb_sg]
  subnets = tolist(data.aws_subnet_ids.web_subnets.ids)   #create alb in public subnet 
}

resource "aws_alb_listener" "web_alb_listener" {
  default_action {
    target_group_arn = aws_alb_target_group.target_group_1.arn
    type = "forward"
  }
  load_balancer_arn = aws_alb.web_alb.arn
  port = 80
  protocol = "HTTP"
}

resource "aws_alb_listener_rule" "rule-1" {
  action {
    target_group_arn = aws_alb_target_group.target_group_1.arn
    type = "forward"
  }

  condition {
    path_pattern {
      values=["/"]
    }
  }

  listener_arn = aws_alb_listener.web_alb_listener.id
  priority = 100
}

resource "aws_autoscaling_group" "web_alb_asg" {
  name = "web-alb-asg"
  min_size             = 2
  desired_capacity     = 2
  max_size             = 4
  launch_configuration = aws_launch_configuration.web_launch.name
  vpc_zone_identifier = tolist(data.aws_subnet_ids.web_subnets.ids)
  termination_policies = [
    "OldestInstance",
    "OldestLaunchConfiguration",
  ]

  health_check_type = "ELB"

  depends_on = [aws_alb.web_alb]

  target_group_arns = [
    aws_alb_target_group.target_group_1.arn  ]

  lifecycle {
    create_before_destroy = true
  }
}

#autoscaling policy
resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.web_alb_asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_alarm_up" {
  alarm_name = "web_connection_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "NewConnectionCount"
  namespace = "AWS/ApplicationELB"
  period = "60"
  statistic = "Average"
  threshold = "100"

  dimensions = {
    LoadBalancer = aws_alb.web_alb.arn_suffix
  }

  alarm_description = "This metric monitor ELB active connection count"
  alarm_actions = [aws_autoscaling_policy.web_policy_up.arn]
}

resource "aws_autoscaling_policy" "web_policy_down" {
  name = "web_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.web_alb_asg.name
}

resource "aws_cloudwatch_metric_alarm" "web_alarm_down" {
  alarm_name = "web_connection_alarm_down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "2"
  metric_name = "NewConnectionCount"
  namespace = "AWS/ApplicationELB"
  period = "120"
  statistic = "Average"
  threshold = "101"

  dimensions = {
    LoadBalancer = aws_alb.web_alb.arn_suffix    #found out with the use of "terraform show"
  }

  alarm_description = "This metric monitor ELB active connection count"
  alarm_actions = [aws_autoscaling_policy.web_policy_down.arn]
}
