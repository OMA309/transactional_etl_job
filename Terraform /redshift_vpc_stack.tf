resource "aws_vpc" "b2c_redshift_vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "b2c_public_subnet_1" {
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "eu-north-1a"
  vpc_id                  = aws_vpc.b2c_redshift_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "b2c_tranx__public_subnet_1"
  }
}

resource "aws_subnet" "b2c_public_subnet_2" {
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "eu-north-1b"
  vpc_id                  = aws_vpc.b2c_redshift_vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name = "b2c_tranx_public_subnet_2"
  }
}

resource "aws_internet_gateway" "b2c-redshift-igw" {
  vpc_id = aws_vpc.b2c_redshift_vpc.id

  tags = {
    Name = "b2c_tranx_redshift_igw"
  }
}

resource "aws_route_table" "b2c_redshift_rt" {
  vpc_id = aws_vpc.b2c_redshift_vpc.id

  tags = {
    Name = "b2c_tranx_redshift_rt"
  }
}

resource "aws_route" "b2c_redshift_route" {
  route_table_id         = aws_route_table.b2c_redshift_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.b2c-redshift-igw.id
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.b2c_public_subnet_1.id
  route_table_id = aws_route_table.b2c_redshift_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.b2c_public_subnet_2.id
  route_table_id = aws_route_table.b2c_redshift_rt.id
}

resource "aws_redshift_subnet_group" "b2c_tranx_subnet_group" {
  name = "b2c-tranx-subnet-group"
  subnet_ids = [
    aws_subnet.b2c_public_subnet_1.id,
    aws_subnet.b2c_public_subnet_2.id
  ]
}

resource "aws_iam_role" "b2c_redshift_role" {
  name = "b2c_tranx_redshift_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "b2c_redshift_policy" {
  name = "the_redshift_b2c_tranx_policy"
  role = aws_iam_role.b2c_redshift_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
            "arn:aws:s3:::b2c-transactional-records/*",
            "arn:aws:s3:::b2c-transactional-records/transactional-records/*",
            "arn:aws:s3:::b2c-transactional-records/api-to-redshift/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = "arn:aws:s3:::b2c-transactional-records"
      }
    ]
  })
}




resource "random_password" "mypassword" {
  length  = 10
  special = false
}


resource "aws_ssm_parameter" "redshift_database_password" {
  name  = "redshift_database_password"
  type  = "String"
  value = random_password.mypassword.result
}

resource "aws_security_group" "b2c_tranx_redshift_SG" {
  name        = "allow_traffic"
  description = "Allow inbound traffic and outbound"
  vpc_id      = aws_vpc.b2c_redshift_vpc.id

  tags = {
    Name = "b2c_tranx_redshift_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  security_group_id = aws_security_group.b2c_tranx_redshift_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5439
  to_port           = 5439
  ip_protocol       = "tcp"
  
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.b2c_tranx_redshift_SG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports,allow all types of ip-protocol
}


resource "aws_redshift_cluster" "b2c_tranx_redshift_cluster" {
  cluster_identifier        = "redshift-cluster"
  database_name             = "b2c_tranx_database"
  master_username           = "botafli"
  master_password           = aws_ssm_parameter.redshift_database_password.value
  node_type                 = "ra3.large"
  cluster_type              = "multi-node"
  iam_roles                 = [aws_iam_role.b2c_redshift_role.arn]
  number_of_nodes           = 2
  publicly_accessible       = true
  cluster_subnet_group_name = aws_redshift_subnet_group.b2c_tranx_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.b2c_tranx_redshift_SG.id]

  tags = {
    Name = "b2c_tranx_redshift_cluster"
  }
}







