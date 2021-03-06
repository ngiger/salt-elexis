
/etc/sudoers.d/nopasswd:
{% if pillar.get('sudo', {}).get('no_passwd', false) %}
  file.managed:
    - mode: 440
    - contents:
      - "# managed by salt"
      - '%sudo ALL = (ALL) NOPASSWD: ALL'
{% else %}
  file.absent
{% endif %}

{% for user in pillar.get('users_absent', []) %}
user_{{user.name}}:
  user.absent:
    - name: {{user.name}}
    {% if user.get('purge', False) %}
    - purge: True
    {% endif %}
{% endfor %}


{% for group in pillar.get('groups', []) %}
{{group.name}}:
  group.present:
    - name: {{group.name}}
    {% if group.gid is defined %}
    - gid: {{group.gid}}
    {% endif %}
    {% if group.system is defined %}
    - system: {{group.system}}
    {% endif %}
{% endfor %}

{% for user in pillar['users'] %}
group_{{user.name}}:
  group.present:
    - name: {{user.name}}
    {% if user.gid is defined %}
    - gid: {{user.gid}}
    {% endif %}

  user.present:
    - enforce_password: false
    - shell: /bin/bash
    # initial password is set to elexis, generated with the commad, where is the salt
    # python -c "import crypt, getpass, pwd; print crypt.crypt('elexis', '\$6\$Dwn/RN6q\$')"
    # or with alt-call random.shadow_hash 'Dwn/RN6q' 'elexis' sha512
    - password: '$6$Dwn/RN6q$H38lUgjc0AEmXMu.V3nGN/CmwbROmV3FtZ26y7iAMD3gKzHJUG.FviYSxXmdCa96hca3RRpi87lMp99RZzN5.1'
    - enforce_password: false # Users should be able to change their password as they want
    {% if user.fullname is defined %}
    - fullname: "{{user.fullname}}"
    {% endif %}
    - name: {{user.name}}
    {% if user.uid is defined %}
    - uid: {{user.uid}}
    {% endif %}
    {% if user.gid is defined %}
    - gid: {{user.gid}}
    {% endif %}
    {% if user.groups is defined %}
    - groups:
      {% for group in user.groups %}
      - {{group}}
      {% endfor %}
    {% endif %}
    - require:
      - group: {{user.name}}
  {% if user.get('home', False) and grains.get('host') != pillar.get('server', {})['name'] %}
    - home: {{user.home}}
    - createhome: false
  file.directory:
    - name:  {{user.home}}
    - user:  {{user.name}}
    - group: {{user.name}}
    - require:
        - user: {{user.name}}
        - group: {{user.name}}
  {% endif %}
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

