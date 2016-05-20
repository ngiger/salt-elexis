{% for elexis_install in  pillar.get('elexis_installation', []) %}
{{elexis_install.inst_path}}_test:
  file.managed:
    - contents:
      - For {{elexis_install.inst_path}}
      - URI {{elexis_install.download_uri}}
      - Hash {{elexis_install.hash}}
{{elexis_install.inst_path}}:
  archive.extracted:
    - if_missing: {{elexis_install.inst_path}}/Elexis3
    - name: {{elexis_install.inst_path}}
    - source: {{elexis_install.download_uri}}
    - source_hash: {{elexis_install.hash}}
    - archive_format: zip
{{elexis_install.inst_path}}/Elexis3:
  file.managed:
    - mode: 755
    - require:
        - archive: {{elexis_install.inst_path}}
        # - java: # not yet handled under Windows
{% endfor %}
