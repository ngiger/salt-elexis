medelexis:
  linux_x86_64:  '/opt/downloads/ch.medelexis.application.product.Medelexis-linux.gtk.x86_64.zip'
  license_xml:   '/opt/downloads/license.xml'

elexis:
  backup_root:   /mnt/backup
  local_files:   /usr/local
  db_type: postgresql # mysql of pg for postgresql
  db_server: 192.168.1.222
  db_port: 8700
  db_main: elexis  # Name of DB to use for production
  db_test: test  # DB to use for tests
  db_user: elexis  # DB-User to access both DB
  db_password: elexisTest # a convention

language: de_CH

java_home: /usr/lib/java
java:
  source_url: http://<somehost>/jdk-linux-server-x64-1.7.0.45.tar.gz
  jce_url: http://<somehost>/UnlimitedJCEPolicyJDK7.zip
  version_name: jdk-linux-server-x64-1.7.0.45
  prefix: /usr/share/java
  dl_opts: -L

medelexis_apps:
  - human_name: Medelexis 3.1 (BETA) auf Test-Datenbank
    variant: beta
    downloaded_zip: /opt/downloads/medelexis.zip
    exe: /usr/local/bin/medelexis-3.1-beta-test
    db_to_use:  elexis-3-test
    config: elexis-3.1-test
  - human_name: Medelexis 3.1 (BETA) auf scharfer Datenbank
    variant: beta
    downloaded_zip: /opt/downloads/medelexis.zip
    exe: /usr/local/bin/medelexis-3.1-beta
    db_to_use:  elexis
    config: elexis-3.1

hin_clients:
    - name: nikgiger
    # Name of the (already activated) idendity file
      id_file:  'bymtoerl.hin'
    # Where to find the idendity file for coping
      id_file_source:  '/vagrant/saltstack/salt'
    # Local User for running the hin server
      hind:  'hind'
    # Where to get the hinclient from, check 4 new versions
      url:  'https://download.hin.ch/download/distribution/install/1.4.0-0/HINClient_unix_1_4_0-0.tar.gz'
    # Redir Ports, on these ports the services will be available
      http_port:  '9011'
      pop3_port:  '9012'
      smtp_port:  '9013'
      imap_port:  '9014'
