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

# Danach kann man mit Hilfe von "psql -U elexis elexis -h localhost" einloggen

