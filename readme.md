# Setup of an Elexis IT infrastructure using salt

## Getting started using two virtual machines

The easiest way is to follow the following steps to get a test environment up and running using VirtualBox and Vagrant.

You need to install:

* Ruby: see https://www.ruby-lang.org/
* Vagrant: see https://www.vagrantup.com/docs/installation/
* Virtualbox: see https://www.virtualbox.org/
* git: see https://git-scm.com/

Once you have installed the prerequisites, you need a copy of this project.

Please invest some time into grasping the basic concept of salt. I recommend its excellent documentation at https://docs.saltstack.com/en/latest/ and the following lightning talk http://talks.caktusgroup.com/lightning-talks/2013/salt-master/

There is Vagrantfile which defines two virtual machines (VM) , one called ElexisServerDemo and another ElexisLaborDemo. Before setting up ElexisLaborDemo we provision all needed stuff in the ElexisServerDemo.

To start the ElexisServerDemo, execute on the command line

````
git clone https://github.com/ngiger/salt-elexis /path/checkout/elexis-salt
cd /path/checkout/elexis-salt
vagrant up ElexisServerDemo
````

This will download a Vagrant box (aka virtual machine image of about 370 MB), which is essentially a x86-64bit Debian Server image.

As last part of the setup the Vagrantfile specifies to run the `scripts/bootstrap_master.sh`. On a real server you had to download and run this script by hand. If you have problems, have a look at logs/server.up.log.

Now we are ready to log into the server by calling `vagrant ssh ElexisServerDemo`. You will be logged in as user vagrant with the password vagrant. We will verify and finish the initial setup for salt. A log file of the following commands can be found under logs/server.ssh.log.

````
salt --version
sudo systemctl status salt-master
sudo systemctl status salt-minion
sudo salt-key -L
sudo salt-key -A
````

Answer 'Y' to the question `Proceed? [n/Y]`. Now the ElexisServerDemo is configured to listen as salt-minion (client) to itself, as our `scripts/bootstrap_master.sh` had added the line `scripts/bootstrap_master.sh` to /etc/salt/minion.

Calling `sudo salt-call pillar.items` shows all the configuration variables (which were defined via the files placed under saltstack/pillar)

Calling `sudo salt-call grains.items` shows the available environments variables describing the running host, e.g. CPU, memory, network.

Calling `sudo salt-call state.highstate` will apply all states. But before call `sudo salt-call state.apply common test=true` to see what would happen if you wanted to apply just the state common. Proceed now with

bc. sudo salt-call state.apply common
sudo salt-call state.highstate

The last command will take a long time, as it has to download a lot of packages. I remarked that the oracle installer alone neede more then 40 minutes to complete.

Calling `sudo salt-call state.highstate` a second times will take a few seconds, as it will check whether everything is okay. If we have no problem in our setup (pillar/states), we find a the end `Succeeded: 61 (changed=0)` and `Failed:     0`

Our server setup is now okay. Open a second command shell and type `vagrant up ElexisLaborDemo` (log see logs/labor.up.log)

Before we can provision the ElexisLaborDemo, we must first accept its key on the ElexisServerDemo. This snippet show how it is done:

````
vagrant@ElexisServerDemo ~> sudo salt-key -L
Accepted Keys:
ElexisServerDemo
Denied Keys:
Unaccepted Keys:
ElexisLaborDemo
Rejected Keys:
vagrant@ElexisServerDemo ~> sudo salt-key -A
The following keys are going to be accepted:
Unaccepted Keys:
ElexisLaborDemo
Proceed? [n/Y] y
Key for minion ElexisLaborDemo accepted.
````

This will fail with a notice like `Failed:    11` as we need a more recent Linux kernel to mount our NFSv4 shares from the PraxisServerDemo. Therefore we `exit` this shell and call `vagrant reload ElexisLaborDemo` to restart ElexisLaborDemo.

Now lets run `vagrant ssh ElexisServerDemo` a second time and call again `sudo salt-call state.highstate`



### Using real machines

* Client (Either Debian wheezy or Ubuntu precise)
** get `install_client.sh`, eg. by calling `wget https://raw.githubusercontent.com/ngiger/salt-elexis/master/scripts/bootstrap_client.sh` and execute it to install salt-minion.

Set the /etc/salt/minion to something like

````
master: 192.168.1.90 # IP address or name, default is salt
state_output: mixed
````


* Server (We assume debian jessie). Here we install salt-master and salt-minion to be able to configure the server, too.
** Call `git clone URL /srv/salt`
** execute `/srv/salt/scripts/install_master.sh` it to install salt-master and salt-minion

