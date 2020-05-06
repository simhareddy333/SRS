/* Terraform code for Creating teh Docker Swarm Cluster */

provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region      = "${var.region}"
}
resource "aws_instance" "manager" {
  ami           = "ami-26c43149"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.name}"]
  key_name = "${aws_key_pair.deployer.key_name}"
  connection {
    user = "ubuntu"
    key_file = "ssh/key"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https ca-certificates",
      "sudo apt-get update",
      "sudo apt-get install -y docker-engine=1.12.0",
      "sudo docker swarm init",
      "sudo docker swarm join-token --quiet worker > /home/ubuntu/token"
    ]
  }
  provisioner "file" {
    source = "proj"
    destination = "/home/ubuntu/"
  }
  tags = { 
    Name = "swarm-manager"
  }
}

resource "aws_instance" "node" {
  count         = 4
  ami           = "ami-26c43149"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.swarm.name}"]
  key_name = "${aws_key_pair.deployer.key_name}"
  connection {
    user = "ubuntu"
    key_file = "ssh/key"
  }
  provisioner "file" {
    source = "key.pem"
    destination = "/home/ubuntu/key.pem"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apt-transport-https ca-certificates",
      "sudo apt-get update",
      "sudo apt-get install -y docker-engine",
      "sudo chmod 400 /home/ubuntu/test.pem",
      "sudo scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i test.pem ubuntu@${aws_instance.master.private_ip}:/home/ubuntu/token .",
      "sudo docker swarm join --token $(cat /home/ubuntu/token) ${aws_instance.master.private_ip}:2377"
    ]
  }
  tags = { 
    Name = "swarm-${count.index}"  /* will be using variable to sequence the nodes as node1,node2...etc */
  }
}

