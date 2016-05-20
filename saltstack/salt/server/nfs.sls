# /usr/share/doc/nfs-common/README.Debian.nfsv4
# http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration

# It is important that the server does not contain any fsid=0 entry in the /etc/exports! eg. next line is okay
# /exports 192.168.0.0/16(rw,no_subtree_check,all_squash) 172.25.1.0/24(rw,no_subtree_check,all_squash)

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
#      - file: server_nfs_kernel_server
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
      - file: server_exports

server_nfs_common:
  pkg.installed:
    - name: nfs-common
  file.managed:
    - name: /etc/default/nfs-common
    - source: salt://server/file/nfs-common
    - user: root
    - group: root
    - mode: 644

server_exports:
  file.managed:
    - name: /etc/exports
    - source: salt://server/file/exports
    - template: jinja

/exports:
  file.directory:
    - user:  root
    - name:  /exports
    - group:  root
    - mode:  755

server_tst:
  file.managed:
    - name: /tmp/exports
    - contents:
      - salt['pillar.get']('server', {})

{% for item in salt['pillar.get']('server', {})['nfs4'] %}
{{item.server_name}}:
  file.directory:
    - name: {{item.server_name}}
    - require:
        - file: /exports
/exports/{{ salt['file.basename'](item.server_name) }}:
  file.directory:
    - name: /exports/{{ salt['file.basename'](item.server_name) }}
    - mode: 777
  cmd.run:
    - name: /bin/mount --bind {{ item.server_name }} /exports/{{ salt['file.basename'](item.server_name) }}
    - unless: grep -c {{salt['file.basename'](item.server_name) }} /etc/mtab
#    - creates: /exports/{{salt['file.basename'](item.server_name) }}
{% endfor %}
