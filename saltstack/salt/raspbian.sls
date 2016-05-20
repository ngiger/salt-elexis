{% if grains.os == 'Raspbian' %}
raspbian-backports-pkgrepo:
  pkgrepo.managed:
    - humanname: Jessie Backports
    - name: deb http://raspbian-backports.sourceforge.net backports/
    - file: /etc/apt/sources.list.d/raspbian-backports.list
oracle-java8-jdk:
  pkg.installed:
    - refresh: false

{% endif %}
