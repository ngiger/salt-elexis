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

{% if grains.host == pillar.get('server.name', '') %}
{% set install_dir = '/opt/checkout/cockpit' %}
cockpit:
  user.present:
    - enforce_password: false
    - shell: /usr/sbin/nologin

cockpit-checkout:
  git.latest:
    - name: https://github.com/elexis/elexis-cockpit.git
    - target: {{install_dir}}

ruby-full:
  pkg.installed:
    - refresh: false
    - name:
      - ruby-full
      - bundler
      - daemontools

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
    - watch:
      - git: cockpit-checkout
      - pkg: ruby-full
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

      - "exec sudo -u cockpit /usr/bin/bundle exec /usr/bin/ruby elexis-cockpit.rb"

{% if true %}
  service.running:
    - name: cockpit
    - provider: daemontools
    - enable: True
    - require:
      - pkg: ruby-full
      - git: cockpit-checkout
    - watch:
      - git: cockpit-checkout
      - file: /etc/service/cockpit/run
      - file: /etc/service/cockpit/log/run
{% endif %}
{% endif %}
