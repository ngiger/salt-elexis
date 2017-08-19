# The *.hin file must be create on Windows-PC found under C:\Users\xx\AppData\Roaming\HIN\HIN Client

{% if grains.osfullname == 'Debian' %}
  {% set mail_pkg = "icedove-l10n-de" %}
{% elif grains.osfullname == 'Ubuntu' %}
  {% set mail_pkg = "thunderbird-locale-de" %}
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
    # via https://download.hin.ch/index_de.html
    # - source: https://download.hin.ch/download/distribution/install/1.5.1-23/HINClient_unix_1_5_1-23.tar.gz
    - source: https://download.hin.ch/download/distribution/install/1.5.3-50/HINClient_unix_1_5_3-50.tar.gz
    # - source_hash: sha512=c5315ca068efbd03977f2b113e894b39463cc1fc91d199f81c51b8143b642377c21e3613fe1cbf7b07591cbe2d7f3b0fade80f946e3cabc6329a69b0cd91776c
    # proxy port auf 5016 keine proxy für localhost;
    - source_hash: sha512=02729b1f9e7366beb35a71472f5eeb9e888ff6bba9d5521f514ca839c7fd20bd384f34dacd4395e70ee69ff002a80427fc08e4c0130ff4a6e43f735cb3b39e88
    - archive_format: tar
    - options: vz
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
    - marker_start: "# BLOCK TOP : salt managed zone: please do not edit"
    - marker_end: "# BLOCK BOTTOM : end of salt managed zone: --"
    - show_changes: True
    - append_if_not_found: True
    # for some unknown reason I cannt place the content as an array. It must be place on a very long line.
    - content: "# Redir config for sharing local HIN Client HIN-Login is {{client.hin_login}}\n{{client.http_port}} stream tcp nowait root /usr/bin/redir --lport={{client.http_port}} --cport=5016 --caddr=localhost --inetd # http\n{{client.smtp_port}} stream tcp nowait root /usr/bin/redir --lport={{client.smtp_port}} --cport=5018 --caddr=localhost --inetd # smtp\n{{client.pop3_port}} stream tcp nowait root /usr/bin/redir --lport={{client.pop3_port}} --cport=5019 --caddr=localhost --inetd # pop3\n{{client.imap_port}} stream tcp nowait root /usr/bin/redir --lport={{client.imap_port}} --cport=5020 --caddr=localhost --inetd # imap\n"
# redir options are
# --caddr Specifies remote host to connect to. (localhost if omitted)
# --cport Specifies port to connect to.
# --lport Specifies port to listen for connections on (when not running from inetd)
# echo "$REDIR_HTTP stream tcp nowait root /usr/bin/redir --lport=$REDIR_HTTP --cport=5016 --caddr=localhost --inetd" >> /etc/inetd.conf

service-inetutils-inetd-{{client.hin_login}}:
  service.running:
    - name: inetutils-inetd
    - watch:
      - file: /etc/inetd.conf
{% set restart_exe = '/usr/local/bin/restart_hin_client_' + client.hin_login %}
{{restart_exe}}:
  file.managed:
    - user: {{client.hin_login}}
    - mode: 755
    - contents:
      - '#!/bin/bash'
      - 'logger {{restart_exe}}'
      - 'sudo /home/{{client.hin_login}}/HIN\ Client/hinclientservice stop'
      - 'sudo -Hu {{client.hin_login}} /home/{{client.hin_login}}/HIN\ Client/hinclientservice restart'
      - 'sudo -Hu {{client.hin_login}} /home/{{client.hin_login}}/HIN\ Client/hinclientservice status'
{% endfor %}

