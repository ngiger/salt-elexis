# These settings should be okay for the Vagrantfile

server:
  name:  ElexisServerDemo
  ip: 192.168.1.90
  # name is defined in common.sls
network:
  domain_name: elexis-demo.dyndns.org
  ip_network: 192.168.1.0/24

  # Next items need only if you want a DHCP client and DNS cache with dnsmasq
  gateway: 192.168.1.90
  dnsmasq:
    interface: ip4_interfaces:eth1
    server: ElexisDemoServer
    ubuntu_installer: true
    dhcp-range: 192.168.1.150,192.168.1.200

  # other_domains is only needed when you have multiple dynamique DNS clients
  # other_domains:
  #  - elexis-demo2.dyndns.org

# name/ip/hw_addr must be kept in sync betweeen Vagrantfile and saltstack/pillar/network.sls
hw_addr:
  - name: ElexisServerDemo
    hw_addr: 00:00:00:68:01:90
    ip: 192.168.1.90
    aliases: prxserver
  - name: ElexisLaborDemo
    hw_addr: 00:00:00:68:01:91
    ip: 192.168.1.91
    aliases: labor mpa
  - name: ElexiArztDemo
    hw_addr: 00:00:00:68:01:93
    ip: 192.168.1.93
    aliases: arzt