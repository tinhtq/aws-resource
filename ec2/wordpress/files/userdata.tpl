#!/bin/bash
apt update -y
apt install curl wget -y
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip
mkdir -p /srv/www
chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
touch /etc/apache2/sites-available/wordpress.conf
cat <<'EOF' >> /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF
a2ensite wordpress
a2enmod rewrite
a2dissite 000-default
service apache2 reload
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/database_name_here/${database_name}/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/${database_username}/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/${database_password}/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/localhost/${database_host}/' /srv/www/wordpress/wp-config.php
