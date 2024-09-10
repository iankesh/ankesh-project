resource "aws_vpc" "vpc" {
   cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1"
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1"
}

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1"
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rta1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "public_rta2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow inbound traffic to instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Allows inbound traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

resource "aws_lb_listener" "lb_lsn" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "lb_tga1" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.public_ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my-aws-alb2" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.public_ec2_2.id
  port             = 80
}

resource "aws_instance" "public_ec2_1" {
  ami                         = "ami-08e2d37b6a0129927"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet1.id
  security_groups             = [aws_security_group.sg.id]

}

resource "aws_instance" "public_ec2_2" {
  ami                         = "ami-08e2d37b6a0129927"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet2.id
  security_groups             = [aws_security_group.sg.id]
    
}

resource "aws_db_instance" "db_ec_1" {
  allocated_storage      = 10
  db_name                = "my_private_db"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "devsecfinops"
  password               = "Passw0rd121"
  parameter_group_name   = "default.mysql5.7"
  db_subnet_group_name   = "db_sub_grp"
  vpc_security_group_ids = [aws_security_group.sg.id]
  skip_final_snapshot    = true
}

resource "aws_instance" "public_ec2_3" {
  ami                         = "ami-08e2d37b6a0129927"
  instance_type               = "g6.48xlarge"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet2.id
  security_groups             = [aws_security_group.sg.id]

}