We want to be able to configure the salt server, too, therefore the /etc/salt/minion to something 

````
master: localhost
state_output: mixed
````

and the /etc/salt/master to something like this (which will allow you to override the defaults)

````
file_roots:
  base:
    - /home/some_user/salt
    - /srv/salt/saltstack/salt
pillar_roots:
  base:
    - /etc/salt/pillar
````

Also I recommond to add a top.sls in /home/some_user/salt with a content like this, which should reflect your environment.

````
base:
  'ubuntu*':
    - common
    - homes.mount
    - elexis
    - unity
    - server.idmap
    - locale
    - hin-client
  "{{ pillar['server.name']}}*":
    - common
    - server.unattended_upgrades
    - server.nfs
    - server.db
````

It might be a good idea each part seperatley (first on the server, then on the clients) using e.g. `sudo salt-call state.apply common Test=true`.
This will list

### Adding and verifying minion keys on the master

* In the output `sudo salt-key -L` you should  see a line like `Unaccepted Keys:` followed `ElexisLaborDemo.local`
* Run `sudo salt-key -A` and accept the keys
* Run `sudo salt '*' test.ping` to verify that you can
* Run `sudo salt-call pillar.items ` to see all variables of your configuration
* `sudo salt-call state.highstate` # will take a long time to download/install all stuff. It must be called first on the master to prepare all the needed stuff like NFS4-server for the clients
* `sudo salt '*' state.highstate` # will take a long time to download/install all stuff

### NFSv4 setup

This was a little bit tricky. Solved by:
* Server must be configured via salt before the client minions
* Client/server need a linux kernel >= 3.4
* Client must be reboot (not yet automated) after upgrading to the new linux kernel

### Aufsetzen des HIN-Clients

Vorgängig muss aus einem Windows oder Mac der Zugang zum HIN konfiguriert werden, da HIN leider Linux nur halbwegs unterstützt.

Im Moment muss der HIN-Client noch von Hand gestartet werden. Dazu /usr/local/bin/restart_<HIN login>_hin_client aufrufen. Sollte man bei Gelegenheit als Service oder Desktop verpacken.

### letsencrypt

Damit dies  läuft müssen einen Eintrag für letsencrypt-formula im /etc/salt/master des Salt-Master-Host vorhanden sein und die entsprechenden Pillar-Einträge vorhanden sein.

````
fileserver_backend:
  - roots
  - git
file_roots:
  base:
    - /srv/salt
pillar_roots:
  base:
    - /srv/pillar
gitfs_remotes:
  - https://github.com/saltstack-formulas/letsencrypt-formula.git
````

### Unresolved problems

* Running `locale-gen de_CH.UTF-8` in locales.sls freezes the whole system. Must call this command by hand. Why?
* Don't know how to tell salt that installing the package unattended-upgrades creates 50unattended-upgrade

### Core features

* NFSv4 server/client
* Setup of user homes
* Installation of Elexis3 OpenSource. Creates Desktop icons
* Installation of MedElexis. License File and ZIP must reside on server. Creates Desktop icons.
* hinclient with setup of a corresponding thunderbird mail configuration
* ssmtp

### Optional features

* building Elexis-core/base from fork and a choosen branch/revision
* rsnapshot backup of all HOME directories
* dnsmask server
* dnsmask tftp server for Ubuntu netboot + installer preseeds
* elexis-cockpit. See https://github.com/elexis/elexis-cockpit
* letsenscrpt
** https://github.com/saltstack-formulas/letsencrypt-formula
** https://www.kunxi.org/blog/2015/12/lets-encrypt-with-saltstack/

### TODO

* Set default keyboard to Swiss German
* Don't ask for upgrade of Ubuntu from 12.04 -> 14.04
* Don't show users like vagrant; Ubuntu # It is enough to change them to user ids < 1000
* Add/remove apps from the Ubuntu sidebar
* rsnapshot (see TODO in saltstack/salt/rsnapshot/readme.textile)
* db backup
* wol (WakeOnLan)
* mysql
* dyndns
* Use docker containers for HIN-clients
* mediport plugin & MPCcommunicator
* nginx https://www.digitalocean.com/community/tutorials/saltstack-infrastructure-creating-salt-states-for-nginx-web-servers and https://github.com/saltstack-formulas/nginx-formula
* exim4/imap/courier mail
* hylafax ???? (FAX will be phased out by swisscom on January, 1, 2017)
