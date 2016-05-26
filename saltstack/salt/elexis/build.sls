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

{% set core_target = pillar.get('elexis',{}).get('core',{}).get('target', '/opt/src/elexis-3-core') %}
{% set base_target = pillar.get('elexis',{}).get('base',{}).get('target', '/opt/src/elexis-3-base') %}

{% if true  %}
git_elexis_core:
  git.latest:
    - name: {{pillar.get('elexis',{}).get('core',{}).get('url', 'https://github.com/elexis/elexis-3-core.git')}}
    - target: {{core_target}}
    - rev: {{pillar.get('elexis',{}).get('core',{}).get('branch', 'master')}}
    - require:
      - pkg: git

build_elexis_core:
  cmd.run:
    - creates: {{core_target}}/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip
    - name: "mvn clean install -Dmaven.test.skip=true 2>&1 | tee maven-salt.log"
    - cwd: {{core_target}}
    - require:
      - pkg: maven

{{base_target}}:
  git.latest:
    - target: {{base_target}}
    - name: {{pillar.get('elexis',{}).get('base',{}).get('url', 'https://github.com/elexis/elexis-3-base.git')}}
    - rev: {{pillar.get('elexis',{}).get('base',{}).get('branch', 'master')}}
    - require:
      - pkg: git
      - cmd: build_elexis_core

build_elexis_base:
  cmd.run:
    - creates: {{base_target}}/ch.elexis.base.p2site/target/targetPlatformRepository
    - name: "mvn clean install -Dmaven.test.skip=true 2>&1 | tee maven-salt.log"
    - cwd: {{base_target}}
    - require:
      - pkg: maven
    - watch:
      - git: {{base_target}}
{% endif  %}

{% set install_x86_64 = '/usr/local/bin/install_x86_64' %}
{{install_x86_64}}:
  file.managed:
    - mode: 0755
    - contents:
      - '#!/bin/bash -v'
      - 'set -x'
      - 'rm -rf {{base_target}}/inst'
      - 'mkdir -p {{base_target}}/inst'
      - 'cd {{base_target}}/inst'
      - "/bin/cp -rp {{base_target}}/ch.elexis.base.p2site/target/repository/plugins ."
      - "/bin/cp -rp {{base_target}}/ch.elexis.base.p2site/target/repository/features ."
      - "/usr/bin/unzip -u -qq {{core_target}}/ch.elexis.core.p2site/target/products/ch.elexis.core.application.ElexisApp-linux.gtk.x86_64.zip"
    - watch:
      - cmd: build_elexis_core
      - cmd: build_elexis_base
  cmd.wait:
    - watch:
      - file: {{install_x86_64}}
        elexis_install: {{ pillar.get('elexis_install') }}

{% for app in pillar.get('elexis_from_source', []) %}
{% set filename = 'elexis-'+ app.variant + '-' + app.db_to_use %}
{% set exe = base_target + '/' + filename +'.sh' %}
{% if pillar.get('server', {}).get('name') %}
{% set db_server = pillar.get('server', {}).get('name') %}
{% else %}
{% set db_server = pillar.get('elexis', {}).get('db_server', 'db_server') %}
{% endif %}

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
  {% endfor %}
{% endfor %}
