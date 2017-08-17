{% if grains.lsb_distrib_codename == 'jessie' and grains.lsb_distrib_id == 'Debian' %}
jessie-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Jessie Backports
    - name: deb http://ftp.ch.debian.org/debian jessie-backports main
    - file: /etc/apt/sources.list.d/jessie-backports.list

saltstack-pkgrepo:
  pkgrepo.managed:
    - humanname: Salt Debian Repository
    - name: "deb https://repo.saltstack.com/apt/{{grains.os_family.lower()}}/{{grains.osmajorrelease}}/{{grains.osarch}}/archive/2016.11.1 {{grains.lsb_distrib_codename}} main"
    - file: /etc/apt/sources.list.d/saltstack.list
{% endif %}

# https://docs.saltstack.com/en/latest/faq.html#id16
salt-minion:
  pkg.latest:
    - name: salt-minion
    - order: last
#  service.running:
#    - name: salt-minion
#    - require:
#      - pkg: salt-minion
  cmd.run:
    - name: echo service salt-minion restart | at now + 1 minute
    - onchanges:
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
    - iotop
    - fish
    - git
    - vim-nox
{% if grains.os_family == 'Debian' %}
    - dlocate
{% endif %}

