#!/bin/bash

echo "======================================="
echo " Install VOIPIRAN Queue Stats"
echo " VOIPIRAN.io"
echo "======================================="
sleep 1

echo "Install VOIPIRAN Asterisk Queue Database"
echo "VOIPIRAN.io"
echo "Hamed Kouhfallah"
echo "k.haamed@gmail.com"
sleep 3

##################################################
# Get Issabel MySQL Root Password
##################################################

rootpw=$(sed -ne 's/.*mysqlrootpwd=//gp' /etc/issabel.conf)

##################################################
# Create Database
##################################################

echo "------------ Create Database ------------"

mysql -uroot -p"$rootpw" < database/voipiran_stats-database.sql

mysql -uroot -p"$rootpw" -e \
"GRANT ALL PRIVILEGES ON voipiran_stats.* TO 'root'@'localhost';
FLUSH PRIVILEGES;"

##################################################
# Asterisk Options
##################################################

ASTERISK_CONF="/etc/asterisk/asterisk.conf"

grep -q "^queue_adaptive_realtime=no" "$ASTERISK_CONF" || \
sed -i '/\[options\]/a queue_adaptive_realtime=no' "$ASTERISK_CONF"

grep -q "^log_membername_as_agent=yes" "$ASTERISK_CONF" || \
sed -i '/\[options\]/a log_membername_as_agent=yes' "$ASTERISK_CONF"

##################################################
# ODBC
##################################################

echo "------------ odbc.ini ------------"

if ! grep -q "^\[voipiran_stats\]" /etc/odbc.ini; then

cat >> /etc/odbc.ini <<EOF

[voipiran_stats]
driver=MariaDB
server=localhost
database=voipiran_stats
Port=3306
Socket=/var/lib/mysql/mysql.sock
option=3
charset=utf8

EOF

fi

##################################################
# res_odbc_custom.conf
##################################################

echo "------------ res_odbc_custom.conf ------------"

if ! grep -q "^\[voipiran_stats\]" /etc/asterisk/res_odbc_custom.conf; then

cat >> /etc/asterisk/res_odbc_custom.conf <<EOF

[voipiran_stats]
enabled=>yes
dsn=>voipiran_stats
pooling=>no
limit=>1
pre-connect=>yes
username=>root
password=>${rootpw}

EOF

fi

##################################################
# queues_custom_general.conf
##################################################

QUEUE_CONF="/etc/asterisk/queues_custom_general.conf"

SETTING="log_membername_as_agent = yes"

echo "------------ queues_custom_general.conf ------------"

touch "$QUEUE_CONF"

if grep -Fxq "$SETTING" "$QUEUE_CONF"; then

    echo "Already Exists"

else

cat >> "$QUEUE_CONF" <<EOF

; Added by VOIPIRAN Queue Stats
$SETTING

EOF

fi

##################################################
# extconfig.conf
##################################################

echo "------------ extconfig.conf ------------"

if ! grep -q "^queue_log => odbc,voipiran_stats,queue_stats" /etc/asterisk/extconfig.conf; then

sed -i '/\[settings\]/a queue_log => odbc,voipiran_stats,queue_stats' /etc/asterisk/extconfig.conf

fi

##################################################
# Reload Asterisk
##################################################

echo "------------ Reload Asterisk ------------"

asterisk -rx "module reload res_odbc.so"
asterisk -rx "reload"

echo
echo "======================================="
echo " VOIPIRAN Queue Stats Installed"
echo "======================================="