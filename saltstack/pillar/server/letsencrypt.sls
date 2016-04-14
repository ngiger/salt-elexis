# Change the entries to the desired values:
# Then change in the next line letsencrypt_example -> letsencrypt
letsencrypt_example:
  config: |
    server = https://acme-v01.api.letsencrypt.org/directory
    email = webmaster@example.com
    authenticator = webroot
    webroot-path = /var/lib/www
    agree-tos = True
    renew-by-default = True
  domainsets:
    www:
      - example.com
      - www.example.com
    mail:
      - imap.example.com
      - smtp.example.com
      - mail.example.com
    intranet:
      - intranet.example.com

