# You have to download manually the Medelexis bootstrap to
# /srv/salt/ch.medelexis.application.product.Medelexis-linux.gtk.x86_64.zip
# and the license.xml to
# /srv/salt/license.xml
# Datei auf Windows-PC erstellt. Gefunden unter C:\Users\xx\AppData\Roaming\HIN\HIN Client
# we assume that the client.hin was conviert to xxd -p client.hin > client.hin.xxd
# reverse operation is cat  client.hin.xxd | xxd -r -pr > client.hin
# 107 lines

hin-client:
  pkg.installed:
    - refresh: False
    - pkgs:
      - inetutils-inetd
      - redir
      - thunderbird-locale-de

{% if false %}
{% for client in [] %}
{{client.name}}:
  user.present:
    - uid: {{ client.get('hind', 'hind') }}
  file.managed:
    - name: /usr/local/bin/{{client.name}}.sh
    - mode: 755
    - source: salt://hin-client/file/client.sh
    - template: jinja
    - defaults:
        client: {{client}}
{% endfor %}
{% endif %}

arzt_hin_client:
  archive.extracted:
    - name: /mnt/homes/arzt
    - archive_user: arzt
    - source: https://download.hin.ch/download/distribution/install/1.5.1-23/HINClient_unix_1_5_1-23.tar.gz
    - source_hash: sha512=c5315ca068efbd03977f2b113e894b39463cc1fc91d199f81c51b8143b642377c21e3613fe1cbf7b07591cbe2d7f3b0fade80f946e3cabc6329a69b0cd91776c
#    - source: https://download.hin.ch/download/distribution/install/1.4.0-0/HINClient_unix_1_4_0-0.tar.gz
#    - source_hash: sha512=de219654cd65759db80ec4e1080f109ac8c158df41610426206bebdb7603c1a96a0de67f730304e119a712bd1ef29cd1e4f13e6ff05133271d3f40fc8ab787f6
    - archive_format: tar
    - tar_options: vz
    - if_missing: '/mnt/homes/arzt/HIN Client/hinclient'

/mnt/homes/arzt/nikgiger.hin:
  file.copy:
    - name: /mnt/homes/arzt/nikgiger.hin
    - user: arzt
    - group: arzt
    - mode: 600
    - source: /vagrant/saltstack/salt/nikgiger.hin

/mnt/homes/arzt/HIN Client:
  file.directory:
    - recurse: true
    - user: arzt
    - group: arzt

inetd_nikggiger:
  file.append:
    - name: /etc/inetd.conf
    - text: |
        # Redir config for sharing local HIN Client nikgiger
        8016 stream tcp nowait root /usr/bin/redir --lport=8016 --cport=5016 --caddr=localhost --inetd
        8018 stream tcp nowait root /usr/bin/redir --lport=8018 --cport=5018 --caddr=localhost --inetd
        8019 stream tcp nowait root /usr/bin/redir --lport=8019 --cport=5019 --caddr=localhost --inetd
        8020 stream tcp nowait root /usr/bin/redir --lport=8020 --cport=5020 --caddr=localhost --inetd

inetutils-inetd:
  service.running:
    - watch:
      - file: /etc/inetd.conf

/mnt/homes/arzt/passphrase.txt:
  file.managed:
    - user: arzt
    - group: arzt
    - mode: 600
    - contents: Mollis8752

/mnt/homes/arzt/.hinclient-service-parameters.txt:
  file.managed:
    - user: arzt
    - group: arzt
    - mode: 600
    - contents:
      - "keystore=/mnt/homes/arzt/nikgiger.hin"
      - "passphrase=/mnt/homes/arzt/passphrase.txt"


{% if false %}

{% endif %}
