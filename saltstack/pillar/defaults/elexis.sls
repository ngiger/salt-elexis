medelexis:
{% if grains.get('id') == 'ElexisServerDemo' %}
  linux_x86_64:  '/opt/downloads/ch.medelexis.application.product.Medelexis-linux.gtk.x86_64.zip'
  license_xml:   '/opt/downloads/license.xml'
{% else %}
  linux_x86_64:  '/mnt/opt/downloads/ch.medelexis.application.product.Medelexis-linux.gtk.x86_64.zip'
  license_xml:   '/mnt/opt/downloads/license.xml'
{% endif %}

elexis:
  backup_root:   /mnt/backup
  local_files:   /usr/local
  db_type: postgresql # mysql of pg for postgresql
  db_version: 9.4 # version of the database
  # Only specify a db_server when it is not identical with network:elexis_server
  # db_server: 192.168.1.222
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
    db_to_use:  test
  - human_name: Medelexis 3.1 (BETA) auf scharfer Datenbank
    variant: beta
    db_to_use:  elexis

{% if grains['os'] == 'Windows' %}
elexis_installation:
  - variant: prerelease
    download_uri: https://download.elexis.info/elexis.3.core/3.1.0-prerelease/products/ch.elexis.core.application.ElexisApp-win32.win32.x86.zip
    hash: sha256=ce2a0875a2227513a138b385ae8cf988d0d54a4bb6d48a22e6339d5e411d450d
    inst_path: C:/elexis-installationen/elexis-3.1-prerelease
{% endif %}

# Conventions used:
#  exe is place /usr/local/bin and  named elexis-<variant>-<db_to_use>.sh
#  configuration $HOME/elexis/ and  named elexis-<variant>-<db_to_use>.cfg
#  desktop /usr/share/applications/ named elexis-<variant>-<db_to_use>.desktop
# The part "elexis-<variant>-<db_to_use>" is passed a file_name to the jinja
elexis_apps:
  - human_name: Elexis 3.1 (Pre-Release) auf Test-Datenbank
    variant: prerelease
    download_uri: https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3.0-Core-Releases/149/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
    hash: sha256=4bbadccd8ea8018498197e577a48bb71fccbd92e5c3f6b5387b97ffc9e7b22f5
    db_to_use:  test
  - human_name: Elexis 3.1 (Pre-Release) auf scharfer Datenbank
    variant: prerelease
    download_uri: https://srv.elexis.info/jenkins/view/3.0/job/Elexis-3.0-Core-Releases/149/artifact/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
    hash: sha256=4bbadccd8ea8018498197e577a48bb71fccbd92e5c3f6b5387b97ffc9e7b22f5
    db_to_use:  elexis

elexis_from_source:
  human_name: Elexis 3.1 (Spezial aus Quellcode) auf Test-Datenbank
  variant: from_source
  db_to_use:  test
  core_url: https://github.com/elexis/elexis-3-core.git
  core_target: /usr/local/src/elexis-3-core
  core_rev: master
  base_url: https://github.com/elexis/elexis-3-base.git
  base_target: /usr/local/src/elexis-3-base
  base_rev: master
  users:
    - arzt
