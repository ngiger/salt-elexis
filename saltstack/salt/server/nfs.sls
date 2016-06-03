# /usr/share/doc/nfs-common/README.Debian.nfsv4
# http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration

# It is important that the server does not contain any fsid=0 entry in the /etc/exports! eg. next line is okay
# /exports 192.168.0.0/16(rw,no_subtree_check,all_squash) 172.25.1.0/24(rw,no_subtree_check,all_squash)
# Also we need a linux kernel >= 3.4

# Not sure whether we shoud enable idmapping or not
# see https://www.novell.com/support/kb/doc.php?id=7014266
include:
  - server.idmap

nfs:
  pkg.installed:
    - refresh: false
    - pkgs:
      - nfs-kernel-server:
      - rpcbind:
  service.running:
    - name: nfs-kernel-server
    - watch:
      - file: /etc/exports
      - file: server_nfs_common

server_nfs_kernel_server:
  file.managed:
    - name: /etc/default/nfs-kernel-server
    - source: salt://server/file/nfs-kernel-server
    - user: root
    - group: root
    - mode: 644

nfs_common:
  service.running:
    - name: nfs-common
    - require:
      - pkg: nfs-common
    - watch:
      - file: server_nfs_common
      - file: /etc/idmapd.conf

update_exports:
  cmd.run:
    - name: exportfs -ra
    - watch:
      - file: /etc/exports

server_nfs_common:
  pkg.installed:
    - name: nfs-common
  file.managed:
    - name: /etc/default/nfs-common
    - source: salt://server/file/nfs-common
    - user: root
    - group: root
    - mode: 644

/etc/exports:
  file.managed:
    - name: /etc/exports
    - contents:
{% for item in salt['pillar.get']('server', {})['nfs4'] %}
      - {{ item.server_name }} {{salt['pillar.get']('network', {})['ip_network'] }}({{ item.export_opts}}){% endfor %}

{% for item in salt['pillar.get']('server', {})['nfs4'] %}
nfs_{{item.server_name}}:
  file.directory:
    - name: {{item.server_name}}
{% endfor %}

{% for item in salt['pillar.get']('server', {})['soft_links'] %}
soft_link_{{item.name}}:
  file.symlink:
    - name: {{item.name}}
    - target: {{item.target}}
{% endfor %}

