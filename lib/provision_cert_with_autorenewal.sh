certbot --apache --domain $HTTPD_ENV_URL
certbot certificates
certbot renew --dry-run

systemctl enable crond
systemctl status crond

crontab -l | { cat; echo "6 1,13 * * * certbot renew --renew-hook 'systemctl restart httpd'"; } | crontab -
