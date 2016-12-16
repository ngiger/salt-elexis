debconf-utils:
  pkg.installed:
    - refresh: false

{% set java_version = salt['pillar.get']('java_version', '8') %}
{% set open_jdk_jre = "openjdk-{{java_version}}-jre" %}

{% if salt['pkg'].version(
) %}
install_openjdk:
  pkg.installed:
    - refresh: false
    - name: "{{open_jdk_jre}}"
oracle_absent:
  pkg.purged:
    - refresh: false
    - name: "oracle-java{{java_version}}-installer"

{% else %}

{% if grains['os_family'] ~ 'Debian|Mint' %}
oracle-java{{ java_version }}-installer:
  {% if grains['os'] == 'Ubuntu' %}
  pkgrepo.managed:
    - ppa: webupd8team/java
  {% elif grains['os'] ~ 'Debian|Mint' %}
  pkgrepo.managed:
    - humanname: WebUp8Team Java Repository
    - name: "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main"
    - dist: precise
    - file: /etc/apt/sources.list.d/webup8team.list
    - keyid: EEA14886
    - keyserver: keyserver.ubuntu.com
  {% endif %}
  pkg.installed:
    - refresh: false
    - require:
      - pkgrepo: oracle-java{{java_version}}-installer
  debconf.set:
   - data:
       'shared/accepted-oracle-license-v1-1': {'type': 'boolean', 'value': True}
   - require_in:
       - pkg: oracle-java{{java_version}}-installer
   - require:
        - pkg: debconf-utils
{% endif %}
{% endif %}
