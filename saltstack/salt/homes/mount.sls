nfs-common:
  pkg.installed:
    - pkgs:
      - nfs-common:

{% for item in salt['pillar.get']('server.config') %}

{{item.mount_point}}:
  file.directory:
    - makedirs: True
  mount.mounted:
    - device: {{item.server_ip}}:{{item.server_name}}
    - fstype: nfs4
    - mkmnt: True
    - config: /etc/fstab
    - persist: True
    - opts:
      - {{item.mount_opts}}
{% endfor %}


