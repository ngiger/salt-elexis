# http://wpkg.org/Thunderbird#Thunderbird_Configuration
# http://web.mit.edu/~thunderbird/www/maintainers/autoconfig.html
# Example thunderbird.js with automatically assigned values from ldap.

thunder_bird_install:
  pkg.installed:
    - refresh: false
{% if grains.os == 'Debian' %}
    - name: icedove
    - name: icedove-l10n-de
{% elif grains.os == 'Ubuntu' %}
    - name: thunderbird-locale-de
    - name: thunderbird
{% endif %}
{% for user in pillar['users'] %}
/home/{{user.name}}/.icedove/{{user.name}}.default:
  file.directory:
    - makedirs: true
/home/{{user.name}}/.icedove/{{user.name}}.default/prefs.js:
  file.managed:
    - replace: false
    - source: salt://elexis/file/thunderbird_prefs.js
    - template: jinja
    - defaults:
        user: {{user}}
{% endfor %}

#./.local/share/applications/mimeapps.lis
#[Default Applications]
#x-scheme-handler/mailto=thunderbird.desktop
#message/rfc822=thunderbird.desktop
#[Added Associations]
#x-scheme-handler/mailto=thunderbird.desktop;
#message/rfc822=thunderbird.desktop;
