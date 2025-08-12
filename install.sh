#!/bin/bash
echo "Install VOIPIRAN Stats"
echo "VOIPIRAN.io"
sleep 1

echo "Install VOIPIRAN Asterisk Queue Database"
echo "VOIPIRAN.io"
echo "Hamed Kouhfallah"
echo "k.haamed@gmail.com"
sleep 3

###Fetch DB root PASSWORD
rootpw=$(sed -ne 's/.*mysqlrootpwd=//gp' /etc/issabel.conf)

### Create Database
echo "Install CallStats Mysql DataBase"
echo "------------Create DB-----------------"
mysql -uroot -p$rootpw < database/voipiran_stats-database.sql
mysql -uroot -p$rootpw -e "GRANT ALL PRIVILEGES ON voipiran_stats.* TO 'root'@'localhost';"

#Asterisk Queue Adaptive
sed -i '/\[options\]/a queue\_adaptive\_realtime\=no' /etc/asterisk/asterisk.conf
sed -i '/\[options\]/a log\_membername\_as\_agent\=yes' /etc/asterisk/asterisk.conf

### Add ODBC 
echo "-------------odbc.ini----------------"
echo "" >> /etc/odbc.ini
echo "[voipiran_stats]" >> /etc/odbc.ini
echo "driver=MariaDB" >> /etc/odbc.ini
echo "server=localhost" >> /etc/odbc.ini
echo "database=voipiran_stats" >> /etc/odbc.ini
echo "Port=3306" >> /etc/odbc.ini
echo "Socket=/var/lib/mysql/mysql.sock" >> /etc/odbc.ini
echo "option=3" >> /etc/odbc.ini
echo "charset=utf8" >> /etc/odbc.ini

### Add ODBC 
echo "-------------res_odbc_custom.conf----------------"
echo "" >> /etc/asterisk/res_odbc_custom.conf
echo "[voipiran_stats]" >> /etc/asterisk/res_odbc_custom.conf
echo "enabled=>yes" >> /etc/asterisk/res_odbc_custom.conf
echo "dsn=>voipiran_stats" >> /etc/asterisk/res_odbc_custom.conf
echo "pooling=>no" >> /etc/asterisk/res_odbc_custom.conf
echo "limit=>1" >> /etc/asterisk/res_odbc_custom.conf
echo "pre-connect=>yes" >> /etc/asterisk/res_odbc_custom.conf
echo "username=>root" >> /etc/asterisk/res_odbc_custom.conf
echo "password=>${rootpw}" >> /etc/asterisk/res_odbc_custom.conf

	
		 # اضافه کردن log_membername_as_agent در queues_custom.conf
    QUEUE_CONF2="/etc/asterisk/queues_custom_general.conf"
    SETTING="log_membername_as_agent = yes"

    if [ ! -f "$QUEUE_CONF" ]; then
        echo "⚠️ فایل $QUEUE_CONF وجود نداشت. در حال ساخت فایل..."
        touch "$QUEUE_CONF"
    fi

    if grep -Fxq "$SETTING" "$QUEUE_CONF"; then
        echo "✔️ $SETTING از قبل در $QUEUE_CONF وجود دارد"
    else
        echo "➕ افزودن $SETTING به $QUEUE_CONF"
        echo "" >> "$QUEUE_CONF"
        echo "; Added by script for voipiran stats" >> "$QUEUE_CONF"
        echo "$SETTING" >> "$QUEUE_CONF"
    fi


### Add ODBC 
echo "-------------extconfig.conf----------------"
sed -i '/\[settings\]/a queue\_log \=\> odbc\,voipiran\_stats\,queue\_stats' /etc/asterisk/extconfig.conf


### Restart Asterisk
asterisk -rx "reload"