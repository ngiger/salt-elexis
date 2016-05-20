# see https://github.com/saltstack-formulas/letsencrypt-formula
{% if pillar.get('letsencrypt', []) %}
include:
  - letsencrypt.install
  - letsencrypt.config
  - letsencrypt.domains
{% endif %}
