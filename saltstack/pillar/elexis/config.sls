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

# Defined which users may access which HIN identities
users_for_hinclients:
  nikgiger: # HIN login
    labor:  # OS users using thunderbird to access above HIN login

# To ease scripting we use the following
# For each HIN Login we have with the same name a
# - local user (which will run the service)
# - hin identify file name $HOME/$login.hin
# - pillar item hin_passphrase
# - pillar item hin_identiy # which must output of xxd --plain (plain hexdump style)
hin_clients:
    - hin_login: nikgiger
    # Choose an ID < 1000 or it will appear in the login choices
      uid:       501
      email:     niklaus.giger@hin.ch
      fullname:  Niklaus Giger
    # Where to get the hinclient from, check 4 new versions
      url:  'https://download.hin.ch/download/distribution/install/1.4.0-0/HINClient_unix_1_4_0-0.tar.gz'
    # Redir Ports, on these ports the services will be available
      http_port:  9016
      smtp_port:  9018
      pop3_port:  9019
      imap_port:  9020
      hin_passphrase: DummyPassphrase
      hin_identity: "44756d6d7920436f6e74656e742065696e20626973736368656e206cc3a4
6e6765720a"

