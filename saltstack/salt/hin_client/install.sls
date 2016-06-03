# The *.hin file must be create on Windows-PC found under C:\Users\xx\AppData\Roaming\HIN\HIN Client

{% if grains.osfullname == 'Debian' %}
  {% set mail_pkg = "icedove-l10n-de" %}
  {% set mail_dir_name = ".icedove" %}
{% elif grains.osfullname == 'Ubuntu' %}
  {% set mail_pkg = "thunderbird-locale-de" %}
  {% set mail_dir_name = ".thunderbird" %}
{% endif %}
{% set hin_passphrase_replace = false %}
hin_client:
  pkg.installed:
    - refresh: False
    - pkgs:
      - inetutils-inetd
      - redir
      - {{mail_pkg}}
{% for id, client in pillar.get('hin_clients',{}).iteritems() %}
    {% if client.hin_passphrase_replace is defined %}
      {% set hin_passphrase_replace = client.hin_passphrase_replace %}
    {% endif %}

g_{{client.hin_login}}:
  group.present:
    - name: {{client.hin_login}}
    - gid: {{client.uid}}

  user.present:
    - name: {{client.hin_login}}
    - uid: {{client.uid}}
    - gid: {{client.uid}}

{{client.hin_login}}_hin_client:
  archive.extracted:
    - name: /home/{{client.hin_login}}
    - archive_user: {{client.hin_login}}
    - source: https://download.hin.ch/download/distribution/install/1.5.1-23/HINClient_unix_1_5_1-23.tar.gz
    - source_hash: sha512=c5315ca068efbd03977f2b113e894b39463cc1fc91d199f81c51b8143b642377c21e3613fe1cbf7b07591cbe2d7f3b0fade80f946e3cabc6329a69b0cd91776c
    - archive_format: tar
    - tar_options: vz
    - if_missing: /home/{{client.hin_login}}/HIN Client/hinclient
    - require:
        - user:  {{client.hin_login}}

/home/{{client.hin_login}}:
  file.directory:
    - recurse:
      - user
      - group
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}

/home/{{client.hin_login}}/{{client.hin_login}}.hin:
  file.managed:
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}
    - mode: 600
    - source: {{client.hin_identity_file}}

/home/{{client.hin_login}}/passphrase.txt:
  file.managed:
    - replace: {{hin_passphrase_replace}}
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}
    - mode: 600
    - contents:
      - {{client.hin_passphrase}}

/home/{{client.hin_login}}/.hinclient-service-parameters.txt:
  file.managed:
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}
    - mode: 600
    - contents:
      - "keystore=/home/{{client.hin_login}}/{{client.hin_login}}.hin"
      - "passphrase=/home/{{client.hin_login}}/passphrase.txt"

inetd_{{client.hin_login}}:
  file.blockreplace:
    - name: /etc/inetd.conf
    - marker_start: "# BLOCK TOP : salt managed zone {{client.hin_login}}: please do not edit"
    - marker_end: "# BLOCK BOTTOM : end of salt managed zone {{client.hin_login}}: --"
    - show_changes: True
    - append_if_not_found: True
    - content: "# Redir config for sharing local HIN Client {{client.hin_login}}\n
        {{client.http_port}} stream tcp nowait root /usr/bin/redir --lport={{client.http_port}} --cport=5016 --caddr=localhost --inetd\n
        {{client.smtp_port}} stream tcp nowait root /usr/bin/redir --lport={{client.smtp_port}} --cport=5018 --caddr=localhost --inetd\n
        {{client.pop3_port}} stream tcp nowait root /usr/bin/redir --lport={{client.pop3_port}} --cport=5019 --caddr=localhost --inetd\n
        {{client.imap_port}} stream tcp nowait root /usr/bin/redir --lport={{client.imap_port}} --cport=5020 --caddr=localhost --inetd\n"
# redir options are
# --caddr Specifies remote host to connect to. (localhost if omitted)
# --cport Specifies port to connect to.
# --lport Specifies port to listen for connections on (when not running from inetd)

service-inetutils-inetd-{{client.hin_login}}:
  service.running:
    - name: inetutils-inetd
    - watch:
      - file: /etc/inetd.conf

{% endfor %}

{% for hin_login, username in salt['pillar.get']('users_for_hinclients', {}).iteritems() %}
  {% for a_user in username %}
    {% for user_def in pillar['users'] %}
      {% if (a_user == user_def.name) %}
        {% if user_def.home is defined %}
        {% set home_dir = user_def.home %}
        {% else %}
        {% set home_dir = '/home/'+user_def.name %}
        {% endif %}

/usr/local/bin/restart_{{hin_login}}_hin_client_{{a_user}}:
  file.managed:
    - user: {{a_user}}
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - 'logger restarting HIN client for {{hin_login}}'
      - 'sudo -Hu {{hin_login}} /home/{{hin_login}}/HIN\ Client/hinclientservice restart'

{{home_dir}}/.config/autostart/hin_client:
  file.managed:
    - user: {{a_user}}
    - mode: 664
    - makedirs: true
    - require:
      - user: {{a_user}}
    - contents:
      - "[Desktop Entry]"
      - Type=Application
      - Exec=/usr/local/bin/restart_{{hin_login}}_hin_client
      - Hidden=false
      - NoDisplay=false
      - X-GNOME-Autostart-enabled=true
      - Name[de_CH]=HIN_Client_ikgiger
      - Name=HIN_Client_ikgiger
      - Comment[de_CH]=HIN-client neu starten
      - Comment=HIN-client neu starten

/etc/sudoers.d/{{a_user}}_hin_client:
  file.managed:
    - mode: 440
    - contents:
      - "{{a_user}}               ALL=(ALL:ALL) NOPASSWD:/usr/local/bin/restart_{{hin_login}}_hin_client"
      - '{{a_user}},{{hin_login}} ALL=(ALL:ALL) NOPASSWD:/home/{{hin_login}}/HIN\ Client/hinclientservice'

{{home_dir}}/{{mail_dir_name}}/{{a_user}}.hin:
  file.directory:
    - makedirs: true
    - user:  {{a_user}}
    - group:  {{a_user}}

{{home_dir}}/{{mail_dir_name}}/profiles.ini:
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
      - Path={{a_user}}.hin
      - Default=1

{{home_dir}}/{{mail_dir_name}}/{{a_user}}.hin/prefs.js:
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
