yum -y install python3 augeas-libs
python3 -m venv /opt/certbot/
/opt/certbot/bin/pip install --upgrade pip

/opt/certbot/bin/pip install certbot certbot-apache
ln -s /opt/certbot/bin/certbot /usr/bin/certbot
