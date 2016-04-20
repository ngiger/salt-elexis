{% if grains.lsb_distrib_codename == 'jessie' and grains.lsb_distrib_id == 'Debian' %}
jessie-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Jessie Backports
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
{% if grains.os_family == 'Debian' %}
    - dlocate
{% endif %}
