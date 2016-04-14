# /mnt/homes must be in sync the the pillar/users.sls file
include:
  - server.letsencrypt

server.name:  prxserver

server.config:
  - server_name: /home
    nfs3_opts: 192.168.1.0/24(rw,insecure,root_squash,no_subtree_check,crossmnt,fsid=0)
    mount_opts: soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
    mount_point: /mnt/homes
    server_ip: 192.168.1.222
  - server_name: /opt
    nfs3_opts: 192.168.1.0/24(rw,insecure,root_squash,no_subtree_check,crossmnt,fsid=0)
    mount_opts: soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
    mount_point: /mnt/opt
    server_ip: 192.168.1.222
  - server_name: /backup
    nfs3_opts: 192.168.1.0/24(rw,insecure,no_root_squash,no_subtree_check,crossmnt,fsid=0)
    mount_opts: soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
    mount_point: /mnt/backup
    server_ip: 192.168.1.222
