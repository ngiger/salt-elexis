{% if grains.lsb_distrib_codename == 'jessie' %}
jessie-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Wheezy Backports
    - name: deb http://ftp.ch.debian.org/debian jessie-backports main
    - file: /etc/apt/sources.list.d/jessie-backports.list
{% endif %}

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
