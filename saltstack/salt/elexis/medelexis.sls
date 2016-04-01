accept-java-license:
  debconf.set:
    - name: oracle-java8-installer
    - data:
        shared/accepted-oracle-license-v1-1: {'type': boolean, 'value': true}

get_key:
  cmd.run:
    - name: sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C2518248EEA14886

ppa-java:
  pkgrepo.managed:
    - keyid: C2518248EEA14886
    - keyserver: keyserver.ubuntu.com
    - humanname: webupd8team
    - name: deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main
    - require_in:
      - pkg: java

java:
  pkg.latest:
    - name: oracle-java8-installer
    - require:
      - debconf: accept-java-license