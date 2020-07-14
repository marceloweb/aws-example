provider "aws" {
  profile = "default"
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami                         = "ami-085925f297f89fce1"
  instance_type               = "t2.micro"
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["sg-00456591112e2ae54"]
  subnet_id = "subnet-045efcd1957a19688"
  key_name = "test_aws"

  tags = {
      Name = var.master-name
      Environment = "Dev"
      Customer = "Trainning"
  }
  
  connection {
    type = "ssh"
	host   = self.public_ip
	user   = "ubuntu"
	private_key = file("~/.ssh/test_aws.pem")
  }
  
  
  provisioner "remote-exec" {
	inline = [
	  "sudo apt-get update -y && sudo apt-get install nginx -y && sudo service nginx start"
	]
  }
  
}
