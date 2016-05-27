{% if pillar.get('elexis_from_source', false) %}

include:
  - users
  - java8

elexis_build_needs:
  pkg.installed:
    - refresh: false
    - names:
      - libnotify-bin
      - xdg-utils
      - git
      - oracle-java8-installer
      - maven
      - dos2unix

{% set app                 = pillar.get('elexis_from_source') %}
{% set core_target         = pillar.get('elexis_from_source', {}).get('core_target', '/opt/src/elexis-3-core') %}
{% set base_target         = pillar.get('elexis_from_source', {}).get('base_target', '/opt/src/elexis-3-base') %}
{% set build_elexis        = pillar.get('elexis_from_source',{}).get('build_elexis', '/usr/local/bin/build_elexis_from_source.sh') %}
{% set install_x86_64_root = pillar.get('elexis_from_source',{}).get('install_x86_64_root', '/usr/local/elexis-from_source') %}
{% set install_win32_root  = pillar.get('elexis_from_source',{}).get('install_win32_root', '/home/samba/prg/elexis/from_source') %}
{% set base_rev            = pillar.get('elexis_from_source', {}).get('base_rev', 'master') %}
{% set core_rev            = pillar.get('elexis_from_source', {}).get('core_rev', 'master') %}
{% set install_x86_64      = '/usr/local/bin/install_x86_64.sh' %}
{% set install_win32       = '/usr/local/bin/install_win32.sh' %}
{% set filename            = 'elexis-'+ app.variant + '-' + app.db_to_use %}
{% set exe                 = base_target + '/' + filename +'.sh' %}
{% set inst_path           = '/usr/local/' + filename %}
{% if                        pillar.get('server', {}).get('name') %}
{% set db_server           = pillar.get('server', {}).get('name') %}
{% else %}
{% set db_server           = pillar.get('elexis', {}).get('db_server', 'db_server') %}
{% endif %}


git_elexis_core:
  git.latest:
    - name: {{pillar.get('elexis_from_source', {}).get('core_url', 'https://github.com/elexis/elexis-3-core.git')}}
    - target: {{core_target}}
    - rev: {{core_rev}}
    - require:
      - pkg: git

{{base_target}}:
  git.latest:
    - target: {{base_target}}
    - name: {{pillar.get('elexis_from_source', {}).get('base_url', 'https://github.com/elexis/elexis-3-base.git')}}
    - rev: {{base_rev}}
    - require:
      - pkg: git

{{build_elexis}}:
  file.managed:
    - mode: 0755
    - contents:
      - '#!/bin/bash -v'
      - 'set -x'
      - 'cd {{core_target}}'
      - 'git remote update'
      - 'git checkout --force {{core_rev}} .'
      - 'git branch -l'
      - "mvn clean install -Dmaven.test.skip=true -Pall-archs 2>&1 | tee maven-{{core_rev}}-salt.log"
      - 'cd {{base_target}}'
      - 'git remote update'
      - 'git checkout --force {{base_rev}} .'
      - 'git branch -l'
      - "mvn clean install -Dmaven.test.skip=true 2>&1 | tee maven-{{base_rev}}-salt.log"
      - "{{install_x86_64}}"
      - "{{install_win32}}"
    - require:
      - pkg: maven
      - git: {{base_target}}

{{install_x86_64}}:
  file.managed:
    - mode: 0755
    - contents:
      - '#!/bin/bash -v'
      - 'set -x'
      - 'rm -rf {{install_x86_64_root}}'
      - 'mkdir -p {{install_x86_64_root}}'
      - 'cd {{install_x86_64_root}}'
      - "/bin/cp -rp {{base_target}}/ch.elexis.base.p2site/target/repository/plugins ."
      - "/bin/cp -rp {{base_target}}/ch.elexis.base.p2site/target/repository/features ."
      - "/usr/bin/unzip -u -qq {{core_target}}/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip"
    - require:
      - file: {{build_elexis}}

{{install_win32}}:
  file.managed:
    - mode: 0755
    - contents:
      - '#!/bin/bash -v'
      - 'set -x'
      - 'rm -rf {{install_win32_root}}'
      - 'mkdir -p {{install_win32_root}}'
      - 'cd {{install_win32_root}}'
      - "/bin/cp -rp {{base_target}}/ch.elexis.base.p2site/target/repository/plugins ."
      - "/bin/cp -rp {{base_target}}/ch.elexis.base.p2site/target/repository/features ."
      - "/usr/bin/unzip -u -qq {{core_target}}/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-win32.win32.x86.zip"
    - require:
      - file: {{build_elexis}}
install_win32_test_db:
  file.managed:
    - name: {{install_win32_root}}/start_test_db.tmp
    - mode: 0755
    - source: salt://elexis/file/elexis.cmd.jinja
    - template: jinja
    - defaults:
        exe: {{install_win32_root}}/Elexis3.exe
        app: {{app}}
        db_server: {{db_server}}
        elexis: {{ pillar.get('elexis') }} # db_parameters
  cmd.wait:
    - name: "/usr/bin/unix2dos --newfile  {{install_win32_root}}/start_test_db.tmp  {{install_win32_root}}/start_test_db.cmd"
    - mode: 0755
    - creates: "{{install_win32_root}}/start_test_db.cmd"
    - watch:
      - file: "{{install_win32_root}}/start_test_db.tmp"

daily_elexis_build:
  cron.present:
    - name: "nice -10 ionice -c3 {{build_elexis}}  >> /var/log/daily_elexis_build.log 2>&1"
    - user: root
    - identifier: daily_elexis_build
    - minute: 15
    - hour:   3

{{filename}}:
  file.managed:
    - name: {{exe}}
    - mode: 755
    - source: salt://elexis/file/elexis.sh.jinja
    - template: jinja
    - defaults:
        exe: {{exe}}
        filename: {{filename}}
        app: {{app}}
        inst_path: {{inst_path}}
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

{% for user_name in app.get('users', []) %}
  {% for user in pillar.get('users') %}
    {% if user.name == user_name %}
{{user.home}}/{{filename}}:
  cmd.run:
    - name: xdg-desktop-icon install /usr/share/applications/{{filename}}.desktop
    - user:  {{user.name}}
    - require:
        - user:  {{user.name}}
        - pkg: xdg-utils
    {% endif %}
  {% endfor %}
{% endfor %}

{% endif %}
