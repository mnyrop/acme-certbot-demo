yum -y install httpd mod_ssl
systemctl start httpd
mkdir -p /var/www/log
mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
chown -R $USER:$USER /var/www/html
chmod -R 755 /var/www
