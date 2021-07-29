# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "generic/centos7"
  config.vm.hostname = "certbot-apache"
  config.vm.synced_folder ".", "/vagrant/src"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 443, host: 443

  config.vm.provision "shell", inline: "cd /vagrant/src && export HTTPD_ENV_URL=127.0.0.1"
  config.vm.provision "shell", path: "./scripts/provision.sh"
  config.vm.provision "shell", path: "./scripts/install_apache.sh"
  # config.vm.provision "shell", path: "./scripts/deploy_app.sh"
  config.vm.provision "shell", path: "./scripts/install_certbot_pip.sh"
  # config.vm.provision "shell", path: "./scripts/register_acme.sh"
  # config.vm.provision "shell", path: "./scripts/provision_cert_with_autorenewal.sh"
end
