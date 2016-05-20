{% if grains.lsb_distrib_codename == 'jessie' and grains.lsb_distrib_id == 'Debian' %}
jessie-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Jessie Backports
    - name: deb http://ftp.ch.debian.org/debian jessie-backports main
    - file: /etc/apt/sources.list.d/jessie-backports.list
{% endif %}

salt-minion:
  pkg.installed:
{% if grains.lsb_distrib_codename == 'jessie' and grains.lsb_distrib_id == 'Raspbian' %}
    - version: 2015.5.3+ds-1~bpo8+1
{% elif grains.lsb_distrib_codename == 'jessie' and grains.lsb_distrib_id == 'Debian' %}
    - version: 2015.8.8+ds-1
{% endif %}
    - refresh: false
salt-minion-service:
  service.running:
    - name: salt-minion
    - watch:
      - pkg: salt-minion

common:
  pkg.installed:
  - refresh: false
  - pkgs:
    - acl
    - etckeeper
    - openssh-server
    - rsync
    - lftp
    - curl
    - htop
    - fish
    - git
    - vim-nox
{% if grains.os_family == 'Debian' %}
    - dlocate
{% endif %}

