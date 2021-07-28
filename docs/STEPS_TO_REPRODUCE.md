# [acme-certbot-demo](http://dco01la-1692s.cfs.its.nyu.edu/)


## 1. set up apache

0. log in as root
    ``` sh
    sudo su -
    ```

1. check centos version
    ``` sh
    cat /etc/redhat-release
    ```

2. install nano
    ``` sh
    yum -y install nano
    ````

3. install + enable apache
    ``` sh
    yum -y install httpd
    systemctl start httpd
    mkdir -p /var/www/log
    chown -R $USER:$USER /var/www/html
    chmod -R 755 /var/www
    ```

4. clone project & (pre)deploy test app
    ``` sh
    git clone https://github.com/mnyrop/acme-certbot-demo.git ~/acme-certbot-demo
    yes | cp -ru ~/acme-certbot-demo/app/* /var/www/html/
    ```

5. enable vhosts & restart apache
    ``` sh
    mkdir -p /etc/httpd/sites-available /etc/httpd/sites-enabled
    nano /etc/httpd/conf/httpd.conf
    ```

    add to end:
      ``` txt
      IncludeOptional sites-enabled/*.conf
      ```

      ``` sh
      nano /etc/httpd/sites-available/dco01la-1692s.cfs.its.nyu.edu.conf
      ```

      ```txt
      <VirtualHost *:80>
        ServerName www.dco01la-1692s.cfs.its.nyu.edu
        ServerAlias dco01la-1692s.cfs.its.nyu.edu
        DocumentRoot /var/www/html
        ErrorLog /var/www/log/error.log
        CustomLog /var/www/log/requests.log combined
      </VirtualHost>
      ```

      ``` sh
      ln -s /etc/httpd/sites-available/dco01la-1692s.cfs.its.nyu.edu.conf /etc/httpd/sites-enabled/dco01la-1692s.cfs.its.nyu.edu.conf
      systemctl restart httpd
      ```

## 2. install certbot

### option a: via pip
*(this is the method currently in use)*  

5. install pip in virtual env
    ``` sh
    yum -y install python3 augeas-libs
    python3 -m venv /opt/certbot/
    /opt/certbot/bin/pip install --upgrade pip
    ```
6. install certbot with pip
    ```sh
    /opt/certbot/bin/pip install certbot certbot-apache
    ln -s /opt/certbot/bin/certbot /usr/bin/certbot
    ```


### option b: via snapd
*(this method is encouraged by certbot but currently fails on the vm. my guess is that this is likely a security configuration issue, since `snapd` ___should___ be available via EPEL, and I struggled to manually enable EPEL. FWIW, I got as far as the following error:)*

  ``` sh
  “system does not fully support snapd: cannot mount squashfs image…”
  ```

5. install snapd (see: [installing snap on rhel](https://snapcraft.io/docs/installing-snap-on-red-hat))
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
6. install certbot from snap
   ``` sh
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
    ```

## 3. use certbot

7. OPTIONAL: register + use sectigo ACME server instead of default let's encrypt. You will need to replace the sample credentials below with your own:  

    ``` sh
    certbot register --email <CUSTOMER_EMAIL>@<DOMAIN.COM> --server https:acme.sectigo.net/v2/InCommonRSAOV --eab-kid bxFGQVK9ed1oNRRVuz3FZg --eab-hmac- key ek2TIQpQcG8Tlt- 5OjMEteSBISa7-fvWAWDyMpczV- nRXc7PkSMtuvW31YQlxA8t0vTf0zOz3xAwEGNI1n0gEw
    ```

8. install certs & modify apache to use them
    ``` sh
    certbot --apache
    ```

9. show certs
    ``` sh
    certbot certificates
    ```

10. test automatic renewal
    ``` sh
    certbot renew --dry-run
    ```
--------

## notes:
- gotchas:
  + !!! make sure that there isn't a vhost in `/etc/httpd/conf.d/ssl.conf` that conflicts and routes 443 to self-signed certs instead of the new ones !!! if there are issues, replace the files contents:
    - `rm /etc/httpd/conf.d/ssl.conf`
    - `nano /etc/httpd/conf.d/ssl.conf`
      ```txt
      #
      # When we also provide SSL we have to listen to the
      # the HTTPS port in addition.
      #
      Listen 443 https
      ```
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
    ```
  + uninstall apache
    ``` sh
    systemctl stop httpd
    yum erase httpd httpd-tools apr apr-util
    yum -y install httpd
    ```
  + restart from step 1.3 above
