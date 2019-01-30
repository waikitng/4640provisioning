setenforce 0
sed -r -i 's/SELINUX=(enforcing|disabled)/SELINUX=permissive/' /etc/selinux/config

yum install -y @core epel-release vim git tcpdump nmap-ncat curl

yum update -y

firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent

firewall-cmd --zone=public --list-all

wget https://4640.acit.site/code/ssh_setup/acit_admin_id_rsa.pub --user=student --password=w1nt3r2019

yum install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx
sudo sytemctl status nginx

