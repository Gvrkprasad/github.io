data "aws_vpc" "Default_vpc" {}

data "aws_availability_zones" "name" {
  state = "available"
}

data "aws_subnet" "default_subnet" {
    count = 2
  vpc_id = data.aws_vpc.Default_vpc.id
  availability_zone = data.aws_availability_zones.name.names[count.index]
    
}