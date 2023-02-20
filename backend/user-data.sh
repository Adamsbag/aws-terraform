#!/bin/bash

# update the system
sudo yum update -y

#Install JQ to retreive the Secret value from json format
sudo yum install jq -y

# import RDS credentials from AWS Secrets Manager
secret=$(aws secretsmanager get-secret-value --secret-id "main/rds/password" --region "us-east-1")
username=$(echo $secret | jq -r .SecretString | jq -r .username)
password=$(echo $secret | jq -r .SecretString | jq -r .password)
name=$(echo $secret | jq -r .SecretString | jq -r .name)
endpoint=$(terraform output rds_endpoint)

# install Apache
sudo yum install httpd -y

# install PHP
sudo amazon-linux-extras install php8.1 -y

# start Apache
sudo systemctl start httpd

# enable Apache to start on boot
sudo systemctl enable httpd

# Install MariaDB
sudo yum install mariadb-server mariadb -y

# start MariaDB
sudo systemctl start mariadb

# enable MariaDB to start on boot
sudo systemctl enable mariadb

# download the latest version of WordPress
curl -O https://wordpress.org/latest.tar.gz

# extract the downloaded file
tar xzvf latest.tar.gz

# move the files to the Apache document root
sudo mv wordpress/* /var/www/html

# set the correct permissions on the WordPress files
sudo chown -R apache:apache /var/www/html

# navigate to the WordPress directory
cd /var/www/html

# copy the sample configuration file
sudo cp wp-config-sample.php wp-config.php

# update the configuration with the RDS endpoint and credentials
sed -i "s/database_name_here/$name/g" wp-config.php
sed -i "s/username_here/$username/g" wp-config.php
sed -i "s/password_here/$password/g" wp-config.php
sed -i "s/localhost/$endpoint/g" wp-config.php

# restart Apache
sudo systemctl restart httpd
