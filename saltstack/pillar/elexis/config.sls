medelexis:
  linux_x86_64:  '/opt/downloads/ch.medelexis.application.product.Medelexis-linux.gtk.x86_64.zip'
  license_xml:   '/opt/downloads/license.xml'

elexis:
  backup_root:   /mnt/backup
  local_files:   /usr/local
  db_type: postgresql # mysql of pg for postgresql
  db_version: 9.4 # version of the database
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

elexis_installation:
  - variant: beta
    download_uri: https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3-Core-Beta/21/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
    hash: sha256=6b2b160cf8bbd49bde8755732cf9b7e5dc11eef36b1782fc6dfca93c44024edb
    inst_path: /usr/local/bin/elexis-3.1-beta

elexis_apps:
  - human_name: Elexis 3.1 (BETA) auf Test-Datenbank
    variant: beta
    download_uri: https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3-Core-Beta/21/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
    hash: sha256=6b2b160cf8bbd49bde8755732cf9b7e5dc11eef36b1782fc6dfca93c44024edb
    exe: /usr/local/bin/elexis-3.1-beta-test
    db_to_use:  elexis-3-test
    config: elexis-3.1-test
  - human_name: Elexis 3.1 (BETA) auf scharfer Datenbank
    variant: beta
    download_uri: https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3-Core-Beta/21/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
    hash: sha256=6b2b160cf8bbd49bde8755732cf9b7e5dc11eef36b1782fc6dfca93c44024edb
    exe: /usr/local/bin/elexis-3.1-beta
    db_to_use:  elexis
    config: elexis-3.1

