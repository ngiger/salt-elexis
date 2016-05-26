# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
    v.gui = true
  end
  # name/ip/hw_addr must be kept in sync betweeen Vagrantfile and saltstack/pillar/network.sls
  config.vm.define :ElexisServerDemo do |prxserver_config|
    # prxserver_config.vm.box = "ubuntu/trusty64"
    prxserver_config.vm.box   =  'deb/jessie-amd64'
    prxserver_config.vm.host_name = 'ElexisServerDemo'
    # master IP must be in sync between Vagrantfile, scripts/bootstrap_client.sh and scripts/bootstrap_master.sh
    prxserver_config.vm.network "private_network", ip: "192.168.1.90"
    prxserver_config.vm.network "public_network", bridge: 'br0', :mac => '00:00:00:68:01:91'.gsub(':','')
    prxserver_config.vm.synced_folder "saltstack/salt/", "/srv/salt"
    prxserver_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar"
    prxserver_config.vm.provision :shell, :path => "scripts/bootstrap_master.sh"
  end

  config.vm.define :ElexisLaborDemo do |labor_config|
    labor_config.vm.box = "ubuntu/precise64"
    labor_config.vm.host_name = 'ElexisLaborDemo'
    labor_config.vm.network "private_network", ip: "192.168.1.91"
    labor_config.vm.network "public_network", bridge: 'br0', :mac => '00:00:00:68:01:92'.gsub(':','')
    labor_config.vm.provision :shell, :path => "scripts/bootstrap_client.sh"
  end

  # A Vagrant box for ubuntu netboot would be nice
  # https://github.com/holms/vagrant-jessie-box/releases/download/Jessie-v0.1/Debian-jessie-amd64-netboot.box
end
