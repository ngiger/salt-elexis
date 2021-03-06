/etc/idmapd.conf:
  file.managed:
    - name:
    - user: root
    - group: root
    - mode: 644
    - contents:
        - '[General]'
        - Verbosity = 0
        - Pipefs-Directory = /run/rpc_pipefs
        - '# set your own domain here, if id differs from FQDN minus hostname'
        - 'Domain = {{ grains.domain}}'
        - '[Mapping]'
        - Nobody-User=nobody
        - Nobody-Group=nogroup
