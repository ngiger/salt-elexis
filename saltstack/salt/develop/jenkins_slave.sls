maven:
  pkg:
    - installed
    - version: 3.0.5-3

bundler:
  pkg:
    - installed

xvfb:
  pkg:
    - installed

python-pip:
  pkg.installed

ruby-pg:
  pkg.installed

locales-all:
  pkg.installed

libmysqlclient-dev:
  pkg.installed

import-docker-key:
  cmd.run:
    - name: "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && touch /etc/apt/58118E89F3A912897C070ADBF76221572C52609D.key"
    - creates: /etc/apt/58118E89F3A912897C070ADBF76221572C52609D.key

docker-pkgrepo:
  pkgrepo.managed:
    - humanname: Docker Debian Repository
    - name: "deb https://apt.dockerproject.org/repo {{grains.os_family.lower()}}-{{grains.lsb_distrib_codename}} main"
    - file: /etc/apt/sources.list.d/docker.list

docker-engine:
  pkg.installed:
    - name: docker-engine
  service.running:
    - name: docker
    - require:
      - pkg: docker-engine

docker-composer:
  pip.installed:
   - name: docker-compose >= 1.9.0
   - require:
      - pkg: docker-engine
      - pkg: python-pip

ngiger/jubula_runner:0.4.1:
  dockerng.image_present

postgres:9.1:
  dockerng.image_present

mysql:5.7:
  dockerng.image_present

user_jenkins_slave:
  user.present:
    - name: jenkins_slave
    - fullname: Jenkins Slave for Elexis OpenSource
    - shell: /bin/bash
    - home: /home/jenkins_slave
    - uid: 1201
    - gid: 1201
    - groups:
      - docker
    - require:
      - pkg: docker-engine

/opt/ci:
  file.directory:
    - user: root
    - group: root

/opt/ci/jenkins_slave:
  file.directory:
    - user: jenkins_slave
    - group: jenkins_slave
    - dir_mode: 755
    - file_mode: 644


