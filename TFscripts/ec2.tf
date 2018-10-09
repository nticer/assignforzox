variable "vpc_id" {}
variable "subnet_id" {}
variable "name" {}
variable "alarms_email" {}
count=X (where X is number of instances
tags {
Name="${format("test-%01d",count.index+1)}"
}

provider "aws" {
access_key="access keys here"
secret_key="secret keys here"
region = "eu-west-1"
}

variable "count" {
default=2
}


resource "aws_instance" "Zox zssign" {
count="${var.count}"
ami = "ami-d834aba1"
instance_type = "t1.nano"
tags { Name="${format("test-%01d",count.index+1)}" }
}

provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
      timeout = "5m"
      agent = true
    }

    inline = [
      curl https://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip -O
	unzip CloudWatchMonitoringScripts-1.2.2.zip && \
	rm CloudWatchMonitoringScripts-1.2.2.zip && \
	cd aws-scripts-mon
	cp awscreds.template awscreds.conf
	echo "AWSAccessKeyId = my-access-key-id" > awscreds.conf
	echo "AWSSecretKey = my-secret-access-key" >> awscreds.conf
	crontab -l > mycron
	echo "*/5 * * * * ~/aws-scripts-mon/mon-put-instance-data.pl --mem-util --mem-used --mem-avail --aggregated=only" >> mycron
	crontab mycron
	rm mycron
    ]
  }
}

}