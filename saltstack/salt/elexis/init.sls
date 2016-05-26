# kate: space-indent on; indent-width 2
include:
  {% if grains['os'] != 'Windows' %}
  - users
  - java8
  - elexis.medelexis # iterates over all defined Medelexis installations
  - elexis.opensource # iterates over all defined opensource installations
  {% if pillar.get('server', {})['with_elexis_cockpit'] %}
  - elexis.cockpit
  {% endif %}
  {% elif grains['os'] == 'Windows' %}
  - elexis.install_elexis_opensource_under_windows
  {% endif %}
