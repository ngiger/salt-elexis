{% if pillar.get('hin_client', false) %}
include:
  - users
  - hin-client.install
{% endif %}
