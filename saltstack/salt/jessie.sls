jessie-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Wheezy Backports
    - name: deb http://ftp.ch.debian.org/debian jessie-backports main
    - file: /etc/apt/sources.list.d/jessie-backports.list
    - require_in:
      - pkg: git

git:
  pkg.latest:
    - fromrepo: jessie-backports
