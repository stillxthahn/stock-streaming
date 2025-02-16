data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"] # Ubuntu Server 22.04 LTS (HVM)
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_security_group" "database-sg" {
  name   = "database-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "client-sg" {
  name   = "client-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "debezium-sg" {
  name   = "debezium-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "spark-sg" {
  name   = "spark-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "client_accept_database" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.client-sg.id
  referenced_security_group_id = aws_security_group.database-sg.id
}

resource "aws_vpc_security_group_egress_rule" "client_to_database" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.client-sg.id
  referenced_security_group_id = aws_security_group.database-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "database_accept_client" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.database-sg.id
  referenced_security_group_id = aws_security_group.client-sg.id
}

resource "aws_vpc_security_group_egress_rule" "database_to_client" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.database-sg.id
  referenced_security_group_id = aws_security_group.client-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "database_accept_debezium" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.database-sg.id
  referenced_security_group_id = aws_security_group.debezium-sg.id
}

resource "aws_vpc_security_group_egress_rule" "database_to_debezium" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.database-sg.id
  referenced_security_group_id = aws_security_group.debezium-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "debezium_accept_database" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.debezium-sg.id
  referenced_security_group_id = aws_security_group.database-sg.id
}

resource "aws_vpc_security_group_egress_rule" "debezium_to_database" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.debezium-sg.id
  referenced_security_group_id = aws_security_group.database-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "debezium_accept_spark" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.debezium-sg.id
  referenced_security_group_id = aws_security_group.spark-sg.id
}

resource "aws_vpc_security_group_egress_rule" "debezium_to_spark" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.debezium-sg.id
  referenced_security_group_id = aws_security_group.spark-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "spark_accept_debezium" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.spark-sg.id
  referenced_security_group_id = aws_security_group.debezium-sg.id
}

resource "aws_vpc_security_group_egress_rule" "spark_to_debezium" {
  ip_protocol                  = "-1"
  security_group_id            = aws_security_group.spark-sg.id
  referenced_security_group_id = aws_security_group.debezium-sg.id
}


// DATABASE INSTANCE
resource "aws_instance" "database" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.database-sg.id]
  user_data              = file("user-data/database_user_data.sh")

  tags = {
    Name = "${var.name}-database"
  }
}

// CLIENT INSTANCE
resource "aws_instance" "client" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.client-sg.id]

  user_data = templatefile("user-data/client_user_data.sh.tpl", {
    MYSQL_HOST = aws_instance.database.private_ip
  })
  tags = {
    Name = "${var.name}-client"
  }
}

// DEBEZIUM - KAFKA INSTANCE
resource "aws_instance" "debezium" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.debezium-sg.id]

  user_data = templatefile("user-data/debezium_user_data.sh.tpl", {
    MYSQL_HOST = aws_instance.database.private_ip
  })

  tags = {
    Name = "${var.name}-debezium"
  }
}

// SPARK INSTANCE
resource "aws_instance" "spark" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.spark-sg.id]

  user_data = templatefile("user-data/spark_user_data.sh.tpl", {
    KAFKA_BROKERS         = "${aws_instance.debezium.private_ip}:9092"
    KAFKA_TOPICS          = "dbserver1.STOCK_STREAMING.IBM_STOCK"
    REGION                = var.region
    AWS_ACCESS_KEY_ID     = var.access_key
    AWS_SECRET_ACCESS_KEY = var.secret_key
    S3_ENDPOINT           = var.s3_stock_bucket_endpoint
    S3_BUCKET             = var.s3_stock_bucket
    S3_FOLDER             = var.s3_stock_folder
  })


  tags = {
    Name = "${var.name}-spark"
  }
}


