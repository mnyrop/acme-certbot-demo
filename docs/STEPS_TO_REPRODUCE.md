# Steps to Reproduce

## ToC
- [Instructions](#instructions)
  + [Basic set up](#basic-set-up)
  + [Install Apache](#install-apache)
  + [Deploy test app](#deploy-test-app)
  + [Serve test app with Apache](#serve-test-app-with-apache)
  + [Install Certbot](#install-certbot)
    - [Option a: via pip](#option-a-via-pip)
    - [Option b: via snapd](#option-b-via-snapd)
  + [Use Certbot to provision a cert](#use-certbot-to-provision-a-cert)
  + [Use Certbot to dry run a cert renewal](#use-certbot-to-dry-run-a-cert-renewal)
  + [Set up a cron for cert renewal](#set-up-a-cron-for-cert-renewal)
- [Misc notes](#misc-notes)

--------

## Instructions

### Basic set up

0. log in as root
    ``` sh
    sudo su -
    ```

1. check os version
    ``` sh
    cat /etc/redhat-release
    ```

2. install nano and use nano
    ``` sh
    yum -y install nano
    export VISUAL="nano"
    ````
3. export domain as ENV var for setup
    ``` sh
    export HTTPD_ENV_URL="dco01la-1692s.cfs.its.nyu.edu"
    ```

### Install Apache

4. install + enable apache
    ``` sh
    yum -y install httpd mod_ssl
    systemctl start httpd
    mkdir -p /var/www/log
    mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
    chown -R $USER:$USER /var/www/html
    chmod -R 755 /var/www
    ```

### Deploy test app
5. clone project & (pre)deploy test app
    ``` sh
    git clone https://github.com/mnyrop/acme-certbot-demo.git ~/acme-certbot-demo
    yes | cp -ru ~/acme-certbot-demo/app/* /var/www/html/
    ```

### Serve test app with Apache
6. enable vhosts with domain (NOTE: certbot doesn't seem to play nice with ENV vars in apache configs, hence the `sed` command below to replace it with the literal domain string)

    ``` sh
    grep -qxF 'IncludeOptional sites-enabled/*.conf' /etc/httpd/conf/httpd.conf || echo 'IncludeOptional sites-enabled/*.conf' >> /etc/httpd/conf/httpd.conf
    rm -f /etc/httpd/conf.d/ssl.conf && touch /etc/httpd/conf.d/ssl.conf
    echo "Listen 443 https" >> /etc/httpd/conf.d/ssl.conf
    yes | cp -f ~/acme-certbot-demo/conf/site.conf /etc/httpd/sites-available/${HTTPD_ENV_URL}.conf
    sed -i "s/\$HTTPD_ENV_URL/${HTTPD_ENV_URL}/" /etc/httpd/sites-available/${HTTPD_ENV_URL}.conf
    ln -s /etc/httpd/sites-available/${HTTPD_ENV_URL}.conf /etc/httpd/sites-enabled/${HTTPD_ENV_URL}.conf
    ```
7. Restart Apache
    ``` sh
    systemctl restart httpd
    ```

### Install Certbot

#### Option a: via pip
*(this is the method currently in use)*  

8. install pip in virtual env
    ``` sh
    yum -y install python3 augeas-libs
    python3 -m venv /opt/certbot/
    /opt/certbot/bin/pip install --upgrade pip
    ```
9. install certbot with pip
    ``` sh
    /opt/certbot/bin/pip install certbot certbot-apache
    ln -s /opt/certbot/bin/certbot /usr/bin/certbot
    ```


#### Option b: via snapd
*(this method is encouraged by certbot but currently fails on the vm. my guess is that this is likely a security configuration issue, since `snapd` ___should___ be available via EPEL, and I struggled to manually enable EPEL. FWIW, I got as far as the following error: `“system does not fully support snapd: cannot mount squashfs image…”`

8. install snapd (see: [installing snap on rhel](https://snapcraft.io/docs/installing-snap-on-red-hat))
    ``` sh
    sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum-config-manager --enable epel # make sure EPEL is enabled!!
    yum -y update
    yum install kernel-modules -y
    yum -y install squashfs-tools squashfuse fuse snapd
    systemctl enable --now snapd.socket
    ln -s /var/lib/snapd/snap /snap
    snap install core
    snap refresh core
    ```
9. install certbot from snap
   ``` sh
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
    ```

### Use Certbot to provision a cert

10. OPTIONAL: register + use sectigo ACME server instead of default let's encrypt. You will need to replace the sample credentials below with your own:  
    ``` sh
    export ACME_EMAIL="customeremail@domain.com"
    export ACME_SERVER="https:acme.sectigo.net/v2/InCommonRSAOV"
    export ACME_EAB_KID="bxFGQVK9ed1oNRRVuz3FZg"
    export ACME_EAB_HMAC_KEY="ek2TIQpQcG8Tlt- 5OjMEteSBISa7-fvWAWDyMpczV- nRXc7PkSMtuvW31YQlxA8t0vTf0zOz3xAwEGNI1n0gEw"

    certbot register --email $ACME_EMAIL --server $ACME_SERVER --eab-kid $ACME_EAB_KID –-eab-hmac-key $ACME_EAB_HMAC_KEY
    ```

11. install certs & modify apache to use them
    ``` sh
    certbot --apache --domain $HTTPD_ENV_URL
    ```

12. show certs
    ``` sh
    certbot certificates
    ```

### Use Certbot to dry run a cert renewal
13. test automatic renewal
    ``` sh
    certbot renew --dry-run
    ```

### Set up a cron for cert renewal

14. Start and check status for crond
    ``` sh
    systemctl enable crond
    systemctl status crond
    ```

15. Write a cron to check & renew cert if appropriate, then automate an apache restart.
    ``` sh
    crontab -e

    # add the text below
    6 1,13 * * * certbot renew --renew-hook "systemctl restart httpd"
    ```

16. Check for cron job
    ``` sh
    crontab -l
    ```

--------

## Misc notes
- gotchas:
  + !!! make sure that there isn't a vhost in `/etc/httpd/conf.d/ssl.conf` that conflicts and routes 443 to self-signed certs instead of the new ones !!!
  + !!! make sure that **public** traffic is allowed on `:80` and `:443` !!!
- dns troubleshooting
  + check A record `host dco01la-1692s.cfs.its.nyu.edu` (from anywhere)
  + check host from IP `nslookup 128.122.122.8` (from anywhere)
  + `ipconfig` or `ip addr show` (on host)
- useful apache troubleshooting:
  + `apachectl` (returns status)
  + `apachectl configtest` (checks config syntax)
  + `apachectl -S` (for info on vhosts and more)
- reset and start over:
  + revoke + delete cert
    ``` sh
    certbot revoke --cert-name dco01la-1692s.cfs.its.nyu.edu
    certbot rollback
    ```
  + uninstall apache
    ``` sh
    systemctl stop httpd
    yum -y erase httpd httpd-tools apr apr-util mod_ssl
    ```
  + restart from step 3 above
