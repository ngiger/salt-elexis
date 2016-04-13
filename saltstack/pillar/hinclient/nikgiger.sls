# To ease scripting we use the following
# For each HIN Login we have with the same name a
# - local user (which will run the service)
# - hin identify file name $HOME/$login.hin
# - pillar item hin_passphrase
# - pillar item hin_identiy # which must output of xxd --plain (plain hexdump style)
hin_clients:
  nikgiger:
    hin_login: nikgiger
    # Choose an ID < 1000 or it will appear in the login choices
    uid:       501
    email:     niklaus.giger@hin.ch
    fullname:  Niklaus Giger
  # Where to get the hinclient from, check 4 new versions
    url:  'https://download.hin.ch/download/distribution/install/1.4.0-0/HINClient_unix_1_4_0-0.tar.gz'
    # Redir Ports, on these ports the services will be available
    http_port:  9016
    smtp_port:  9018
    pop3_port:  9019
    imap_port:  9020
    hin_passphrase: DummyPassphrase
    hin_identity: "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
affe"
