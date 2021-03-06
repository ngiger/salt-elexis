base:
  '*':
    - common
   # now the stuff which must be only installed on the server
{% if grains.get('host') == pillar.get('server', {})['name'] %}
    - server.idmap
    - server.nfs
    - server.unattended_upgrades
    - server.db
{% else %}
   # now the stuff which must be only installed on the clients
    - homes.mount
    - unity
    - unity.lts_kernel
    - locale
{% endif %}
    - server.dnsmasq
    - server.apt-cacher-ng
    - elexis

{% if pillar.get('rsnapshot_backups', False) %}
    - rsnapshot
{% endif %}

{% if pillar.get('hin_clients', False) %}
    - hin_client
{% endif %}

{% if pillar.get('ssmtp', False) %}
    - apps.ssmtp
{% endif %}

{% if  pillar.get('letsencrypt', False) %}
    - letsencrypt.domains
{% endif %}

  'goodies':
    - elexis.build
