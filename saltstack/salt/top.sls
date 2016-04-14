base:
  'labor*':
    - common
    - homes.mount
    - elexis
    - unity
    - server.idmap
    - locale
    - hin-client
    - apps.ssmtp
  "{{ pillar['server.name']}}*":
    - common
    - server.unattended_upgrades
    - server.nfs
    - server.db
#{% if  pillar.get('letsencrypt', {}) %}
    - letsencrypt.domains
{% endif %}
