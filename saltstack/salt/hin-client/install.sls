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
    - name: unzip

{% for client in pillar['hin_clients'] %}
{{client.name}}:
  user.present:
    - uid: {{ client.get('hind', 'hind'}}
  file.managed:
    - name: /usr/local/bin/{{client.name}}.sh
    - mode: 755
    - source: salt://hin-client/file/client.sh
    - template: jinja
    - defaults:
        client: {{client}}
{% endfor %}

/etc/my_super_secret_file:
  file.managed:
    - user: secret
    - group: secret
    - mode: 600
    - contents_pillar: secret_files:my_super_secret_file