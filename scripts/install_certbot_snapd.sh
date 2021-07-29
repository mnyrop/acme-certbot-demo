sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable epel # make sure EPEL is enabled!!
yum -y update
yum install kernel-modules -y
yum -y install squashfs-tools squashfuse fuse snapd
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap
snap install core
snap refresh core

snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
