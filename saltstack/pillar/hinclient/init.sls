# Defined which users may access which HIN identity
# Only one can be defined
users_for_hinclients:
  test1: # HIN login
    labor:  # OS users using thunderbird to access above HIN login
    arzt:
    no_such_user: # will be ignored as long it does not appear in users items

hin_clients:
  musterpraxis: # Nur für SALT Relevant
    hin_login: musterpraxis # Name der Verwendeten HIN-Datei
    # Choose an ID < 1000 or it will appear in the login choices
    uid:       503
    email:     praxis.mustermannr@hin.ch
    fullname:  Praxis Dr. Max Mustermann
    # Redir Ports, on these ports the services will be available to all linux users
    http_port:  50016
    smtp_port:  50018
    pop3_port:  50019
    imap_port:  50020
    hin_passphrase: max_hat_ein_geheimes_passwort
    hin_passphrase_replace: true # Soll das Thunderbird-Profile überschrieb werden
    hin_identity_file:  salt://files/hin_client/test1.hin
