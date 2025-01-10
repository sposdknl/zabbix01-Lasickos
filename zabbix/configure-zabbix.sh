#!/usr/bin/env bash

# Instalace MySQL serveru (MariaDB)
sudo dnf install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
# Připojení k MySQL
mysql -u root -p
# Konfigurace databáze pro Zabbix
sudo mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'zabbix_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Povolení a startování služeb Zabbix, MariaDB a PHP-FPM
sudo systemctl enable --now zabbix-server zabbix-agent php-fpm mariadb httpd

# Restart služeb pro aplikování změn
sudo systemctl restart zabbix-server zabbix-agent httpd php-fpm mariadb


# Import Zabbix databázové struktury
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -pzabbix_password zabbix 

# Disable log_bin_trust_function_creators option after importing database schema.
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Konfigurace Zabbix serveru
sudo sed -i 's/# DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf

# Spuštění Zabbix serveru a agenta
sudo systemctl restart zabbix-server zabbix-agent2 apache2
sudo systemctl enable zabbix-server zabbix-agent2 apache2

# Konfigurace PHP pro Zabbix frontend
sudo sed -i 's/^max_execution_time = .*/max_execution_time = 300/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^memory_limit = .*/memory_limit = 128M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^post_max_size = .*/post_max_size = 16M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 2M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^;date.timezone =.*/date.timezone = Europe\/Prague/' /etc/php/*/apache2/php.ini

# Restart Apache pro načtení změn
sudo systemctl restart apache2

# # Konfigurace zabbix_agent2.conf
sudo cp -v /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf-orig
sudo sed -i "s/Hostname=Zabbix server/Hostname=lasikoval/g" /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/Server=127.0.0.1/Server=enceladus.pfsense.cz/g' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/ServerActive=127.0.0.1/ServerActive=enceladus.pfsense.cz/g' /etc/zabbix/zabbix_agent2.conf
sudo diff -u /etc/zabbix/zabbix_agent2.conf-orig /etc/zabbix/zabbix_agent2.conf

# Restart sluzby zabbix-agent2
sudo systemctl restart zabbix-agent2

#konfigurace zabbix serveru
ls -lrth /etc/zabbix/web/zabbix.conf.php
-rw------- 1 www-data www-data 1.8K Dec  5 10:37 /etc/zabbix/web/zabbix.conf.php

sudo chmod 400 /etc/zabbix/web/zabbix.conf.php

ls -lrth /etc/zabbix/web/zabbix.conf.php
-r-------- 1 www-data www-data 1.8K Dec  5 10:37 /etc/zabbix/web/zabbix.conf.php

# Disable log_bin_trust_function_creators option after importing database schema.
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Konfigurace Zabbix serveru
sudo sed -i 's/# DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf

# Spuštění Zabbix serveru a agenta
sudo systemctl restart zabbix-server zabbix-agent2 apache2
sudo systemctl enable zabbix-server zabbix-agent2 apache2
# Povolení a startování služeb Zabbix, MariaDB a PHP-FPM
sudo systemctl enable --now zabbix-server zabbix-agent php-fpm mariadb httpd

# Restart služeb pro aplikování změn
sudo systemctl restart zabbix-server zabbix-agent httpd php-fpm mariadb

# Zkontrolujte stav služeb
sudo systemctl status zabbix-server zabbix-agent php-fpm mariadb httpd


# Konfigurace PHP pro Zabbix frontend
sudo sed -i 's/^max_execution_time = .*/max_execution_time = 300/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^memory_limit = .*/memory_limit = 128M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^post_max_size = .*/post_max_size = 16M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 2M/' /etc/php/*/apache2/php.ini
sudo sed -i 's/^;date.timezone =.*/date.timezone = Europe\/Prague/' /etc/php/*/apache2/php.ini

# Restart Apache pro načtení změn
sudo systemctl restart apache2
# EOF