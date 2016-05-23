include:
  - users
  - java8

unzip:
  pkg.installed:
    - refresh: false

xdg-utils:
  pkg.installed:
    - refresh: false


/usr/share/icons/elexis-logo.png:
  file.managed:
    - source: salt://elexis/file/elexis-logo.png

{% for elexis_install in  pillar.get('elexis_installation', []) %}
{{elexis_install.inst_path}}:
  archive.extracted:
    - if_missing: {{elexis_install.inst_path}}/Elexis3
    - name: {{elexis_install.inst_path}}
    - source: {{elexis_install.download_uri}}
    - source_hash: {{elexis_install.hash}}
    - archive_format: zip
{{elexis_install.inst_path}}/Elexis3:
  file.managed:
    - mode: 755
    - require:
        - archive: {{elexis_install.inst_path}}
{% endfor %}

/tmp/tst:
  file.managed:
    - contents:
      - "pillar.get('elexis_apps', [])"
      - "elexis:db_server {{pillar.get('elexis:db_server', [])}}"
      - "server:name {{pillar.get('server:name', [])}}"
      - "server {{pillar.get('server', [])}}"
      - "server2 {{pillar.get('server', {}).get('name')}}"
{% for app in pillar.get('elexis_apps', []) %}
{%- set filename = salt['file.basename'](app.exe) %}

{% if pillar.get('server', {}).get('name') %}
{% set db_server = pillar.get('server', {}).get('name') %}
{% else %}
{% set db_server = pillar.get('elexis', {}).get('db_server', 'db_server') %}
{% endif %}

{{app.exe}}:
  file.managed:
    - mode: 755
    - source: salt://elexis/file/elexis.sh
    - template: jinja
    - defaults:
        app: {{app}}
        db_server: {{db_server}}
        elexis: {{ pillar.get('elexis') }} # db_parameters
        elexis_install: {{ pillar.get('elexis_install') }}
/usr/share/applications/{{filename}}.desktop:
  file.managed:
    - source: salt://elexis/file/elexis.desktop
    - template: jinja
    - defaults:
        app: {{app}}
        db_server: {{db_server}}
        icon: /usr/share/icons/hicolor/scalable/elexis-logo.svg

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
