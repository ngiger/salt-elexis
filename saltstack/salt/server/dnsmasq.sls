# kate: syntax python; space-indent on; indent-width 4; mixedindent off; replace-tabs on

{% set hostname = salt['pillar.get']('network:dnsmasq_server') %}
{% if grains.host != hostname %}
dnsmasq:
  pkg.removed
/etc/dnsmasq.d/{{hostname}}:
  file.absent
/var/lib/tftpboot:
  file.absent
#    - name: /var/lib/tftpboot

{% else %}
{% if salt['pillar.get']('network:ubuntu_installer', None) %}
include:
  - server.ubuntu_installer
/tmp/ubuntu_installer_true:
  file.managed:
    - mode: 644
    - contents:
      - domain=ngiger.dyndns.org
{% else %}
/tmp/ubuntu_installer_false:
  file.managed:
    - mode: 644
    - contents:
      - domain=ngiger.dyndns.org
      - {{salt['pillar.get']('network:ubuntu_installer', None)}}
{% endif %}

dnsmasq:
  pkg.installed:
    - refresh: false
    - name: dnsmasq
  service.running:
    - name: dnsmasq
    - require:
      - pkg: dnsmasq
    - watch:
      - file: /etc/dnsmasq.d/{{hostname}}
      - file: /etc/hosts
{% if salt['pillar.get']('network:ubuntu_installer', None) %}
      - file: /etc/dnsmasq.d/install_ubuntu.conf
{% endif %}

/etc/dnsmasq.d/{{hostname}}:
  file.managed:
    - mode: 644
    - contents:
      - domain=ngiger.dyndns.org
{% for item in salt['pillar.get']('hw_addr', {}) %}
      - dhcp-host={{item.hw_addr}},{{item.name}},{{item.ip}},120d
{% endfor %}
# TODO: Must use a pillar variable from somewhere
      - expand-hosts
      - dhcp-range=set:cable,172.25.1.150,172.25.1.200,12d
      - dhcp-range=set:cable,172.25.2.150,172.25.2.200,12d
      - '# we use a tag to be able to set the correct gateway when logging from the wlan'
      - dhcp-range=set:wlan,192.168.0.150,192.168.0.200,2h
      - dhcp-option=tag:wlan,3,192.168.0.1
      - dhcp-option=tag:cable,3,172.25.1.60
      - '#'
      - dhcp-option=3,172.25.1.60
      - dhcp-option=tag:cable,3,172.25.1.60
      - dhcp-option=tag:wlan,3,192.168.0.1
      - "# {{salt['pillar.get']('network:dnsmasq_server', {})}}"

{% endif %}

/etc/hosts:
  file.managed:
    - mode: 644
    - contents:
      - 127.0.0.1 localhost
{% if grains.host == hostname %}
    {% set if_name = salt['pillar.get']('network:dnsmasq_interface', 'eth0') %}
    {% set if_addr = salt['grains.get'](if_name, '172.99.99.99') %}
      - {{if_addr[0]}}
      - {{grains.fqdn}} {{grains.host}} {% for name in salt['pillar.get']('network:other_domains', []) %} {{grains.host}}.{{name}}{% endfor %}
{% endif %}
      - 127.0.1.1 {{grains.fqdn}} {{grains.host}} {% for name in salt['pillar.get']('network:other_domains', []) %} {{grains.host}}.{{name}}{% endfor %}
      - '# The following lines are desirable for IPv6 capable hosts'
      - ::1     localhost       ip6-localhost ip6-loopback
      - ff02::1 ip6-allnodes
      - ff02::2 ip6-allrouters
{% for item in salt['pillar.get']('hw_addr', None) %}
      - {{item.ip}} {{item.name}} {{ item.get('aliases', '') }}
{% endfor %}


