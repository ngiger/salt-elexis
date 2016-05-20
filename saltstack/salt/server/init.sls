include:
  - server.dnsmasq
{% if pillar.get('server.nfs', false) %}
  - server.idmap
  - server.nfs
{% endif %}
{% if pillar.get('server.postgresq', false) %}
  - server.postgresql
{% endif %}
  - server.letsencrypt
