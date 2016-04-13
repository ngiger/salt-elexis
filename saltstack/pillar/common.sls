common:
  - user21
  - user33

ssmtp:
    root: some.name@provider.com
    mailhub: smtp.provider.com
    rewriteDomain: some.domain
    hostname: smtp.provider.com
    UseSTARTTLS: YES
    AuthUser: some.name@provider.com
    AuthPass: NotSoSecret
    FromLineOverride: Yes
    InstallBSD_Mailx: true
