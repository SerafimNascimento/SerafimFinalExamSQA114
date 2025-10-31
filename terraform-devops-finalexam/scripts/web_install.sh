#!/bin/bash
set -e

dnf -y update
dnf -y install httpd

systemctl enable httpd
systemctl start httpd

echo "<h1>Web server deployed by Terraform</h1>" > /var/www/html/index.html


chown -R ec2-user:ec2-user /var/www/html
chmod -R 755 /var/www/html