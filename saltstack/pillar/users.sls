users_absent:
  - name: pi
    purge: True

# keep the UID far away from the normally generated ones
# /mnt/homes must be in sync the the pillar/users.sls file
users:
  - name: arzt
    uid: 2000
    gid: 2000
    home: /mnt/homes/arzt
    groups: [ praxis, adm, lpadmin, ssh, sudo ]
  - name: mpa
    uid: 2001
    gid: 2001
    home: /mnt/homes/mpa
    groups: [ praxis ]
groups:
  - name: praxis
    gid:  3000

#  - name: labor
#    uid: 2002
#    gid: 2002
#    home: /mnt/homes/labor
#    git_setttings: True
