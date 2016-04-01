# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :prxserver do |prxserver_config|
    # prxserver_config.vm.box = "ubuntu/trusty64"
    prxserver_config.vm.box   =  'deb/jessie-amd64'
    prxserver_config.vm.host_name = 'prxserver.local'
    prxserver_config.vm.network "private_network", ip: "192.168.1.222"
    prxserver_config.vm.network "public_network", bridge: 'br0', :mac => '000000250122'
    prxserver_config.vm.synced_folder "saltstack/salt/", "/srv/salt"
    prxserver_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar"
    prxserver_config.vm.provision :shell, :path => "scripts/bootstrap_master.sh"
    prxserver_config.vm.provision :salt do |salt|
      salt.prxserver_config = "saltstack/etc/prxserver"
      salt.prxserver_key = "saltstack/keys/prxserver_minion.pem"
      salt.prxserver_pub = "saltstack/keys/prxserver_minion.pub"
      salt.minion_key = "saltstack/keys/prxserver_minion.pem"
      salt.minion_pub = "saltstack/keys/prxserver_minion.pub"
      salt.seed_prxserver = {
                          "minion1" => "saltstack/keys/minion1.pub",
                          "minion2" => "saltstack/keys/minion2.pub"
                         }

      salt.install_type = "stable"
      salt.install_prxserver = true
      salt.no_minion = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end if false
  end

  config.vm.define :labor do |labor_config|
    labor_config.vm.box = "ubuntu/precise64"
    labor_config.vm.host_name = 'labor.local'
    labor_config.vm.network "private_network", ip: "192.168.1.40"
    labor_config.vm.network "public_network", bridge: 'br0', :mac => '000000250140'
    labor_config.vm.provision :shell, :path => "scripts/bootstrap_client.sh"
    labor_config.vm.provision :salt do |salt|
      salt.labor_config = "saltstack/etc/minion2"
      salt.minion_key = "saltstack/keys/minion2.pem"
      salt.minion_pub = "saltstack/keys/minion2.pub"
      salt.install_type = "stable"
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end if false
  end

end
