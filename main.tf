terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28"
    }
  }

  backend "s3" {}
}

resource "aws_instance" "instance_1" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instances.id]
  user_data       = <<-EOF
              #!/bin/bash
              mkdir -p /opt/webapp
              echo "Hello, World!" > /opt/webapp/index.html
              cd /opt/webapp
              nohup python3 -m http.server 8080 > /var/log/webapp.log 2>&1 &
              EOF

  tags = {
    Name = "ExampleInstance1"
  }
}

resource "aws_instance" "instance_2" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instances.id]
  user_data       = <<-EOF
              #!/bin/bash
              mkdir -p /opt/webapp
              echo "Hello, World!" > /opt/webapp/index.html
              cd /opt/webapp
              nohup python3 -m http.server 8080 > /var/log/webapp.log 2>&1 &
              EOF

  tags = {
    Name = "ExampleInstance2"
  }
}

resource "aws_s3_bucket" "example" {
  bucket        = var.app_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instances" {
  name = "instances-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = aws_security_group.instances.id
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "instances" {
  name     = "example-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

resource "aws_lb_listener_rule" "instance" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound_alb" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_http_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb" "application_load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_security_group" "rds" {
  name = "rds-security-group"
}

resource "aws_security_group_rule" "allow_postgres_inbound" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instances.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  storage_type           = "standard"
  engine                 = "postgres"
  engine_version         = "16"
  instance_class         = "db.t2.micro"
  identifier             = var.db_name
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
}
