server.config:
  - name: /home
    nfs3_opts: 192.168.1.0/24(rw,insecure,root_squash,no_subtree_check,crossmnt,fsid=0)
    mount_opts: soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
    mount_point: /mnt/homes
  - name: /opt
    nfs3_opts: 192.168.1.0/24(rw,insecure,root_squash,no_subtree_check,crossmnt,fsid=0)
    mount_opts: soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
    mount_point: /opt
  - name: /backup
    nfs3_opts: 192.168.1.0/24(rw,insecure,no_root_squash,no_subtree_check,crossmnt,fsid=0)
    mount_opts: soft,intr,rw,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
    mount_point: /mnt/backup
