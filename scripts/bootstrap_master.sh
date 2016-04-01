#!/bin/bash
release=`lsb_release --codename --short`

if [ ! -f /etc/apt/sources.list.d/salt.list ]
then
  echo "deb http://debian.saltstack.com/debian $release-saltstack main" | sudo tee /etc/apt/sources.list.d/salt.list
  wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | sudo apt-key add -
fi
found=`dpkg -l salt-master | egrep "${version2install}"`
if [ -z "$found" ]
then
  echo salt-master not yet installed
  sudo apt-get update
  sudo apt-get install -y salt-common salt-master salt-minion
else
  echo salt-master already installed
fi
grep '^master' /etc/salt/minion
if [ $? -ne 0 ]
then
  echo "master: 192.168.1.222" | sudo tee --append /etc/salt/minion
  sudo service salt-minion restart
fi
