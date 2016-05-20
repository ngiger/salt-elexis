https://github.com/elexis/elexis-3-core.git:
  git.latest:
    - target: /opt/src/elexis-3-core
#    - require:
#      - pkg: git
maven:
  pkg.installed:
    - refresh: false

build_elexis_core:
  cmd.run:
    - creates: /opt/src/elexis-3-core/ch.elexis.core.p2site/target
    - name: "mvn clean -Dmaven.test.skip=true 2>&1 | tee maven-salt.log"
    - cwd: /opt/src/elexis-3-core

