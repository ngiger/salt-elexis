{% for user in pillar.get('users_absent', []) %}
user_{{user.name}}:
  user.absent:
    - name: {{user.name}}
    {% if user.get('purge', False) %}
    - purge: True
    {% endif %}
{% endfor %}

{% for user in pillar['users'] %}
{{user.name}}:
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
      - group: {{user.name}}
    {% if user.get('home', False) and grains.get('id') != pillar.get('server', {})['name'] %}
    - home: {{user.home}}
    - createhome: true
    {% endif %}
  file.directory:
    - name:  {{user.home}}
    - user:  {{user.name}}
    - group: {{user.name}}
    - require:
        - user: {{user.name}}
        - group: {{user.name}}
    - recurse:
        - user
        - group

#----------------- Add git repo for some users -------------------------------------
  # While developping it is handy to trace all changes in the the config directories of
  # of one (ore more) user homes.
  {% if user.get('git_setttings', false) %}
  git.present:
    - bare: false
    - name:  {{user.home}}
    - user: {{user.name}}
    - require:
        - user: {{user.name}}
  cmd.run:
    - cwd: {{user.home}}
    - user:  {{user.name}}
    - name: find . -iname ".gitignore|.local|.config|.gconf|.gnome" | xargs git add --all; git commit -m "Done"
    - on_change:
        - file: {{user.home}}
{{user.home}}/.gitignore:
  file.managed:
    - user: {{user.name}}
    - group: {{user.name}}
    - contents: |
       "HIN Client"
       .cache
       .medelexis-beta
       .nothing
  {% endif %}
#----------------- end git repo for some users -------------------------------------


{% endfor %}

/etc/sudoers.d/nopasswd:
  file.managed:
    - mode: 440
    - contents:
      - "# managed by salt"
      - '%sudo ALL = (ALL) NOPASSWD: ALL'

{% if false %}
{% endif %}