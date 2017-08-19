{% if pillar.get('hin_clients', false) %}
include:
  - users
  - hin_client.services
  #  - hin_client.docker_composeng # run services inside docker compose
  - hin_client.thunderbird
{% endif %}
