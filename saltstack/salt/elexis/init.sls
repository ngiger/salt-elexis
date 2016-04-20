include:
  {% if grains['os'] != 'Windows' %}
  - users
  - java8
  - elexis.medelexis
  - elexis.opensource
  {% elif grains['os'] == 'Windows' %}
  - elexis.install_elexis_opensource_under_windows
  {% endif %}
