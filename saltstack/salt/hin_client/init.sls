{% if pillar.get('hin_clients', false) %}
include:
  - users
  - hin_client.install
{% endif %}
