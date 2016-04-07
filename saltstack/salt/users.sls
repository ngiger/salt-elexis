{% for user in pillar.get('users_absent', []) %}
user_{{user.name}}:
  user.absent:
    - name: {{user.name}}
    {% if user.get('purge', False) %}
    - purge: True
    {% endif %}
{% endfor %}

{% for user in pillar['users'] %}
user_{{user.name}}:
  group.present:
    - name: {{user.name}}
    - gid: {{user.gid}}

  user.present:
    - enforce_password: false
    - shell: /bin/bash
    # initial password is set to elexis
    - password: '$6$Dwn/RN6q$H38lUgjc0AEmXMu.V3nGN/CmwbROmV3FtZ26y7iAMD3gKzHJUG.FviYSxXmdCa96hca3RRpi87lMp99RZzN5.1'
    - fullname: "{{user.name}}"
    - name: {{user.name}}
    - uid: {{user.uid}}
    - gid: {{user.gid}}
    {% if user.get('groups', user.name) %}
    - optional_groups:
      {% for group in user.get('groups', user.name) %}
      - {{group}}
      {% endfor %}
    {% endif %}
    - require:
      - group: user_{{user.name}}
    {% if user.get('home', False) and grains.get('id') != 'prxserver.local' %}
    - home: {{user.home}}
  file.directory:
    - name:  {{user.home}}
    - user:  {{user.name}}
    - group: {{user.gid}}
    - recurse:
        - user:
        - group:
    {% endif %}

{% endfor %}

/etc/sudoers.d/nopasswd:
  file.managed:
    - mode: 440
    - contents:
      - "# managed by salt"
      - '%sudo ALL = (ALL) NOPASSWD: ALL'

