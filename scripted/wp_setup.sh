sed -i '4s/.*/BOOTPROTO=static' /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "IPADDR=192.168.254.10" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "PREFIX=24" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "GATEWAY=192.168.254.10" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-enp0s3
echo "192.168.254.10/24 wp.snp.acit" >> /etc/hosts
systemctl restart network

yum install wget
wget https://4640.acit.site/code/ssh_setup/acit_admin_id_rsa.pub --user=student --password=w1nt3r2019

mkdir -p ~/.ssh
chmod 700 ~/.ssh

sudo useradd admin -p P@ssw0rd
sudo gpasswd -a admin wheel
cp acit_admin_id_rsa.pub ~/.ssh/authorized_keys

setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

yum install -y @core epel-release vim git tcpdump nmap-ncat curl 
yum update -y

firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --list-all

yum install -y nginx
systemctl start nginx
systemctl enable nginx
systemctl status nginx 

curl http://localhost:80

yum install -y mariadb-server mariadb
systemctl start mariadb

echo "UPDATE mysql.user SET Password=PASSWORD('P@ssw0rd') WHERE User='root';" > mariadb_security_config.sql
echo "DELETE FROM mysql.user WHERE User='';" >> mariadb_security_config.sql
echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1','::1');" >> mariadb_security_config.sql
echo "DROP DATABASE test;" >> mariadb_security_config.sql
echo "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" >> mariadb_security_config.sql

mysql -u root -p < mariadb_security_config.sql

systemctl enable mariadb

yum install -y php php-mysql php-fpm

sed -i '763s/.*/cgi.fix_pathinfo=0/' etc/php.ini
sed -i '12s/.*/listen=/var/run/php-fpm/php-fpm.sock/' etc/php-fpm.d/www.conf
sed -i '31s/.*/listen.owner=nobody' /etc/php-fpm.d/www.conf
sed -i '32s/.*/listen.group=nobody' /etc/php-fpm.d/www.conf
sed -i '39s/.*/user=nginx' /etc/php-fpm.d/www.conf
sed -i '41s/.*/group=nginx' /etc/php-fpm.d/www.conf
sed -i '12s:.*:listen = /var/run/php-fpm/php-fpm.sock:' /etc/php-fpm.d/www.conf

systemctl start php-fpm
systemctl enable php-fpm

sed -i '44s/.*/index index.php index.html index.htm;/' /etc/nginx/nginx.conf
sed -i '57s/.*//' /etc/nginx/nginx.conf
sed -i '89s/.*//' /etc/nginx/nginx.conf
echo "location ~ \.php$ {" >> /etc/nginx/nginx.conf
echo 'try_files $uri =404;' >> /etc/nginx/nginx.conf
echo "fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;" >> /etc/nginx/nginx.conf
echo "fastcgi_index index.php;" >> /etc/nginx/nginx.conf
echo 'fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> /etc/nginx/nginx.conf
echo "include fastcgi_params;" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf
echo "}" >> /etc/nginx/nginx.conf

echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php
systemctl restart nginx

echo "CREATE DATABASE wordpress;" > wp_mariadb_config.sql
echo "CREATE USER wordpress_user@localhost IDENTIFIED BY 'P@ssw0rd';" >> wp_mariadb_config.sql
echo "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress_user@localhost;" >> wp_mariadb_config.sql
echo "FLUSH PRIVILEGES;" >> wp_mariadb_config.sql

mysql -u root -p < wp_mariadb_config.sql


wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php

sed -i "23s/.*/define('DB_NAME', 'wordpress');/" wordpress/wp-config.php
sed -i "26s/.*/define('DB_USER', 'wordpress_user');/" wordpress/wp-config.php
sed -i "29s/.*/define('DB_PASSWORD', 'P@ssw0rd');/" wordpress/wp-config.php 

yum install rsync 

sudo rsync -avP wordpress/ /usr/share/nginx/html/

sudo mkdir /usr/share/nginx/html/wp-content/uploads

sudo chown -R admin:nginx /usr/share/nginx/html/*