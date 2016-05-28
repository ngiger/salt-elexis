users_absent:
  - name: pi
    purge: True

sudo:
  no_passwd: true # Set to false to fore sudo users to enter a password before calling sudo a first time

groups:
  - name: praxis
    gid:  3000

# keep the UID far away from the normally generated ones
# /mnt/homes must be in sync the the pillar/users.sls file
users:
  - name: arzt
    uid: 2000
    gid: 2000
    home: /mnt/homes/arzt
    fullname: Dr. med. Aeskulap
    groups: [ praxis, adm, lpadmin, ssh, sudo ]
  - name: mpa
    uid: 2001
    gid: 2001
    home: /mnt/homes/mpa
    groups: [ praxis ]
#  - name: labor
#    uid: 2002
#    gid: 2002
#    home: /mnt/homes/labor
#    git_setttings: True
