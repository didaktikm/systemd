#!/usr/bin/env bash

### Task 1
cp /vagrant/provision/watchlog /etc/sysconfig/
cp /vagrant/provision/watchlog.log /var/log/
cp /vagrant/provision/watchlog.sh /opt/ 
chmod +x /opt/watchlog.sh
cp /vagrant/provision/watchlog.service /etc/systemd/system/
cp /vagrant/provision/watchlog.timer /etc/systemd/system/

systemctl daemon-reload
systemctl enable watchlog.timer
systemctl enable watchlog.service
systemctl start watchlog.timer
systemctl start watchlog.service

### Task 2
# Устанавливаем spawn-fcgi и необходимые пакеты
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
# Необходимо раскомментировать строки с переменными в /etc/sysconfig/spawn-fcgi
sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi
# Добавляем юнит 
cp /vagrant/provision/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service
# Включаем и стартуем
systemctl daemon-reload
systemctl enable spawn-fcgi
systemctl start spawn-fcgi

### Task 3
# Копируем юнит из шаблона
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
# Добавляем параметр для запуска нескольких экземпляров 
sed -i '/^EnvironmentFile/ s/$/-%I/' /etc/systemd/system/httpd@.service
echo "OPTIONS=-f conf/httpd-first.conf" > /etc/sysconfig/httpd-first
echo "OPTIONS=-f conf/httpd-second.conf" > /etc/sysconfig/httpd-second
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd-second.conf
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.OLD
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd-second.conf
sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-second.pid' /etc/httpd/conf/httpd-second.conf

systemctl disable httpd
systemctl daemon-reload
systemctl start httpd@first
systemctl start httpd@second