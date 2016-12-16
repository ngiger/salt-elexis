{% set the_role = salt['grains.get']('roles', '') %}

base:
{% if the_role %}
  'roles:mpc_server':
    - match: grain
    - mpc
{% endif %}
  '*':
    - common
    - rsnapshot_home
    - network
    - users
  'inactive':
    - hinclient
    - goodies
