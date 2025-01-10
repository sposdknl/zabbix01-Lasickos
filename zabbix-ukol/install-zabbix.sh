# Aktualizace systému
sudo dnf update
sudo dnf upgrade -y

# Instalace základních nástrojů
sudo dnf install -y wget curl vim gnupg2

# Instalace balícku net-tools
sudo dnf update

# Stažení balíčku pro instalaci zabbix repo
sudo rpm -Uvh https://repo.zabbix.com/zabbix/7.0/centos/9/x86_64/zabbix-release-latest-7.0.el9.noarch.rpm
sudo dnf clean all

# Aktualizace repository
sudo dnf update

# Instalace MySQL serveru (MariaDB)
sudo dnf install -y mariadb-server

# Start sluzby mariadb
sudo systemctl start mariadb

# Povoleni sluzby mariadb
sudo systemctl enable mariadb

rpm -qa | grep zabbix
rpm -qa | grep php

sudo yum install epel-release
sudo yum install zabbix-server-mysql zabbix-agent zabbix-web-mysql zabbix-apache-conf php-fpm

sudo systemctl enable zabbix-server
sudo systemctl start zabbix-server

sudo systemctl enable zabbix-agent
sudo systemctl start zabbix-agent

sudo systemctl enable php-fpm
sudo systemctl start php-fpm


# Instalace Zabbix serveru, agenta a webového rozhraní
sudo dnf install -y zabbix-server-mysql zabbix-agent zabbix-web-mysql zabbix-apache-conf php-fpm

# Instalace EPEL repository (pokud chybí)
sudo dnf install -y epel-release

# Aktualizace repository
sudo dnf install -y mariadb-server
sudo yum install zabbix-server-mysql zabbix-agent zabbix-web-mysql zabbix-apache-conf php-fpm -y
# Inicializace databáze Zabbix
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -p"zabbix_password" zabbix
# Instalace Apache (httpd)
sudo dnf install -y httpd

# Povolení Apache služby
sudo systemctl enable httpd

# Povoleni sluzby zabbix-agent2
sudo systemctl enable mariadb.service
sudo systemctl enable zabbix-server zabbix-agent php-fpm

# Restart sluzby zabbix-agent2 a apache
sudo systemctl restart mariadb.service
sudo systemctl restart zabbix-server zabbix-agent httpd php-fpm

# EOF
