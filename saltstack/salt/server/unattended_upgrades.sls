# Followed https://blog.talpor.com/2014/07/saltstack-beginners-tutorial/
# Other proposed: http://blog.viraptor.info/post/75262988169/ubuntu-unattended-upgrades-the-salt-way
unattended-upgrades-on: # State ID
  pkg.installed:
    - pkgs:
      - unattended-upgrades
  file.uncomment:
    - name: /etc/apt/apt.conf.d/50unattended-upgrades
    - regex: 'Unattended-Upgrade::Mail .*;'
    - char: '//'
/etc/apt/apt.conf.d/20auto-upgrades:
  file.managed:
  # - name: /etc/apt/apt.conf.d/20auto-upgrades
    - source: salt://server/unattended_upgrades.txt

