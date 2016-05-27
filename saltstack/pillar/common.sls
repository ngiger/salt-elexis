# define ssmtp if you want to have a simple method of sending E-Mails from the server and clients
ssmtp:
    root: some.name@provider.com
    mailhub: smtp.provider.com
    rewriteDomain: some.domain
    hostname: smtp.provider.com
    UseSTARTTLS: YES
    AuthUser: some.name@provider.com
    AuthPass: NotSoSecret
    FromLineOverride: Yes
    InstallBSD_Mailx: true

# /mnt/homes must be in sync the the pillar/users.sls file
server:
  with_elexis_cockpit: true
  nfs4: # Please be aware that we NFS setup will fail if you specify somewhere int mount_opts fsid=0
    - server_name: /home
      export_opts: rw,no_subtree_check,no_root_squash
      mount_opts: rw,soft,intr,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
      mount_point: /mnt/homes
      server_ip: 192.168.1.90
    - server_name: /opt
      export_opts: rw,no_subtree_check,no_root_squash
      mount_opts: rw,soft,intr,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
      mount_point: /opt
      server_ip: 192.168.1.90
    - server_name: /backup
      export_opts: rw,no_subtree_check,no_root_squash
      mount_opts: rw,soft,intr,rsize=32768,wsize=32768,timeo=14,intr,actimeo=10
      mount_point: /backup
      server_ip: 192.168.1.90

