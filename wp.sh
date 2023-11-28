#!/bin/bash

echo "Michery Environment Menu"
echo "[1] Instalar"

read -p "Seleccione una opción: " opcion

if [ "$opcion" = "1" ]; then
    sudo su
    sudo apt update
    sudo apt install apache2 \
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

    sudo mkdir -p /srv/www
    sudo chown www-data: /srv/www
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

    sudo bash -c 'cat > /etc/apache2/sites-available/wordpress.conf <<EOF
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
EOF'

    sudo a2ensite wordpress
    sudo a2enmod rewrite
    sudo a2dissite 000-default
    sudo service apache2 reload

    read -p "Ingrese una contraseña para el usuario de WordPress de MySQL: " mysql_pass
    sudo mysql -e "CREATE DATABASE wordpress;"
    sudo mysql -e "CREATE USER wordpress@localhost IDENTIFIED BY '$mysql_pass';"
    sudo mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER ON wordpress.* TO wordpress@localhost;"
    sudo mysql -e "FLUSH PRIVILEGES;"
    sudo service mysql start

    sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i "s/password_here/${mysql_pass}/" /srv/www/wordpress/wp-config.php

    sudo -u www-data sed -i '/AUTH_KEY/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/SECURE_AUTH_KEY/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/LOGGED_IN_KEY/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/NONCE_KEY/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/AUTH_SALT/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/SECURE_AUTH_SALT/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/LOGGED_IN_SALT/d' /srv/www/wordpress/wp-config.php
    sudo -u www-data sed -i '/NONCE_SALT/d' /srv/www/wordpress/wp-config.php
else
    echo "Opción no reconocida."
fi