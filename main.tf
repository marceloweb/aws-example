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
  key_name = "test_win"

  tags = {
      Name = var.master-name
      Environment = "Dev"
      Customer = "Trainning"
  }
  
  provisioner "remote-exec" {
  
    connection {
	  host 		  = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./test_win.ppk")
    }
  }
  
  provisioner "local-exec" {
    command = "apt install nginx && service nginx start"
  }
}