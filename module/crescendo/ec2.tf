resource "aws_instance" "ec2" {
  ami                       = data.aws_ami.ubuntu_24_04_lts.id
  instance_type             = var.instance_type
  vpc_security_group_ids    = [ aws_security_group.private.id ]
  ebs_optimized             = true
  key_name                  = aws_key_pair.keypair.key_name
  disable_api_termination   = true
  subnet_id                 = aws_subnet.private_subnet[0].id

   root_block_device {
       delete_on_termination = true
       volume_type           = "gp3"
       volume_size           = 20
   
       tags ={
           Name        = "${var.project-name}-EBS"
           Environment = var.tags_env
           Manage      = var.tags_manage
       }
     }

  tags = {
    Name            = "${var.project-name}-EC2"
    Environment     = var.tags_env
    Manage          = var.tags_manage

  }

  user_data = <<-EOF
                #!/bin/bash
                # Update and install Nginx
                apt-get update -y
                apt-get install -y nginx
                systemctl start nginx
                systemctl enable nginx

                # Install Java for Tomcat
                apt-get install -y default-jdk

                # Download and Install Tomcat
                wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.58/bin/apache-tomcat-9.0.58.tar.gz -P /tmp
                tar -xvf /tmp/apache-tomcat-9.0.58.tar.gz -C /opt
                mv /opt/apache-tomcat-9.0.58 /opt/tomcat

                # Start Tomcat
                /opt/tomcat/bin/startup.sh


                # Enable Tomcat on reboot
                cat <<'EOF2' > /etc/systemd/system/tomcat.service
                [Unit]
                Description=Apache Tomcat Web Application Container
                After=network.target

                [Service]
                Type=forking

                ExecStart=/opt/tomcat/bin/startup.sh
                ExecStop=/opt/tomcat/bin/shutdown.sh

                User=root
                Group=root

                [Install]
                WantedBy=multi-user.target
                EOF2

                systemctl daemon-reload
                systemctl enable tomcat
                systemctl start tomcat
              EOF
}

resource "aws_key_pair" "keypair" {
  key_name   = var.project-name
  public_key = var.pubkey

  tags = {
    Name        = "${var.project-name}-keypair"
    Manage      = var.tags_manage
    Environment = var.tags_env
      }
}