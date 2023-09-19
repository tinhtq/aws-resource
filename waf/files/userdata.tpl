#!/bin/bash
sudo su
yum update -y
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<html><h1> Welcome to Whizlabs Server ${number} </h1><html>" >> /var/www/html/index.html
