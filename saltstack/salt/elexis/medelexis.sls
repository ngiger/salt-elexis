# You have to download manually the Medelexis zip and license file to
# and specifiy the content of the license file in the pillar data

{% if salt.file.file_exists(pillar['medelexis']['linux_x86_64']) %}

unzip:
  pkg.installed:
    - refresh: false
libnotify-bin:
  pkg.installed:
    - refresh: false
xdg-utils:
  pkg.installed:
    - refresh: false

/usr/share/icons/medelexis-logo.png:
  file.managed:
    - source: salt://elexis/file/medelexis-logo.png

{% if pillar.get('elexis:db_server', False) %}
{% set db_server = pillar.get('server:name', 'a') %}
{% else %}
{% set db_server = pillar.get('elexis:db_server', 'b') %}
{% endif %}

{% for app in pillar['medelexis_apps'] %}
{{app.exe}}:
  file.managed:
    - mode: 755
    - source: salt://elexis/file/medelexis.sh
    - template: jinja
    - defaults:
        app: {{app}}
        db_server: {{db_server}}
        elexis: {{ pillar.get('elexis') }} # db_parameters
{%- set filename = salt['file.basename'](app.exe) %}
/usr/share/applications/{{filename}}.desktop:
  file.managed:
    - source: salt://elexis/file/medelexis.desktop
    - template: jinja
    - defaults:
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

{% if salt.file.file_exists(pillar['medelexis']['license_xml']) %}
{{user.home}}/elexis/license.xml:
  file.copy:
    - source: {{ pillar['medelexis']['license_xml'] }}
{% endif %}

{% endfor %}

{% endif %}
