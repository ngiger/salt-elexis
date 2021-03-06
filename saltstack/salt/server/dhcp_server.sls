# kate: syntax python; space-indent on; indent-width 4; mixedindent off; replace-tabs on

{% set dnsmasq_lease_time = salt['pillar.get']('network:dnsmasq_lease_time', '12h') %}
{% set ip_24_base = salt['pillar.get']('network:ip_24_base', '192.168.0') %}
{% set gateway = salt['pillar.get']('network:gateway', '192.168.0.1') %}
dnsmasq_for_dhcpserver:
  pkg.installed:
    - refresh: false
    - name: dnsmasq
  service.running:
    - name: dnsmasq
    - require:
      - pkg: dnsmasq
{% if salt['pillar.get']('network:ubuntu_installer', None) %}
      - file: /etc/dnsmasq.d/install_ubuntu.conf
include:
  - server.ubuntu_installer
{% endif %}

# dhcpcd has the ability to prepend or append nameservers to /etc/resolv.conf by creating (or editing) the /etc/resolv.conf.head and /etc/resolv.conf.tail files respectively:
# echo "nameserver 127.0.0.1" > /etc/resolv.conf.head
/etc/dnsmasq.d/{{grains.host}}:
    file.absent
/etc/dnsmasq.d/dhcp_server:
  file.managed:
    - mode: 644
    - contents:
      # we do not specify any interface nor listen address to allow reading on all
      - '#'
      - '# default dhcp range'
      # dhcp-range=192.168.1.3,192.168.1.99,255.255.255.0,1h
      - dhcp-range={{ip_24_base}}.3,{{ip_24_base}}.254,255.255.255.0,1h
      - '#'
      - '# we use a tag to be able to set the correct gateway when accessing via the cable network'
      - dhcp-range=set:cable,{{ip_24_base}}.100,{{ip_24_base}}.149,{{dnsmasq_lease_time}}
      - '#'
      - '# we use a tag to be able to set the correct gateway when logging from the wlan'
      - dhcp-range=set:wlan,{{ip_24_base}}.150,{{ip_24_base}}.200,{{dnsmasq_lease_time}}
      - '#'
      - '# DHCP-Option 3 is default gateway'
      - dhcp-option=tag:wlan,3,{{gateway}}
      - dhcp-option=tag:cable,3,{{gateway}}
      - '#'

/etc/dnsmasq.d/hosts:
  file.managed:
    - mode: 644
    - contents:
{% for item in salt['pillar.get']('hw_addr', {}) %}
      - dhcp-host={{item.hw_addr}},{{item.name}},{{item.ip}},{{dnsmasq_lease_time}}
{% endfor %}
