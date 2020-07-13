
resource "aws_lb_listener" "nlb-listener" {
  load_balancer_arn = "${aws_lb.nlb-storage.arn}"
  port              = "445"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.nlb-target-group.arn}"
  }
}
resource "aws_lb_target_group_attachment" "storage-tg-attachment" {
  target_group_arn = "${aws_lb_target_group.nlb-target-group.arn}"
  target_id        = "${aws_instance.storage-master.private_ip}" 
  port             = 445
}
resource "aws_lb_target_group_attachment" "storage-tg-attachment-slave" {
  target_group_arn = "${aws_lb_target_group.nlb-target-group.arn}"
  target_id        = "${aws_instance.storage-slave.private_ip}" 
  port             = 445
}
resource "aws_route53_record" "storage-pepsico" {
  zone_id = "/hostedzone/Z38N2ATLLA5KZ6"
  name    = "${var.route-name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.nlb-storage.dns_name}"]
}
