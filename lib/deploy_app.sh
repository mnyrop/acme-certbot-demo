git clone https://github.com/mnyrop/acme-certbot-demo.git ~/acme-certbot-demo
yes | cp -ru ~/acme-certbot-demo/app/* /var/www/html/

grep -qxF 'IncludeOptional sites-enabled/*.conf' /etc/httpd/conf/httpd.conf || echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
rm -f /etc/httpd/conf.d/ssl.conf && touch /etc/httpd/conf.d/ssl.conf
echo "Listen 443 https" >> /etc/httpd/conf.d/ssl.conf
yes | cp -f ~/acme-certbot-demo/conf/site.conf /etc/httpd/sites-available/${HTTPD_ENV_URL}.conf
sed -i "s/\$HTTPD_ENV_URL/${HTTPD_ENV_URL}/" /etc/httpd/sites-available/${HTTPD_ENV_URL}.conf
ln -s /etc/httpd/sites-available/${HTTPD_ENV_URL}.conf /etc/httpd/sites-enabled/${HTTPD_ENV_URL}.conf

systemctl restart httpd
