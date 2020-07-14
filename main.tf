provider "aws" {
  profile = "default"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "xpto-terraform-example"
    key            = "example-s3"
    region         = "us-east-1"
  }
}

# Criação da instancia - Master
resource "aws_instance" "storage-master" {
  ami                         = "ami-0bd01eb1d7433538b"
  instance_type               = "t2.micro"
  key_name                    = "mdcs-docker"
  disable_api_termination = "true"
  ebs_optimized               = "false"
  availability_zone = "us-east-1a"
  associate_public_ip_address = "false"
  vpc_security_group_ids = ["sg-0e420d113bbdcd40a"]
  subnet_id = ""


  tags = {
      Name = var.master-name
      Terraform = "sim"
      Type-Storage = "master"
      Environment = "PD"
      Customer = "Example"
  }
}

# cria instancia slave
resource "aws_instance" "storage-slave" {
  ami                         = "ami-0fd035f0b10426dcf"
  instance_type               = "t2.micro"
  key_name                    = "mdcs-docker"
  disable_api_termination = "true"
  ebs_optimized               = "false"
  availability_zone  = "us-east-1b"
  associate_public_ip_address = "false"
  vpc_security_group_ids = ["sg-0e420d113bbdcd40a"]
  subnet_id = "" 

  tags = {
      Name = "${var.slave-name}"
      Terraform = "sim"
      Type-Storage = "slave"
      Environment = "PD"
      Customer = "Example"
  }
}

resource "aws_lb" "nlb-storage" {
  name               = var.nlb-name
  internal           = true
  load_balancer_type = "network"
  subnets            = ["subnet", ""]

  enable_deletion_protection = true

  tags = {
    Environment = "PD"
    Name = var.nlb-name
    Customer = "Example"
  }
}

resource "aws_lb_target_group" "nlb-target-group" {
  name     = var.tg-name
  port     = 445
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = "vpc"

  health_check {
    protocol = "TCP"
    port = 445
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
  }
}

resource "aws_lb_listener" "nlb-listener" {
  load_balancer_arn = aws-lb.nlb-storage.arn
  port              = "445"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "storage-tg-attachment" {
  target_group_arn = aws_lb_target_group.nlb-target-group.arn
  target_id        = aws_instance.storage-master.private_ip 
  port             = 445
}

resource "aws_lb_target_group_attachment" "storage-tg-attachment-slave" {
  target_group_arn = aws_lb_target_group.nlb-target-group.arn
  target_id        = aws_instance.storage-slave.private_ip 
  port             = 445
}

resource "aws_route53_record" "storage-example" {
  zone_id = "/hostedzone/"
  name    = var.route-name
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.nlb-storage.dns_name]
}
