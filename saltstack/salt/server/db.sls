postgresql-dbserver:
  pkg.installed:
    - refresh: false
    - pkgs:
      - postgresql:
      - postgresql-client:
  service.running:
    - name: postgresql
    - watch:
        - file: /etc/postgresql/9.4/main/postgresql.conf
        - file: /etc/postgresql/9.4/main/pg_hba.conf

/etc/postgresql/9.4/main/postgresql.conf:
  file.append:
    - text: "listen_addresses = '*'"

/etc/postgresql/9.4/main/pg_hba.conf:
  file.append:
    - text: "host    all             all             192.168.1.0/24            md5"

db_user:
  postgres_user.present:
    - name: elexis
    - encrypted: False
    - login: True
    - password: {{salt['pillar.get']('elexis').db_password }}
    - require:
        - service: postgresql

db_main:
   postgres_database.present:
     - name: {{salt['pillar.get']('elexis').db_main }}
     - encoding: 'UTF-8'
     - owner: {{salt['pillar.get']('elexis').db_user }}
     - require:
         - postgres_user: elexis
db_test:
   postgres_database.present:
     - name: {{salt['pillar.get']('elexis').db_test }}
     - encoding: 'UTF-8'
     - owner: {{salt['pillar.get']('elexis').db_user }}
     - require:
         - postgres_user: elexis

# Danach kann man mit Hilfe von "psql -U elexis elexis -h localhost" einloggen

