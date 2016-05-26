# You have to download manually the Medelexis zip and license file to
# and specifiy the content of the license file in the pillar data

{% if salt.file.file_exists(pillar['medelexis']['linux_x86_64']) != true %}
/tmp/Medelexis_not_found:
  file.managed:
    - contents:
      - "Could not find {{pillar['medelexis']['linux_x86_64'] }}"
{% else %}

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

{% if pillar.get('elexis:db_server', False) %}
{% set db_server = pillar.get('server:name', 'a') %}
{% else %}
{% set db_server = pillar.get('elexis:db_server', 'b') %}
{% endif %}

{% for app in pillar['medelexis_apps'] %}
{%- set filename = 'medelexis-'+ app.variant + '-' + app.db_to_use %}
{%- set exe = '/usr/local/bin/' + filename +'.sh' %}
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

{% if salt.file.file_exists(pillar['medelexis']['license_xml']) %}
{{user.home}}/elexis/license.xml:
  file.copy:
    - source: {{ pillar['medelexis']['license_xml'] }}
{% endif %}

{% endfor %}

{% endif %}
