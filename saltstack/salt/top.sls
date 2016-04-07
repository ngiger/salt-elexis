base:
  'labor*':
    - common
    - homes.mount
    - elexis
    - unity
    - server.idmap
    - sever.db
    - locale
  "{{ pillar['server.name']}}*":
    - common
    - server.unattended_upgrades
    - server.nfs
