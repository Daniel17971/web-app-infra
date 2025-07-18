resource "aws_instance" "web" {
  count = length(var.private_subnet_ids)
  ami             = var.ami_id # Amazon Linux 2 (example, pick your region)
  instance_type   = var.instance_type
  subnet_id       = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = var.user_data
  tags = {
    Name = "${var.name_prefix}-web-${count.index + 1}"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.name_prefix}-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id] # Only ALB can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ec2-sg"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  count            = length(aws_instance.web)
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}