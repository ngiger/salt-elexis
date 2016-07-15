include:
  {% if grains['os'] != 'Windows' %}
  - users
  - java8
{% if pillar.get('medelexis', false) %}
  - elexis.medelexis # iterates over all defined Medelexis installations
{% endif %}
  - elexis.opensource # iterates over all defined opensource installations
  {% if pillar.get('server', {}).get('with_elexis_cockpit', false) %}
  - elexis.cockpit
  {% endif %}
  {% elif grains['os'] == 'Windows' %}
  - elexis.install_elexis_opensource_under_windows
  {% endif %}
