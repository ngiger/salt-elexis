# You have to download manually the Medelexis bootstrap to
# /srv/salt/ch.medelexis.application.product.Medelexis-linux.gtk.x86_64.zip
# and the license.xml to
# /srv/salt/license.xml
# Datei auf Windows-PC erstellt. Gefunden unter C:\Users\xx\AppData\Roaming\HIN\HIN Client
# we assume that the client.hin was conviert to xxd -p client.hin > client.hin.xxd
# reverse operation is cat  client.hin.xxd | xxd -r -pr > client.hin
# 107 lines

hin-client:
  pkg.installed:
    - refresh: False
    - pkgs:
      - inetutils-inetd
      - redir
      - thunderbird-locale-de

{% for client in pillar['hin_clients'] %}

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
    - if_missing: /home/{{client.hin_login}}/HIN Client/hinclient'
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
  cmd.run:
    - name: echo {{client.hin_identity}} | xxd -revert -plain > /home/{{client.hin_login}}/{{client.hin_login}}.hin
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}
    - mode: 600
    - creates: /home/{{client.hin_login}}/{{client.hin_login}}.hin

/home/{{client.hin_login}}/passphrase.txt:
  file.managed:
    - replace: False
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}
    - mode: 600
    - contents: {{client.hin_passphrase}}

/home/{{client.hin_login}}/.hinclient-service-parameters.txt:
  file.managed:
    - user: {{client.hin_login}}
    - group: {{client.hin_login}}
    - mode: 600
    - contents:
      - "keystore=/home/{{client.hin_login}}/{{client.hin_login}}.hin"
      - "passphrase=/home/{{client.hin_login}}/passphrase.txt"

inetd_{{client.hin_login}}:
  file.append:
    - name: /etc/inetd.conf
    - text: |
        # Redir config for sharing local HIN Client {{client.hin_login}}
        {{client.http_port}} stream tcp nowait root /usr/bin/redir --lport={{client.http_port}} --cport=5016 --caddr=localhost --inetd
        {{client.smtp_port}} stream tcp nowait root /usr/bin/redir --lport={{client.smtp_port}} --cport=5018 --caddr=localhost --inetd
        {{client.pop3_port}} stream tcp nowait root /usr/bin/redir --lport={{client.pop3_port}} --cport=5019 --caddr=localhost --inetd
        {{client.imap_port}} stream tcp nowait root /usr/bin/redir --lport={{client.imap_port}} --cport=5020 --caddr=localhost --inetd
# redir options are
# --caddr Specifies remote host to connect to. (localhost if omitted)
# --cport Specifies port to connect to.
# --lport Specifies port to listen for connections on (when not running from inetd)

inetutils-inetd:
  service.running:
    - watch:
      - file: /etc/inetd.conf

{% endfor %}

{% for hin_login, username in salt['pillar.get']('users_for_hinclients', {}).iteritems() %}
  {% for a_user in username %}
    {% for user_def in pillar['users'] %}
      {% if (a_user == user_def.name) %}
{{user_def.home}}/.config/autostart:
  file.directory:
    - user: {{a_user}}
/usr/local/bin/restart_{{hin_login}}_hin_client:
  file.managed:
    - user: {{a_user}}
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - 'logger retarting HIN client for {{hin_login}}'
      - 'sudo -Hu {{hin_login}} /home/{{hin_login}}/HIN\ Client/hinclientservice restart'

{{user_def.home}}/.config/autostart/hin_client:
  file.managed:
    - user: {{a_user}}
    - mode: 664
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

{{user_def.home}}/.thunderbird/{{a_user}}.hin:
  file.directory:
    - makedirs: true
    - user:  {{a_user}}
    - group:  {{a_user}}

{{user_def.home}}/.thunderbird/profiles.ini:
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

{{user_def.home}}/.thunderbird/{{a_user}}.hin/prefs.js:
  file.managed:
    - replace: false # we don't want to override the user made changes after the first installation
    - user:  {{a_user}}
    - source: salt://hin-client/file/prefs.js
    - template: jinja
    - require:
      - file: {{user_def.home}}/.thunderbird/{{a_user}}.hin
    - defaults:
        user_name: {{a_user}}
        home: {{user_def.home}}
        hin_login: {{hin_login}}
        {% for client in pillar['hin_clients'] %}
          {% if (hin_login == client.hin_login) %}
        client: {{client}}
          {% endif %}
        {% endfor %}
      {% endif %}
    {% endfor %}
  {% endfor %}
{% endfor %}