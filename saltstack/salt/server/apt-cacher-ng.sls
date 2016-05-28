# kate: syntax python; space-indent on; indent-width 4; mixedindent off; replace-tabs on

{% set hostname = salt['pillar.get']('network:apt_cacher_ng_server', false) %}
{% if hostname %}
apt_proxy:
  file.managed:
    - name: /etc/apt/apt.conf.d/99_proxy
    - contents:
        - 'Acquire::http::Proxy "http:/{{hostname}}:3142";'
        - 'Acquire::http::Proxy {'
        - '  download.oracle.com DIRECT;'
        -  '};'
{% if grains.host == hostname %}
apt_cacher_ng_server:
  pkg.installed:
    - refresh: false
    - name: apt-cacher-ng
  service.running:
    - name: apt-cacher-ng
{% endif %}
{% endif %}


