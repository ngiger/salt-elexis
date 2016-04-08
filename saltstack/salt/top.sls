base:
  'labor*':
    - common
    - homes.mount
    - elexis
    - unity
    - server.idmap
    - sever.db
    - locale
    - hin-client
  "{{ pillar['server.name']}}*":
    - common
    - server.unattended_upgrades
    - server.nfs
