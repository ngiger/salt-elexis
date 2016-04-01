nfs:
  pkg.installed:
    - pkgs:
      - nfs-kernel-server:
  service.running:
    - name: nfs-kernel-server
    - watch:
      - file: server_nfs_kernel_server
      - file: server_nfs_common
      - file: idmapd_conf

nfs_common:
  service.running:
    - name: nfs-common
    - require:
      - pkg: nfs-common
    - watch:
      - file: server_nfs_common
      - file: idmapd_conf

update_exports:
  cmd.run:
    - name: exportfs -ra
    - watch:
      - file: server_exports

server_nfs_kernel_server:
  file.managed:
    - name: /etc/default/nfs-kernel-server
    - source: salt://server/nfs-kernel-server
    - user: root
    - group: root
    - mode: 644

server_nfs_common:
  pkg.installed:
    - name: nfs-common
  file.managed:
    - name: /etc/default/nfs-common
    - source: salt://server/nfs-common
    - user: root
    - group: root
    - mode: 644

server_exports:
  file.managed:
    - name: /etc/exports
    - source: salt://server/exports
    - template: jinja

idmapd_conf:
  file.managed:
    - name: /etc/idmapd.conf
    - source: salt://server/idmapd.conf
    - user: root
    - group: root
    - mode: 644
/exports:
  file.directory:
    - user:  root
    - name:  /exports
    - group:  root
    - mode:  755

{% for item in salt['pillar.get']('server.config') %}
{{item.name}}:
  file.directory:
    - name: {{item.name}}
/exports/{{ salt['file.basename'](item.name) }}:
  file.directory:
    - name: /exports/{{ salt['file.basename'](item.name) }}
    - mode: 777
  cmd.run:
    - name: /bin/mount --bind {{ item.name }} /exports/{{ salt['file.basename'](item.name) }}
#    - creates: /exports/{{ salt['file.basename'](item.name) }}
{% endfor %}


{% if false %}
{% endif %}
