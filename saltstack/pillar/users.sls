users_absent:
  - name: niklaus
    purge: True

# keep the UID far away from the normally generated ones
# /mnt/homes must be in sync the the pillar/users.sls file
users:
#  - name: arzt
#    uid: 2000
#    gid: 2000
#    home: /mnt/homes/arzt
#  - name: mpa
#    uid: 2001
#    gid: 2001
#    home: /mnt/homes/mpa
  - name: labor
    uid: 2002
    gid: 2002
    home: /mnt/homes/labor
    git_setttings: True
