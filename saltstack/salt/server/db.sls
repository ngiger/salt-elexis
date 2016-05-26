postgresql-dbserver:
  pkg.installed:
    - refresh: false
    - pkgs:
      - postgresql-{{salt['pillar.get']('elexis').db_version}}:
      - postgresql-client-{{salt['pillar.get']('elexis').db_version}}:
  service.running:
    - name: postgresql
    - watch:
        - file: /etc/postgresql/{{salt['pillar.get']('elexis').db_version}}/main/postgresql.conf
        - file: /etc/postgresql/{{salt['pillar.get']('elexis').db_version}}/main/pg_hba.conf

/etc/postgresql/{{salt['pillar.get']('elexis').db_version}}/main/postgresql.conf:
  file.append:
    - require:
      - pkg: postgresql-dbserver
    - text: "listen_addresses = '*'"


/etc/postgresql/{{salt['pillar.get']('elexis').db_version}}/main/pg_hba.conf:
  file.blockreplace:
    - marker_start: "# BLOCK TOP : salt managed zone : ip_network : please do not edit"
    - marker_end: "# BLOCK BOTTOM : end of salt managed zone --"
    - content: "host all all {{salt['pillar.get']('network', {})['ip_network'] }} md5
{% for allow in salt['pillar.get']('network', {}).get('allow_from',{}) %}\nhost all all {{allow}} md5{% endfor %}"
    - show_changes: True
    - append_if_not_found: True
    - require:
      - pkg: postgresql-dbserver

db_user:
  postgres_user.present:
    - name: elexis
    - encrypted: False
    - login: True
    - password: {{salt['pillar.get']('elexis').db_password }}
    - require:
      - pkg: postgresql-dbserver

db_main:
   postgres_database.present:
     - name: {{salt['pillar.get']('elexis').db_main }}
     - encoding: 'UTF8'
     - owner: {{salt['pillar.get']('elexis').db_user }}
     - require:
        - pkg: postgresql-dbserver
        - postgres_user: elexis
db_test:
   postgres_database.present:
     - name: {{salt['pillar.get']('elexis').db_test }}
     - encoding: 'UTF8'
     - owner: {{salt['pillar.get']('elexis').db_user }}
     - require:
        - pkg: postgresql-dbserver
        - postgres_user: elexis

db_dumps_base_dir:
  file.directory:
     - makedirs: true
     - name: /opt/downloads/postgresql

db_pg_util:
  file.managed:
    - name: /usr/local/bin/pg_util.rb
    - mode: 0755
    - source: salt://server/file/pg_util.jinja
    - template: jinja
    - defaults:
        elexis: {{pillar.get('elexis', {})}}

{% set db_to_load   = pillar.get('elexis', {}).get('db_test', 'elexis_test') %}
{% set pg_load_test = pillar.get('elexis', {}).get('pg_load_script', '/usr/local/bin/postgresql_load_') + db_to_load + '_db.rb' %}
db_pg_load_test:
  file.managed:
    - name: {{pg_load_test}}
    - mode: 0755
    - source: salt://server/file/pg_load.jinja
    - template: jinja
    - defaults:
        elexis: {{pillar.get('elexis', {})}}
        db_to_load: {{db_to_load}}

db_simple_test:
  file.managed:
    - name: /opt/downloads/postgresql/simpel.sql.gz
    - archive_format: gzip
    - source: https://github.com/ngiger/elexis-3-db_dumps/raw/master/postgresql/simpel.sql.gz
    - source_hash: sha256=19ef8b75002907f7e29350f7af0e50761a0dd80db187f402562304451637eeda

# Danach kann man mit Hilfe von "psql -U elexis elexis -h localhost" einloggen

