# To ease scripting we use the following
# For each HIN Login we have with the same name a
# - local user (which will run the service)
# - hin identify file name $HOME/$login.hin
# - pillar item hin_passphrase
# - pillar item hin_identiy # which must output of xxd --plain (plain hexdump style)
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
    hin_identity: "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
affe"
