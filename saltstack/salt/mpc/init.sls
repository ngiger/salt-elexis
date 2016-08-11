# The *.hin file must be create on Windows-PC found under C:\Users\xx\AppData\Roaming\HIN\HIN Client

# The hin client needs multiarch support ! The wrapper script is a x86 exe
# wrapper: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.0.30, not stripped
# E.g. dpkg --print-foreign-architectures should output i386

{% if grains.oscodename == 'wheezy' or grains.oscodename == 'jessie' or grains.oscodename == 'rosa' %}
  {% set jave_jre_pkg = 'openjdk-7-jre' %}
{% endif %}

{% if pillar.get('mpc', False) and grains.host == pillar.get('server', {})['name'] %}
{% set mpc = pillar.get('mpc') %}
{% set response_file = mpc.install_path+ '/install_mpc.response' %}
{% if pillar.get('mpc.group', False) %}
{% set mpc_group = pillar.get('mpc.group') %}
{% else %}
{% set mpc_group = 'mpc' %}
{% endif %}
add_i386_arch:
  cmd.run:
   - name: "/usr/bin/dpkg --add-architecture i386 && /usr/bin/apt-get upgrade"
   - unless: "/usr/bin/dpkg --print-foreign-architectures | /bin/grep i386"
install_path:
  pkg.installed:
    - refresh: true
    - require:
      - cmd: add_i386_arch
    - pkgs:
      - {{jave_jre_pkg}}
      - dos2unix
      - postgresql-client
      - libstdc++6:i386
      - libgcc1:i386
      - zlib1g:i386
      - libncurses5:i386

mediport_user:
  user.present:
    - name: mediport
    - system: true

mediport_bin:
  archive.extracted:
    - name: {{mpc.install_path}}
    - source: {{mpc.zip_path}}
    - source_hash: {{mpc.hash}}
    - archive_format: zip
    - if_missing: "{{mpc.install_path}}/{{mpc.bin_name}}"

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
        - archive:  {{mpc.install_path}}

install_mpc:
  cmd.run:
    - cwd: {{mpc.install_path}}
    - name: "/bin/bash '{{mpc.install_path}}/{{mpc.bin_name}}' -i console < {{response_file}}"
    - creates: "{{mpc.install_path}}/mpc.sh"
    - require:
        - archive:  {{mpc.install_path}}
        - file: response_file
no_cr_lf_mpc_sh:
  cmd.run:
    - cwd: {{mpc.install_path}}
    - name: "dos2unix {{mpc.install_path}}/mpc.sh"
    - onlyif: "/usr/bin/file {{mpc.install_path}}/mpc.sh | /bin/grep CRLF"

/usr/local/bin/mpc.sh:
  file.symlink:
    - target: {{mpc.install_path}}/mpc.sh
    - require:
      - cmd:  {{mpc.install_path}}

# /usr/local/mediport/config/EAN2099988870017_mpg.keystore
keystore_mpc:
  file.managed:
    - name: {{mpc.install_path}}/config/EAN{{mpc.sender_ean}}_mpg.keystore
    - source: {{mpc.keystore}}
    - require:
      - archive: {{mpc.install_path}}
{{mpc.install_path}}/data/partner/partnerinfo.txt:
  file.managed:
    - source: salt://mpc/file/partnerinfo.txt
    - require:
      - archive: {{mpc.install_path}}

{{mpc.install_path}}/config/mpcommunicator.config:
  file.managed:
    - source: salt://mpc/file/mpcommunicator.config.jinja
    - template: jinja
    - require:
      - archive: {{mpc.install_path}}
      - file: keystore_mpc
    - defaults:
        mpc: {{mpc}}
{{mpc.install_path}}/ausgang/tp:
  file.directory:
    - makedirs: true
{{mpc.install_path}}/ausgang/tg:
  file.directory:
    - makedirs: true

facl_{{mpc.install_path}}:
  group.present:
    - name: {{mpc_group}}
  acl.present:
    - name: {{mpc.install_path}}/config/mpcommunicator.config
    - name: {{mpc.install_path}}/ausgang
    - name: {{mpc.install_path}}/data
    - name: {{mpc.install_path}}
    - acl_type: group
    - acl_name: {{mpc_group}}
    - perms: rwx
    - recurse: true
    - require:
        - archive:  {{mpc.install_path}}

{% if grains.init == 'systemd' %}
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
      - archive: {{mpc.install_path}}
service_mpc:
  service.running: # running or disabled
    - name: mpc
    - require:
      - archive: {{mpc.install_path}}
      - file: /etc/systemd/system/mpc.service
      - file: {{mpc.install_path}}/config/mpcommunicator.config
{% elif grains.init == 'sysvinit' %}
# add to rc.local
/etc/rc.local:
  file.blockreplace:
    - marker_start: "# START managed zone mpc -DO-NOT-EDIT-"
    - marker_end: "# END managed zone zone --"
    - content: "{{mpc.install_path}}/mpc.sh start"
    - append_if_not_found: True
/etc/rc.local_no_exit:
  file.comment:
    - name: /etc/rc.local
    - regex: 'exit 0'
    - backup: '.bak'
service_mpc:
  service.disabled: # running or disabled
    - name: mpc
    - require:
      - archive: {{mpc.install_path}}
      - file: /etc/rc.local
      - file: {{mpc.install_path}}/config/mpcommunicator.config
{% endif %}

{% if mpc.get('change_elexis_config', False) %}
{% set psql_prefix = 'psql --host=localhost -U ' + salt['pillar.get']('elexis:db_user')+ ' ' + salt['pillar.get']('elexis:db_main') + ' -c ' %}
ensure_mpc_install_dir:
  cmd.run:
    - name: "{{psql_prefix}} \"insert into config values('mpc/install_dir', '{{mpc.install_path}}', '1');\"\n
        {{psql_prefix}} \"update config set wert = '{{mpc.install_path}}' where param = 'mpc/install_dir';\"\n"
    - unless: "{{psql_prefix}} \"select wert from config where param like 'mpc/install_dir'\" | grep '{{mpc.install_path}}'"
    - env:
      - PGPASSWORD: {{salt['pillar.get']('elexis:db_password', 'elexis:db_password notdefined')}}
      - MYSQL_PWD: {{salt['pillar.get']('elexis:db_password', 'elexis:db_password notdefined')}}
{% endif %}
{% endif %}

