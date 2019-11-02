
############# RESOURCE: AWS EC2  INSTANCE 
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
	      #!/bin/bash
	      echo "<h1>Chudo: Hello, Autentia. It is Chudo here.</h1>" >> index.html
              echo "<h2>Autentia: Hello, Chudo. We see you.</h2>" >> index.html
              nohup busybox httpd -f -p  8080 &
              EOF

  tags = {
    Name = var.cluster_name

  }
}

############ RESOURCE: AWS LAUNCH CONFIGURATION
resource "aws_launch_configuration" "example" {
  image_id      = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]


  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>Chudo: Hello, Autentia. It is Chudo here.</h1>" >> index.html
              echo "<h2>Autentia: Hello, Chudo. We see you.</h2>" >> index.html
              nohup busybox httpd -f -p  8080 &
              EOF

  lifecycle{
    create_before_destroy = true
  }
}

############ RESOURCE: AWS SECURITY GROUP INSTANCE (ASG)
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############ RESOURCE: AWS AUTO SCALING GROUP (ASG)
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.id
  availability_zones = data.aws_availability_zones.all.names
  min_size = var.min_size
  max_size = var.max_size
  load_balancers = [aws_elb.example.name] # using the load_balancers parameter of the aws_autoscaling_group resource to tell the ASG to register each Instance in the CLB
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg-group"
    propagate_at_launch = true
  }
}

############ RESOURCE: AWS ELASTIC CLASSIC LOAD BALANCER (CLB)
resource "aws_elb" "example" {
  name                = "${var.cluster_name}-asg-group"
  security_groups    = [aws_security_group.elb.id]
  availability_zones  = data.aws_availability_zones.all.names

   #checks for health of target url of each of the EC2 Instances and only mark an Instance as healthy if it responds with a 200 OK
   health_check {
    target             = "HTTP:${var.server_port}/"
    interval            = 30 #30 seconds
    timeout             = 3 # The length of time before the check times out.
    healthy_threshold   = 2 #The number of checks before the instance is declared healthy.
    unhealthy_threshold = 2
  }
  #this adds the listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

############ RESOURCE: AWS CLB SECURITY GROUP 
resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-elb"

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 ############ DATA SOURCES
data "aws_availability_zones" "all" {}
