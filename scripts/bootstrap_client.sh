#!/bin/bash
release=`lsb_release --codename --short`

if [ "$release" == "jessie" -o   "$release" == "wheezy" ]
then
  echo release is $release
  version2install="2015.8.7*"
  if [ ! -f /etc/apt/sources.list.d/salt.list ]
  then
    echo "deb http://debian.saltstack.com/debian $release-saltstack main" | sudo tee /etc/apt/sources.list.d/salt.list
    wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | sudo apt-key add -
  fi
  found=`dpkg -l salt-minion | egrep "${version2install}"`
elif [ "$release" == "precise" ]
  then
  if [ ! -f /etc/apt/sources.list.d/salt.list ]
  then
    sudo add-apt-repository ppa:saltstack/salt
  fi
  found=`dpkg -l salt-minion`
else
  echo unknown release $release
  exit 2
fi

if [ -z "$found" ]
then
  echo salt-minion not yet installed
  sudo apt-get update
  sudo apt-get install -y salt-common salt-minion
else
  echo salt-minion already installed
fi

grep '^master' /etc/salt/minion
if [ $? -ne 0 ]
then
  echo "master: 192.168.1.222" | sudo tee --append /etc/salt/minion
  sudo service salt-minion restart
fi
