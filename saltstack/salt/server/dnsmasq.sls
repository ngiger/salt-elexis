# kate: syntax python; space-indent on; indent-width 4; mixedindent off; replace-tabs on

dnsmasq:
  pkg.installed:
    - refresh: false
    - name: dnsmasq
  service.running:
    - name: dnsmasq
    - require:
      - pkg: dnsmasq
    - watch:
      - file: /etc/dnsmasq.d/salt.conf
      - file: /etc/hosts

# dhcpcd has the ability to prepend or append nameservers to /etc/resolv.conf by creating (or editing) the /etc/resolv.conf.head and /etc/resolv.conf.tail files respectively:
# echo "nameserver 127.0.0.1" > /etc/resolv.conf.head

/etc/resolv.conf.head:
  file.managed:
    - mode: 644
    - contents:
      - nameserver 127.0.0.1

/etc/dnsmasq.d/salt.conf:
  file.managed:
    - mode: 644
    - contents:
      - local=/{{salt['pillar.get']('network:domain_name', 'local')}}/
      - domain={{salt['pillar.get']('network:domain_name', 'local')}}
# TODO: Must use a pillar variable from somewhere
      - expand-hosts
      # The following directives prevent dnsmasq from forwarding plain names (without any dots) or addresses in the non-routed address space to the parent nameservers.
      - domain-needed
      - bogus-priv
      # Here we use a separate file where dnsmasq reads the IPs of the parent nameservers from.
      - server=8.8.8.8
      - server=8.8.4.4
      - no-poll

/etc/hosts:
  file.managed:
    - mode: 644
    - contents:
      - 127.0.0.1 localhost
    {% set if_name = salt['pillar.get']('network:dnsmasq_interface', 'eth0') %}
    {% set if_addr = salt['grains.get'](if_name, '172.99.99.99') %}
      - # {{if_addr[0]}}
      - # {{grains.fqdn}} {{grains.host}} {% for name in salt['pillar.get']('network:other_domains', []) %} {{grains.host}}.{{name}}{% endfor %}
      - 127.0.1.1 {{grains.fqdn}} {{grains.host}} {% for name in salt['pillar.get']('network:other_domains', []) %} {{grains.host}}.{{name}}{% endfor %}
      - '# The following lines are desirable for IPv6 capable hosts'
      - ::1     localhost       ip6-localhost ip6-loopback
      - ff02::1 ip6-allnodes
      - ff02::2 ip6-allrouters
{% for item in salt.pillar.get('hw_addr', {})  %}
      - {{item.ip}} {{item.name}} {{ item.get('aliases', '') }}
{% endfor %}


