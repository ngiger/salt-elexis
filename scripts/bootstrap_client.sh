#!/bin/bash
if [ -z "$1" ]; then
  master="localhost"
  echo "Using default IP ${master} for salt master"
else
  master="$1"
  echo "Salt master is set to ${master}"
fi

release=`lsb_release --codename --short`
export DEBIAN_FRONTEND=noninteractive

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
elif [ "$release" == "precise" -o "$release" == "rosa" ]
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
  sudo apt-get update --quiet
  sudo apt-get install --no-install-recommends --quiet --yes salt-common salt-minion
else
  echo salt-minion already installed
fi

grep '^master' /etc/salt/minion
if [ $? -ne 0 ]
then
  # master IP must be in sync between Vagrantfile, scripts/bootstrap_client.sh and scripts/bootstrap_master.sh
  printf "master: ${master}\nstartup_states: sls\nsls_list:\n - server.nfs" | sudo tee /etc/salt/minion
  sudo service salt-minion restart
fi
