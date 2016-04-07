# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
    v.gui = true
  end
  config.vm.define :prxserver do |prxserver_config|
    # prxserver_config.vm.box = "ubuntu/trusty64"
    prxserver_config.vm.box   =  'deb/jessie-amd64'
    prxserver_config.vm.host_name = 'prxserver.local'
    prxserver_config.vm.network "private_network", ip: "192.168.1.222"
    prxserver_config.vm.network "public_network", bridge: 'br0', :mac => '000000250122'
    prxserver_config.vm.synced_folder "saltstack/salt/", "/srv/salt"
    prxserver_config.vm.synced_folder "saltstack/pillar/", "/srv/pillar"
    prxserver_config.vm.provision :shell, :path => "scripts/bootstrap_master.sh"
  end

  config.vm.define :labor do |labor_config|
    labor_config.vm.box = "ubuntu/precise64"
    labor_config.vm.host_name = 'labor.local'
    labor_config.vm.network "private_network", ip: "192.168.1.40"
    labor_config.vm.network "public_network", bridge: 'br0', :mac => '000000250140'
    labor_config.vm.provision :shell, :path => "scripts/bootstrap_client.sh"
  end

end
