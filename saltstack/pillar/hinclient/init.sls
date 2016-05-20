# Defined which users may access which HIN identities
users_for_hinclients:
  test1: # HIN login
    labor:  # OS users using thunderbird to access above HIN login

include:
  - hinclient.test1
  - hinclient.test2
