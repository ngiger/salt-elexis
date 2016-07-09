# The *.hin file must be create on Windows-PC found under C:\Users\xx\AppData\Roaming\HIN\HIN Client

{% if grains.osfullname == 'Debian' %}
  {% set mail_pkg = "icedove-l10n-de" %}
  {% set mail_dir_name = ".icedove" %}
{% elif grains.osfullname == 'Ubuntu' %}
  {% set mail_pkg = "thunderbird-locale-de" %}
  {% set mail_dir_name = ".thunderbird" %}
{% endif %}
{% set hin_passphrase_replace = false %}
{% for hin_login, username in salt['pillar.get']('users_for_hinclients', {}).iteritems() %}
  {% for a_user in username %}
    {% for user_def in pillar['users'] %}
      {% if (a_user == user_def.name) %}
        {% if user_def.home is defined %}
        {% set home_dir = user_def.home %}
        {% else %}
        {% set home_dir = '/home/'+user_def.name %}
        {% endif %}

{{home_dir}}/.config/autostart/hin_client-{{hin_login}}:
  file.managed:
    - user: {{a_user}}
    - mode: 664
    - makedirs: true
    - require:
      - user: {{a_user}}
    - contents:
      - "[Desktop Entry]"
      - Type=Application
      - Exec={{restart_exe}}
      - Hidden=false
      - NoDisplay=false
      - X-GNOME-Autostart-enabled=true
      - Name[de_CH]=HIN_Client_ikgiger
      - Name=HIN_Client_ikgiger
      - Comment[de_CH]=HIN-client neu starten
      - Comment=HIN-client neu starten

/etc/sudoers.d/{{a_user}}_hin_client_{{hin_login}}:
  file.managed:
    - mode: 440
    - contents:
      - '{{a_user}},{{hin_login}} ALL=(ALL:ALL) NOPASSWD:/home/{{hin_login}}/HIN\ Client/hinclientservice'

{{home_dir}}/{{mail_dir_name}}/{{hin_login}}.hin:
  file.directory:
    - makedirs: true
    - user:  {{a_user}}
    - group:  {{a_user}}

{{home_dir}}/{{mail_dir_name}}/{{hin_login}}-profile.ini:
  file.managed:
    - user:  {{a_user}}
    - group:  {{a_user}}
    - contents:
      - "[General]"
      - StartWithLastProfile=1
      -
      - "[Profile0]"
      - Name=default
      - IsRelative=1
      - Path={{hin_login}}.hin
      - Default=1

# TODO: This must be done very differntly!
{{home_dir}}/{{mail_dir_name}}/{{hin_login}}.hin/prefs.js:
  file.managed:
    - replace: {{hin_passphrase_replace}}
    - user:  {{a_user}}
    - source: salt://hin_client/file/prefs.js
    - template: jinja
    - require:
      - file: {{home_dir}}/{{mail_dir_name}}/{{a_user}}.hin
    - defaults:
        user_name: {{a_user}}
        home: {{home_dir}}
        hin_login: {{hin_login}}
        {% for id, client in pillar.get('hin_clients',{}).iteritems() %}
          {% if (hin_login == client.hin_login) %}
        client: {{client}}
          {% endif %}
        {% endfor %}
      {% endif %}
    {% endfor %}
  {% endfor %}
{% endfor %}
