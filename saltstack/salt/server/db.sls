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
  file.append:
    - require:
      - pkg: postgresql-dbserver
    - text: "host    all             all             192.168.1.0/24            md5"

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

