# You have to download manually the Medelexis zip and license file to
# and specifiy the content of the license file in the pillar data

{% if pillar.get('medelexis',[])['linux_x86_64'] %}

include:
  - users
  - java8

medelexis_needs:
  file.directory:
    - names:
      - /usr/local/bin
  pkg.installed:
    - refresh: false
    - names:
      - libnotify-bin
      - xdg-utils

/usr/share/icons/medelexis-logo.png:
  file.managed:
    - source: salt://elexis/file/medelexis-logo.png

{%- set elexis =  pillar.get('elexis',[]) -%}
{% if elexis.get('db_server', False) %}
{% set db_server = elexis.get('db_server', 'localhost') %}
{% else %}
{% set db_server = pillar.get('server',[]).get('name', 'localhost') %}
{% endif %}

{% for app in pillar.get('medelexis_apps', []) %}
{%- set filename = 'medelexis-'+ app.variant + '-' + app.db_to_use %}
{%- set exe = '/usr/local/bin/' + filename +'.sh' %}
{% if elexis.get('db_type', 'mysql') == 'mysql' or elexis.get('db_type', false) == 'mariadb'  %}
{%- set jdbc_type = 'mysql' -%}
{% else %}
{%- set jdbc_type = elexis.get('db_type', 'undef') -%}
{% endif %}
{{exe}}:
  file.managed:
    - mode: 755
    - source: salt://elexis/file/medelexis.sh.jinja
    - template: jinja
    - defaults:
        filename: {{filename}}
        exe: {{exe}}
        app: {{app}}
        db_server: {{db_server}}
        medelexis: {{ pillar.get('medelexis') }} # location of downloaded zip
        elexis: {{ pillar.get('elexis') }} # db_parameters
        jdbc_type: {{jdbc_type}}
/usr/share/applications/{{filename}}.desktop:
  file.managed:
    - source: salt://elexis/file/medelexis.desktop.jinja
    - template: jinja
    - defaults:
        exe: {{exe}}
        app: {{app}}
        icon: /usr/share/icons/hicolor/scalable/medelexis-logo.svg

  {% for user in pillar['users'] %}

{{user.home}}/{{filename}}:
  cmd.run:
    - name: xdg-desktop-icon install /usr/share/applications/{{filename}}.desktop
    - user:  {{user.name}}
    - require:
        - user:  {{user.name}}
        - pkg: xdg-utils
    - unless: diff /usr/share/applications/{{filename}}.desktop {{user.home}}/*/{{filename}}.desktop
  {% endfor %}

{% endfor %}

{% for user in pillar['users'] %}
{{user.home}}/elexis:
  file.directory:
    - name: {{user.home}}/elexis

{% endfor %}

{% endif %}

{% if pillar.get('medelexis',[])['license_xml'] %}
/etc/license.xml:
  file.managed:
    - source: pillar.get('medelexis',[])['license_xml']
    - source_hash: sha256=7d04edb1398d8d009eecff086dc51d4c73d5583b5ea36804fe37db1a1c1bdf65
{% endif %}

