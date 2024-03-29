#!/bin/bash

sudo yum -y update
sudo yum install -y epel-release
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-8.rpm
sudo cp mariadb.repo /etc/yum.repos.d
sudo rpm -Uvh http://nginx.org/packages/centos/8/x86_64/RPMS/nginx-1.20.1-1.el8.ngx.x86_64.rpm
sudo yum -y module enable php:remi-8.2
sudo yum install -y zip unzip git composer java-1.8.0-openjdk mariadb-server php php-fpm php-mysqlnd php-gd php-curl php-mbstring php-dom php-opcache php-soap policycoreutils-python-utils --enablerepo=remi
sudo systemctl enable nginx && sudo systemctl start nginx && sudo systemctl enable mariadb && sudo systemctl start mariadb && sudo systemctl enable php-fpm && sudo systemctl start php-fpm
sudo mysqladmin -u root password root
sudo sed -i "$ a [mariadb] \nmax_allowed_packet=900M" /etc/my.cnf
sudo sed -i.bak s/'display_errors = Off'/'display_errors = On'/g /etc/php.ini
sudo sed -i.bak s/'display_startup_errors = Off'/'display_startup_errors = On'/g /etc/php.ini
sudo sed -i.bak s/'memory_limit = 128M'/'memory_limit = 900M'/g /etc/php.ini
sudo sed -i.bak s/'upload_max_filesize = 2M'/'upload_max_filesize = 100M'/g /etc/php.ini
sudo sed -i.bak s/'post_max_size = 8M'/'post_max_size = 100M'/g /etc/php.ini
sudo sed -i.bak s/'user = apache'/'user = rocky'/g /etc/php-fpm.d/www.conf
sudo sed -i.bak s/'group = apache'/'group = rocky'/g /etc/php-fpm.d/www.conf
sudo sed -i.bak s/'\/run\/php-fpm\/www.sock'/'127.0.0.1:9000'/g /etc/php-fpm.d/www.conf
sudo rm /etc/nginx/conf.d/default.conf
sudo cp nginx.conf /etc/nginx/conf.d
composer global require drush/drush
echo 'export PATH=$HOME/.composer/vendor/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
sudo rpm -Uvh https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.0-x86_64.rpm
yes | sudo /usr/share/elasticsearch/bin/elasticsearch-plugin install ingest-attachment
sudo systemctl enable elasticsearch && sudo systemctl start elasticsearch
sudo semanage permissive -a httpd_t
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
sudo systemctl restart nginx && sudo systemctl restart mariadb && sudo systemctl restart php-fpm
sudo chown -R rocky:rocky /srv/



# based on https://github.com/MariaDB/server/blob/5.5/scripts/mysql_secure_installation.sh
mariadb -u root -proot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
