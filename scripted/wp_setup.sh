#assume for this script that you are root user

useradd admin -p P@ssw0rd

setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

yum install -y @core epel-release vim git tcpdump nmap-ncat curl wget

yum update -y

firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent

firewall-cmd --zone=public --list-all

wget https://4640.acit.site/code/ssh_setup/acit_admin_id_rsa.pub --user=student --password=w1nt3r2019

yum install -y nginx

systemctl start nginx
systemctl enable nginx
systemctl status nginx 

#lines to verify operation

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

systemctl start php-fpm
systemctl enable php-fpm

echo "CREATE DATABASE wordpress;" > wp_mariadb_config.sql
echo "CREATE USER wordpress_user@localhost IDENTIFIED BY 'P@ssw0rd';" >> wp_mariadb_config.sql
echo "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress_user@localhost;" >> wp_mariadb_config.sql
echo "FLUSH PRIVILEGES;" >> wp_mariadb_config.sql

mysql -u root -p < wp_mariadb_config.sql

echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/info.php

systemctl restart nginx

mysql -u root -p < wp_mariadb_config.sql

mysql -u root -e "SELECT user FROM mysql.user;"

mysql -u root -e "SHOW DATABASES;"

wget https://wordpress.org/latest.tar.gz

tar xzvf latest.tar.gz

cp wordpress/wp-config-sample.php wordpress/wp-config.php

rsync -avP wordpress/ /usr/share/nginx/html/

mkdir /usr/share/nginx/html/wp-content/uploads

chown -R admin:nginx /usr/share/nginx/html/*