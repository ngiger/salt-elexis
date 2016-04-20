include:
  - users
  - java8

elexis-requires:
  pkg.installed:
    - name: unzip

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
{%- set filename = salt['file.basename'](app.exe) %}

{{app.exe}}:
  file.managed:
    - mode: 755
    - source: salt://elexis/file/elexis.sh
    - template: jinja
    - defaults:
        app: {{app}}
        elexis: {{ pillar.get('elexis') }} # db_parameters
/usr/share/applications/{{filename}}.desktop:
  file.managed:
    - source: salt://elexis/file/elexis.desktop
    - template: jinja
    - defaults:
        app: {{app}}
        icon: /usr/share/icons/hicolor/scalable/elexis-logo.svg

  {% for user in pillar['users'] %}

{{user.home}}/{{filename}}:
  cmd.run:
    - name: xdg-desktop-icon install /usr/share/applications/{{filename}}.desktop
    - user:  {{user.name}}
    - require:
        - user:  {{user.name}}
    - unless: diff /usr/share/applications/{{filename}}.desktop {{user.home}}/*/{{filename}}.desktop
  {% endfor %}

{% endfor %}
