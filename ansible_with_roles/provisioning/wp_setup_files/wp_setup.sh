#!/usr/bin/bash

setenforce 0

sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

#Setting Firewall Settings

firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent 
firewall-cmd --reload

#Installing Packages
yum -y install @core vim git epel-release tcpdump nmap-ncat curl wget
yum -y update

#nginx Setup
yum -y install nginx 
systemctl start nginx
systemctl enable nginx

yum -y install mariadb-server mariadb
systemctl start mariadb
mysql -u root < /home/admin/setup/mariadb_security_config.sql
systemctl enable mariadb

#php installation and setup
yum -y install php php-mysql php-fpm
mv -f /home/admin/setup/php.ini /etc
mv -f /home/admin/setup/www.conf /etc/php-fpm.d
systemctl start php-fpm
systemctl enable php-fpm

#Configure nginx
mv -f /home/admin/setup/nginx.conf /etc/nginx
mv -f /home/admin/setup/info.php /usr/share/nginx/html
systemctl restart nginx

#Wordpress setup
mysql -u root < /home/admin/setup/wp_mariadb_config.sql
wget https://wordpress.org/latest.tar.gz /home/admin
tar xzvf latest.tar.gz --directory /home/admin
mv /home/admin/setup/wp-config.php  /home/admin/wordpress
rsync -avP /home/admin/wordpress/ /usr/share/nginx/html/
mkdir /usr/share/nginx/html/wp-content/uploads
chown -R admin:nginx /usr/share/nginx/html/*
systemctl restart nginx

