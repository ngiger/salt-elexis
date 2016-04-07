# Followed https://blog.talpor.com/2014/07/saltstack-beginners-tutorial/
# Other proposed: http://blog.viraptor.info/post/75262988169/ubuntu-unattended-upgrades-the-salt-way
unattended-upgrades-on: # State ID
  pkg.installed:
    - name: unattended-upgrades

# Don't know how to tell salt that unattended-upgrades creates 50unattended-upgrade
{% if salt['file.file_exists']('/etc/apt/apt.conf.d/50unattended-upgrade') %}
/etc/apt/apt.conf.d/50unattended-upgrade:
  file.uncomment:
    - name: /etc/apt/apt.conf.d/50unattended-upgrade
    - require:
      - pkg: unattended-upgrades
    - regex: 'Unattended-Upgrade::Mail .*;'
    - char: '//'
{% endif %}

/etc/apt/apt.conf.d/20auto-upgrades:
  file.managed:
    - source: salt://server/file/unattended_upgrades.txt
    - require:
      - pkg: unattended-upgrades

