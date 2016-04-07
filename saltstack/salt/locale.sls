
# see https://github.com/saltstack/salt/issues/24433
# this must be done, until salt issue #24433 has been fixed

/etc/locale.gen:
  file.managed:
    - contents:
      - de_CH.UTF-8 UTF-8
      - en_US.UTF-8 UTF-8

/etc/default/locale:
  file.managed:
    - contents:
      - LANG=de_CH.UTF-8
      - LANGUAGE=de_CH

{% if true  %}

generate_locale:
  cmd.run:
    # TODO: Here salt hangs if I try to run this command. Why?
    - name: locale-gen de_CH.UTF-8
{% endif %}
