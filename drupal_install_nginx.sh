#!/bin/bash

echo 'Enter db root password:'
read -s dbpass

apt-get update -y
apt-get install -y sudo wget nano curl #expect
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/nginx

sudo apt-get install -y nginx
#!/usr/bin/expect -f
#set timeout -1
#spawn ./drupal_install_nginx.sh
#expect "Geographic area:\r"
#send -- "8\r"
#expect "Time zone:\r"
#send -- "23\r"
#expect eof
sudo /etc/init.d/nginx start


sudo apt-get update -y

sudo apt-get install -y software-properties-common
sudo apt-get install -y mariadb-server mariadb-client libapache2-mod-php
sudo apt-get install -y php-cli php8.1-fpm php-json php-common php-mysql php-zip php-gd
sudo apt-get install -y php-intl php-mbstring php-curl php-xml php-pear php-tidy
sudo apt-get install -y php-soap php-bcmath php-xmlrpc

sudo /etc/init.d/php8.1-fpm start
#sudo mysql_secure_installation

sudo /etc/init.d/mariadb start
sudo mysql -u root -p$dbpass<<'EOF'
CREATE USER drupal@localhost IDENTIFIED BY "drupal";
create database drupal;
GRANT ALL ON drupal.* TO drupal@localhost;
FLUSH PRIVILEGES;
EOF


sudo wget https://www.drupal.org/download-latest/tar.gz -O drupal.tar.gz

sudo tar -xvf drupal.tar.gz
sudo mv drupal-*.* /var/www/html/drupal
sudo cp /var/www/html/drupal/sites/default/default.settings.php /var/www/html/drupal/sites/default/settings.php

sudo chown -R www-data:www-data /var/www/html/drupal/
sudo chmod -R 755 /var/www/html/drupal/
sudo echo 'server {
        listen 81;
        listen [::]:81;
        root /var/www/html/drupal;

        # Add index.php to the list if you are using PHP
        index index.php index.html index.htm index.nginx-debian.html;

        server_name examp.com;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
        }
        # pass PHP scripts to FastCGI server
        #
        location ~ \.php$ {
                include snippets/fastcgi-php.conf;

                # With php-fpm (or other unix sockets):
                fastcgi_pass unix:/run/php/php8.1-fpm.sock;
               # With php-cgi (or other tcp sockets):
        }

        location ~ /\.ht {
                deny all;
        }
}
' > /etc/nginx/sites-enabled/drupal

#sed -i "s/# Basic Settings/# Basic Settings
#server_names_hash_bucket_size 64;/1" /etc/nginx/nginx.conf
sudo /etc/init.d/php8.1-fpm reload
sudo /etc/init.d/nginx reload
