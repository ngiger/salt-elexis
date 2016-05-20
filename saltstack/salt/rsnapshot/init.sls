# kate: space-indent on; indent-width 4; mixedindent on; indent-mode python; replace-tabs off; syntax python
# TODO:
# Initial destination is not created
# authorized  not accepted

# consider backup_script      /usr/local/bin/backup_mysql.sh       localhost/mysql/
# See https://wiki.archlinux.org/index.php/Rsnapshot#Extra_Scripts

rsnapshot:
  pkg.installed:
    - refresh: false
    - name: rsnapshot

# create an rsync exclude file if define
{% set rsnapshot_defaults = salt['pillar.get']('rsnapshot_defaults', {})  %}
{% set options =  salt['pillar.get']('rsnapshot_options', {}) %}
{% if options.exclude_file is defined %}
{{options.exclude_file}}:
  file.managed:
    - mode: 644
    - source: salt://rsnapshot/files/rsync.exclude
{% endif %}

{% if options.ssh_key_id_rsa_pub is defined and options.ssh_key_id_rsa  is defined %}
{{options.ssh_key}}:
  file.managed:
    - mode: 600
    - contents: {{options.ssh_key_id_rsa}}
{{options.ssh_key}}.pub:
  file.managed:
    - mode: 644
    - contents: {{options.ssh_key_id_rsa_pub}}
{% elif options.ssh_key is defined %}
{{options.ssh_key}}:
  cmd.run:
    - mode: 600
    - name: "sudo ssh-keygen -f /root/.ssh/rsnapshot_key -N ''"
    - creates: {{options.ssh_key}}
{% endif %}

{% if options.ssh_config is defined %}
/root/.ssh/config:
  file.managed:
    - mode: 600
    - name: /root/.ssh/config
    - content: '# Dummy'
    - replace: false
{% endif %}

{% for idx, backup in salt['pillar.get']('rsnapshot_backups', {}).iteritems() %}
  {% set config = backup %}
  {% set config_file = "/etc/rsnapshot_" + idx + ".conf" %}

{% if false %}
/tmp/rsnapshot_{{idx}}.debug:
  file.managed:
    - mode: 644
    - contents:
      - "idx {{idx}}"
      - "backup {{backup}}"
      - "rsnapshot_options {{options}}"
      - "rsnapshot_defaults {{rsnapshot_defaults}}"
{% endif %}

# create ssh_config entry if copying from remote server
{% if options.ssh_config is defined and config.dirs_to_backup.items()[0][0].find(':') != -1 %}
rsnapshot_ssh_config_{{idx}}:
  file.blockreplace:
    - name: /root/.ssh/config
    - marker_start: "# BLOCK TOP : salt managed zone : rsnapshot_ssh_config_{{idx}} : please do not edit"
    - marker_end: "# BLOCK BOTTOM : end of salt managed zone --"
    - content: "Host {{idx}}-rsnapshot\nHostname {{idx}}\nIdentityFile {{options.ssh_key}}"
    - show_changes: True
    - append_if_not_found: True
{% endif %}

{{config_file}}:
  file.managed:
    - mode: 644
    - source: salt://rsnapshot/files/rsnapshot.conf
    - template: jinja
    - context:
        options: {{options}}
        config: {{backup}}
        name: {{idx}}
{% if backup.crontab is defined %}
{% set crontab_items = backup.crontab %}
{% else %}
{% set crontab_items = rsnapshot_defaults.crontab %}
{% endif %}
        rsnapshot_defaults: {{rsnapshot_defaults}}
    {% for id, item in crontab_items.iteritems() %}
rsnapshot_{{idx}}_{{id}}.tst:
  cron.present:
    - name: nice -10 ionice -c3 /usr/bin/rsnapshot -q -c {{config_file}} {{id}} 1>/dev/null
    - user: root
    - identifier: {{idx}}_{{id}}
    {% for time_id, time_value in item.iteritems() %}
    - {{time_id}}: {{time_value}}{% endfor %}
    {% endfor %}
  {% endfor %}

