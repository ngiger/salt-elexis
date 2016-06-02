# Defined which users may access which HIN identities
users_for_hinclients:
  test1: # HIN login
    labor:  # OS users using thunderbird/icedove to access above HIN login
    arzt:
    no_such_user: # will be ignored as long it does not appear in users items

include:
  - hinclient.test1
  - hinclient.test2
