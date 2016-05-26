nfs-common:
  pkg.installed:
    - refresh: false
    - pkgs:
      - nfs-common:

{% for item in salt['pillar.get']('server', {})['nfs4'] %}

{{item.mount_point}}:
  file.directory:
    - makedirs: True
  mount.mounted:
    - device: {{item.server_ip}}:{{item.server_name}}
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - {{item.mount_opts}}
    # Hack to avoid seeing changes every time I run salt-apply
    - unless: egrep "{{item.server_ip}}:{{item.server_name}}.*{{item.mount_opts}}" /etc/fstab && grep " {{item.mount_point}}" /etc/mtab
{% endfor %}


