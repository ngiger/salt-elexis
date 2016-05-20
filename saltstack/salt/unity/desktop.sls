unity-desktop:
  pkg.installed:
    - refresh: False
    - pkgs:
      - unity
      - lightdm
      - ubuntu-desktop
      - myspell-de-ch
      - language-pack-de

{% for user in pillar['users'] %}
/var/lib/AccountsService/users/{{user.name}}:
  file.managed:
    - replace: True
    - contents:
      - '[User]'
      - 'XSession=ubuntu'
      - 'XKeyboardLayouts=ch;us fr;'
# this file gets overriden by lightdm each time it restarts. Why?
# But it looks like it is okay when createing the first time

{{user.home}}/.gconf:
  file.directory:
    - user: {{user.name}}
    - group: {{user.name}}
    - makedirs: True
    - recurse:
        - user
        - group

# TODO: Make keyboard selection work
{% if true %}
{{user.home}}/.gconf/desktop/gnome/peripherals/keyboard/kbd/:
  file.directory:
    - user: {{user.name}}
    - group: {{user.name}}
    - makedirs: True
{{user.home}}.kbd.gconf.xml:
  file.managed:
          # /mnt/homes/mpa/.gconf/desktop/gnome/peripherals/keyboard/kbd/%gconf.xml
          #              ./.gconf/desktop/gnome/peripherals/keyboard/kbd/%gconf.xml
    - name: "{{user.home}}/.gconf/desktop/gnome/peripherals/keyboard/kbd/%gconf.xml"
    - user: {{user.name}}
    - group: {{user.name}}
    - force:  false
    - contents:
       - '<?xml version="1.0"?>'
       - '<gconf>'
       - '        <entry name="layouts" mtime="1459697748" type="list" ltype="string">'
       - '                <li type="string">'
       - '                        <stringvalue>ch</stringvalue>'
       - '                </li>'
       - '       </entry>'
       - '</gconf>'
{{user.home}}/.gconf/apps/update-notifier/:
  file.directory:
    - user: {{user.name}}
    - group: {{user.name}}
    - makedirs: True
    - force:  false
{{user.home}}/.gconf/apps/update-notifier/%gconf.xml:
  file.managed:
    - user: {{user.name}}
    - group: {{user.name}}
    - makedirs: True
    - contents:
      - '<?xml version="1.0"?>'
      - '<gconf><entry name="release_check_time" mtime="1459787624" type="int" value="0"/></gconf>'
{% endif %}
{% endfor %}

lightdm:
  pkg.installed:
    - refresh: false
    - name: lightdm
  service.running:
    - name: lightdm

