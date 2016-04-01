elexis:
  backup_root:   /mnt/backup
  local_files:   /usr/local
  db_type: pg # mysql of pg for postgresql
  db_server: prxserver
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
