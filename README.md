# Drupal install using NGINX
Based on Ubuntu Docker image.

Script for automatic installation is present: [drupal_install_nginx.sh][ghsh] (runs directly from image).

### Prerequisites

- Docker


### Dockerfile

```sh
FROM ubuntu
MAINTAINER vladskvortsov
WORKDIR home/
COPY *.sh /home/
```   

## Step 1. Build and run docker ubuntu image.

```sh
docker build . -t drupal_install_nginx
docker run -it -p 8080:81 --name ubuntu drupal_install_nginx
```
> Note: `--name ubuntu` ubuntu to name your container.

## Step 2. Install NGINX, MariaDB PHP and additions.

Install NGINX and additions:

```sh
apt-get update -y
apt-get install -y sudo wget nano curl
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/nginx
sudo apt-get install -y nginx
``` 

Then start NGINX service:

```sh
sudo /etc/init.d/nginx start
```

Install PHP and MariaDB:

```sh
sudo apt-get update -y
sudo apt-get install -y software-properties-common
sudo apt-get install -y mariadb-server mariadb-client libapache2-mod-php
sudo apt-get install -y php-cli php8.1-fpm php-json php-common php-mysql php-zip php-gd
sudo apt-get install -y php-intl php-mbstring php-curl php-xml php-pear php-tidy
sudo apt-get install -y php-soap php-bcmath php-xmlrpc
```

Start PHP-FPM and MariaDB services:

```sh
sudo /etc/init.d/php8.1-fpm start
sudo /etc/init.d/mariadb start
```

## Step 3. Cofigure drupal database and user.

Run to enter mysql configuration, enter mysql root password if needed:

```sh
sudo mysql -u root -p
```
Then run following to create user "drupal" with password "drupal":
```sh
CREATE USER drupal@localhost IDENTIFIED BY "drupal";
```
Create drupal database and grant privileges:
```sh
create database drupal;
GRANT ALL ON drupal.* TO drupal@localhost;
FLUSH PRIVILEGES;
exit
```

## Step 4. Install Drupal.

Use wget to download archive, then unpack it:

```sh

sudo wget https://www.drupal.org/download-latest/tar.gz -O drupal.tar.gz
sudo tar -xvf drupal.tar.gz
sudo mv drupal-*.* /var/www/html/drupal
```

Grant priveleges: 
```sh

sudo chown -R www-data:www-data /var/www/html/drupal/
sudo chmod -R 755 /var/www/html/drupal/
```

Add following in `/etc/nginx/sites-enabled/drupal` (hostname in my case `examp.com`, port in use 81):

```sh
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
```    
> Note: You can use vim if you wish.

Restart NGINX and PHP-FPM services:

```sh
sudo /etc/init.d/php8.1-fpm reload
sudo /etc/init.d/nginx reload
```

To access Drupal open your browser and type:

```sh
localhost:8080
```

[git-repo-url]: <https://github.com/vladskvortsov/drupal_install_nginx/>
[ghsh]: <https://github.com/vladskvortsov/drupal_install_nginx/blob/master/drupal_install_nginx.sh>
