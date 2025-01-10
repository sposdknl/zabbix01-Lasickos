# Stáhněte a nainstalujte Zabbix repository
sudo rpm -Uvh https://repo.zabbix.com/zabbix/7.0/centos/9/x86_64/zabbix-release-latest-7.0.el9.noarch.rpm
dpkg -i zabbix-release_latest+centos_all.deb
dnf update

# Instalace Zabbix serveru, agenta, frontend a SQL skriptů
dnf install -y zabbix-server-mysql zabbix-agent2 zabbix-web zabbix-apache-conf zabbix-sql-scripts

# Instalace MySQL serveru
dnf install -y mysql-server

# Spuštění MySQL a povolení služby
systemctl start mysql
systemctl enable mysql

# Vytvoření databáze Zabbix
mysql -u root -e "CREATE DATABASE IF NOT EXISTS zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"

# Vytvoření uživatele a přiřazení práv
mysql -u root -e "CREATE USER IF NOT EXISTS 'zabbix'@'localhost' IDENTIFIED WITH mysql_native_password BY 'zabbix_password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Povolení funkcí pro Zabbix
mysql -u root -e "SET GLOBAL log_bin_trust_function_creators = 1;"

# Kontrola, zda je schéma Zabbix k dispozici, a jeho import
if [ -f /usr/share/zabbix-sql-scripts/mysql/server.sql.gz ]; then
    zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql -u zabbix -p'zabbix_password' zabbix
else
    echo "Chyba: Databázový skript Zabbix nebyl nalezen."
    exit 1
fi

# Zakázání log_bin_trust_function_creators
mysql -u root -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# Nastavení hesla pro Zabbix server v konfiguraci
sed -i 's/# DBPassword=/DBPassword=zabbix_password/' /etc/zabbix/zabbix_server.conf

# Restartování služeb Zabbix serveru, agenta a Apache
systemctl restart zabbix-server zabbix-agent2 apache2
systemctl enable zabbix-server zabbix-agent2 apache2

# Konfigurace PHP pro Zabbix frontend
PHP_INI_PATH=$(php --ini | grep "/cli/php.ini" | sed 's|/cli/php.ini||')
if [ -n "$PHP_INI_PATH" ]; then
    sed -i 's/^max_execution_time = .*/max_execution_time = 300/' "$PHP_INI_PATH/apache2/php.ini"
    sed -i 's/^memory_limit = .*/memory_limit = 128M/' "$PHP_INI_PATH/apache2/php.ini"
    sed -i 's/^post_max_size = .*/post_max_size = 16M/' "$PHP_INI_PATH/apache2/php.ini"
    sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 2M/' "$PHP_INI_PATH/apache2/php.ini"
    sed -i 's/^;date.timezone =.*/date.timezone = Europe\/Prague/' "$PHP_INI_PATH/apache2/php.ini"
else
    echo "Chyba: Konfigurační soubor php.ini nebyl nalezen."
    exit 1
fi

# Restart Apache serveru
systemctl restart apache2

# Konfigurace souboru zabbix_agent2.conf
sed -i "s/Hostname=Zabbix server/Hostname=localhost/g" /etc/zabbix/zabbix_agent2.conf
sed -i 's/Server=127.0.0.1/Server=enceladus.pfsense.cz/g' /etc/zabbix/zabbix_agent2.conf
sed -i 's/ServerActive=127.0.0.1/ServerActive=enceladus.pfsense.cz/g' /etc/zabbix/zabbix_agent2.conf

# Restart Zabbix agenta
systemctl restart zabbix-agent2

# Závěr
Po dokončení těchto kroků by měl být Zabbix server a agent úspěšně nainstalován a nakonfigurován. Databáze bude připravena pro použití a frontend bude dostupný pro správu a monitorování vašich zařízení.

# Tento proces zahrnoval:
Instalaci Zabbix serveru, agenta a webového frontendu.
Vytvoření a konfiguraci MySQL databáze.
Import databázového schématu.
Nastavení Zabbix serveru a agenta pro správnou komunikaci a monitorování.