# vim: set expandtab: sw=2S

/usr/share/icons/hicolor/256x256/elexis-logo.png:
  file.managed:
    - source: salt://elexis/file/elexis-logo.png
/usr/share/applications/elexis-cockpit.desktop:
  file.managed:
    - source: salt://elexis/file/elexis-cockpit.desktop
    - template: jinja
    - defaults:
        server: {{pillar.get('server.name', '0.0.0.0')}}
        icon: /usr/share/icons/hicolor/256x256/elexis-logo.png

{% if grains.get('id') == pillar.get('server', {})['name'] %}
{% set install_dir = '/opt/checkout/cockpit' %}
{% set pillar_yaml = '/etc/pillar.yaml' %}
cockpit:
  user.present:
    - enforce_password: false
    - shell: /usr/sbin/nologin

cockpit-checkout:
  file.directory:
    - name: {{install_dir}}
    - user: cockpit
  git.latest:
    - name: https://github.com/elexis/elexis-cockpit.git
    - target: {{install_dir}}
    - user: cockpit

cockpit_needs:
  pkg.installed:
    - refresh: false
    - names:
      - ruby-full
      - bundler
      - daemontools
      - libsqlite3-dev
      - libxml2-dev
      - libxslt1-dev

{{pillar_yaml}}:
  cmd.run:
    - name: "salt-call --out yaml pillar.items > {{pillar_yaml}}"

/etc/service/cockpit/log:
  file.directory:
    - present: true
    - makedirs: true

/etc/service/cockpit/log/run:
  file.managed:
    - mode: 0744
    - require:
      - git: cockpit-checkout
      - file: /etc/service/cockpit/log
    - contents:
      - '#!/bin/sh'
      - 'exec multilog t ./main'

cockpit-bundle:
  cmd.run:
    - name: /usr/bin/bundle install --deployment
    - cwd: {{install_dir}}
    - creates:  {{install_dir}}/vendor
    - require:
      - git: cockpit-checkout
      - pkg:
        -names:
          - ruby-full
          - bundler
    - watch:
      - git: cockpit-checkout
  file.managed:
    - name: /etc/service/cockpit/run
    - mode: 0744
    - require:
      - git: cockpit-checkout
      - file: /etc/service/cockpit/log
    - contents:
      - '#!/bin/sh'
      - 'exec 2>&1'
      - 'ulimit -v 10240000'
      - "cd {{install_dir}}"
      - "sudo -u cockpit /usr/bin/bundle install --deployment --without=test"
      - "exec sudo -u cockpit /usr/bin/bundle exec /usr/bin/ruby elexis-cockpit.rb"

  service.running:
    - name: cockpit
    - provider: daemontools
    - enable: True
    - require:
      - pkg:
        -names:
          - ruby-full
          - bundler
      - git: cockpit-checkout
    - watch:
      - git: cockpit-checkout
      - file: /etc/service/cockpit/run
      - file: /etc/service/cockpit/log/run
{% endif %}
