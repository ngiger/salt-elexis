{% for user in pillar['users'] %}
user_{{user.name}}:
  group.present:
    - name: {{user.name}}
    - gid: {{user.gid}}

  user.present:
    - name: {{user.name}}
    - uid: {{user.uid}}
    - gid: {{user.gid}}
    {% if user.get('groups', user.name) %}
    - optional_groups:
      {% for group in user.get('groups', user.name) %}
      - {{group}}
      {% endfor %}
    {% endif %}
    - require:
      - group: user_{{user.name}}

{% endfor %}

