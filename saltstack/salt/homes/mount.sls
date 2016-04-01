{% if false %}

homes.mount:
  pkg.installed:
    - name: nfs4-acl-tools
/mnt/opt:
  mount.mounted:
    - device: 192.168.1.222:/opt
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
/mnt/home:
  mount.mounted:
    - device: 192.168.1.222:/home
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
{% endif %}

{% for item in salt['pillar.get']('server.config') %}

{{item.mount_point}}:
  file.directory:
    - name: {{item.mount_point}}
    - makedirs: True
  mount.mounted:
    - name: {{item.mount_point}}
    - device: 192.168.1.222:{{item.name}}
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - {{item.mount_opts}}
{% endfor %}


