# http://wpkg.org/Thunderbird#Thunderbird_Configuration
# http://web.mit.edu/~thunderbird/www/maintainers/autoconfig.html
# Example thunderbird.js with automatically assigned values from ldap.

{%- set ssmtp = pillar.get('ssmtp', False) %}
{% if ssmtp %}
{% if ssmtp.InstallBSD_Mailx %}
bsd_mailx:
  pkg.installed:
    - refresh: false
    - name: bsd-mailx
{% endif %}
ssmtp_install:
  pkg.installed:
    - refresh: false
    - name: ssmtp
/etc/ssmtp/ssmtp.conf:
  file.managed:
    - require:
      - pkg: ssmtp
    - mode: 644
    - contents:
      - "# Managed by salt. Change pillar ssmtp and/or ssmtp.sls "
      - "root={{ssmtp.root}}"
      - mailhub={{ssmtp.mailhub}}
      - rewriteDomain={{ssmtp.rewriteDomain}}
      - hostname={{ssmtp.hostname}}
      - UseSTARTTLS={{ssmtp.UseSTARTTLS}}
      - AuthUser={{ssmtp.AuthUser}}
      - AuthPass={{ssmtp.AuthPass}}
      - FromLineOverride={{ssmtp.FromLineOverride}}
{% endif %}

