# Defined which users may access which HIN identities
users_for_hinclients:
  test1: # HIN login
    labor:  # OS users using thunderbird/icedove to access above HIN login
    arzt:
    no_such_user: # will be ignored as long it does not appear in users items

hin_clients:
  test1:
    hin_login: test1
    # Choose an ID < 1000 or it will appear in the login choices
    uid:       501
    email:     test1r@hin.ch
    fullname:  Test 1 Elexis-Demo
  # Where to get the hinclient from, check 4 new versions
    url:  'https://download.hin.ch/download/distribution/install/1.4.0-0/HINClient_unix_1_4_0-0.tar.gz'
    # Redir Ports, on these ports the services will be available
    http_port:  9116
    smtp_port:  9118
    pop3_port:  9119
    imap_port:  9120
    hin_passphrase: DummyPassphrase
    hin_passphrase_replace: true # if set to true users will be unable to change the passphrase for thein HIN account
    hin_identity_file:  salt://files/hin_client/test1.hin
  test2:
    hin_login: test2
    # Choose an ID < 1000 or it will appear in the login choices
    uid:       501
    email:     niklaus.giger@hin.ch
    fullname:  Niklaus Giger
  # Where to get the hinclient from, check 4 new versions
    url:  'https://download.hin.ch/download/distribution/install/1.4.0-0/HINClient_unix_1_4_0-0.tar.gz'
    # Redir Ports, on these ports the services will be available
    http_port:  9216
    smtp_port:  9218
    pop3_port:  9219
    imap_port:  9220
    hin_passphrase: NoSecretAtAll
    hin_identity_file:  salt://files/hin_client/test2.hin

