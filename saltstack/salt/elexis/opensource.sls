include:
  - users
  - java8

elexis_needs:
  file.directory:
    - names:
      - /usr/local/bin
  pkg.installed:
    - refresh: false
    - names:
      - xdg-utils

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

{% for app in pillar.get('elexis_apps', []) %}
{% set filename = 'elexis-'+ app.variant + '-' + app.db_to_use %}
{% set inst_path = '/usr/local/' + filename %}
{% set exe = '/usr/local/bin/' + filename +'.sh' %}
{% if pillar.get('server', {}).get('name') %}
{% set db_server = pillar.get('server', {}).get('name') %}
{% else %}
{% set db_server = pillar.get('elexis', {}).get('db_server', 'db_server') %}
{% endif %}

{{inst_path}}:
  archive.extracted:
    - if_missing: {{inst_path}}/Elexis3
    - name: {{inst_path}}
    - source: {{app.download_uri}}
    - source_hash: {{app.hash}}
    - archive_format: zip
{{inst_path}}/Elexis3:
  file.managed:
    - replace: False
    - mode: 755
    - require:
        - archive: {{inst_path}}

{{filename}}:
  file.managed:
    - name: {{exe}}
    - mode: 755
    - source: salt://elexis/file/elexis.sh.jinja
    - template: jinja
    - defaults:
        inst_path: {{inst_path}}
        exe: {{exe}}
        filename: {{filename}}
        app: {{app}}
        db_server: {{db_server}}
        elexis: {{ pillar.get('elexis') }} # db_parameters
/usr/share/applications/{{filename}}.desktop:
  file.managed:
    - source: salt://elexis/file/elexis.desktop.jinja
    - template: jinja
    - defaults:
        app: {{app}}
        exe: {{exe}}
        filename: {{filename}}
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
