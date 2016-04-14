accept-java-license:
  debconf.set:
    - name: oracle-java8-installer
    - data:
        shared/accepted-oracle-license-v1-1: {'type': boolean, 'value': true}

get_key:
  cmd.run:
    - name: sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C2518248EEA14886

ppa-java:
{% if grains.osfullname == 'Ubuntu' %}
  pkgrepo.managed:
    - keyid: C2518248EEA14886
    - keyserver: keyserver.ubuntu.com
    - humanname: webupd8team
    - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu {{grains.lsb_distrib_codename}} main
    - require_in:
      - pkg: java
{% elif grains.osfullname == 'Debian' %}
  pkgrepo.managed:
    - keyid: C2518248EEA14886
    - humanname: webupd8team
    - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main
    - dist: trusty
    - file: /etc/apt/sources.list.d/webupd8team.list
    - gpgcheck: 1
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: java
{% else  %}
    - name: "#Unknown OS {{grains.os}}/{{grains.osfullname}} {{grains.lsb_distrib_codename}}"
{% endif %}

java:
  pkg.latest:
    - name: oracle-java8-installer
    - refresh: false
    - require:
      - debconf: accept-java-license