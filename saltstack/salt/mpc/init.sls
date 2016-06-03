# The *.hin file must be create on Windows-PC found under C:\Users\xx\AppData\Roaming\HIN\HIN Client

{% if grains.osfinger == 'Debian-7' or grains.osfinger == 'Debian-8' %}
  {% set jave_jre_pkg = 'openjdk-7-jre' %}
{% endif %}

{% if pillar.get('mpc', False) %} # and grains.host == pillar.get('server', {})['name']
{% set mpc = pillar.get('mpc') %}
{% set response_file = mpc.install_path+ '/install_mpc.response' %}
install_path:
  pkg.installed:
    - refresh: False
    - pkgs:
      - {{jave_jre_pkg}}
      - dos2unix
      - daemontools
mediport_user:
  user.present:
    - name: mediport
    - system: true

unzip_mpc:
  file.directory:
    - makedirs: true
    - name: {{mpc.install_path}}
  cmd.run:
    - cwd: {{mpc.install_path}}
    - name: "unzip {{mpc.zip_path}}"
    - creates: "{{mpc.install_path}}/MPCommunicator_V1.16.0.0.bin"
    - require:
        - user: mediport

response_file:
  file.managed:
    - name: {{response_file}}
    - contents:
      - '2' # english
      - '' # PRESS <ENTER> TO CONTINUE default is /root/
      - '{{mpc.install_path}}' # ENTER AN ABSOLUTE PATH, OR PRESS <ENTER> TO ACCEPT THE DEFAULT
      - 'Y' # IS THIS CORRECT? (
      - '{{mpc.install_path}}' # User Config. and Default Data Folder (DEFAULT: /opt/mpcdata)
      - '' # PRESS <ENTER> TO CONTINUE
      - 'Done'
    - require:
        - cmd: unzip_mpc

install_mpc:
  cmd.run:
    - cwd: {{mpc.install_path}}
    - name: "/bin/bash {{mpc.install_path}}/{{mpc.bin_name}} -i console < {{response_file}}; /usr/bin/dos2unix {{mpc.install_path}}/mpc.sh"
    - creates: "{{mpc.install_path}}/mpc.sh"
    - require:
        - cmd: unzip_mpc
        - file: response_file

# /usr/local/mediport/config/EAN2099988870017_mpg.keystore
keystore_mpc:
  file.managed:
    - name: {{mpc.install_path}}/config/EAN{{mpc.sender_ean}}_mpg.keystore
    - source: {{mpc.keystore}}
    - require:
      - cmd: install_mpc

{{mpc.install_path}}/config/mpcommunicator.config:
  file.managed:
    - source: salt://mpc/file/mpcommunicator.config.jinja
    - template: jinja
    - require:
      - cmd: install_mpc
      - file: keystore_mpc
    - defaults:
        mpc: {{mpc}}

/etc/systemd/system/mpc.service:
  file.managed:
    - contents:
      - '[Unit]'
      - Description=MediPort Communicator
      - After=syslog.target network.target
      - '[Service]'
      - EnvironmentFile=-/etc/default/ssh
      - ExecStart={{mpc.install_path}}/mpc.sh start
      - ExecStop={{mpc.install_path}}/mpc.sh stop
      - Type=forking
      - KillMode=process
      - Restart=on-failure
      - '[Install]'
      - WantedBy=multi-user.target
    - require:
      - cmd: install_mpc

service_mpc:
  service.running: # running or disabled
    - name: mpc
    - require:
      - file: /etc/systemd/system/mpc.service
      - file: {{mpc.install_path}}/config/mpcommunicator.config
{% set psql_prefix = 'psql --host=localhost -U ' + salt['pillar.get']('elexis:db_user')+ ' ' + salt['pillar.get']('elexis:db_main') + ' -c ' %}
ensure_mpc_install_dir:
  cmd.run:
    - name: "{{psql_prefix}} \"insert into config values('mpc/install_dir', '{{mpc.install_path}}', '1');\"\n
        {{psql_prefix}} \"update config set wert = '{{mpc.install_path}}' where param = 'mpc/install_dir';\"\n"
    - unless: "{{psql_prefix}} \"select wert from config where param like 'mpc/install_dir'\" | grep '{{mpc.install_path}}'"
    - env:
      - PGPASSWORD: {{salt['pillar.get']('elexis:db_password')}}
      - MYSQL_PWD: {{salt['pillar.get']('elexis:db_password')}}
{% endif %}

