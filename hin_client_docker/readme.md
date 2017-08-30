# Dokumentation des Aufsetzten eines HIN-Clients

Vorgängig muss aus einem Windows oder Mac der Zugang zum HIN konfiguriert werden, da HIN leider Linux nur halbwegs unterstützt.

Im Moment muss der HIN-Client noch von Hand gestartet werden. Dazu /usr/local/bin/restart_<HIN login>_hin_client aufrufen. Sollte man bei Gelegenheit als Service oder Desktop verpacken.

Es kann nur eine HIN-Identität pro Linux-Server laufen!

Der ganze Setup basiert auf einem Shell Script von Fabian Schmid, das man als Referenz unter [file/client.sh](file/client.sh) anschauen kann.

Den Inhalt des *.hin-Identiyfiles, passwort, e-mail, etc muss man im pillar analog zum [Beispiel](../../pillar/hinclient/init.sls) beim eigenen Pillar anpassen.

GEmäss mail brauchen wir

http://deepspacepixels.net/posts/4


Besten Dank für Ihre Anfrage. Das Problem ist wie Sie bereits vermutet haben nicht Ihre Internet Verbindung.

Mit der Aktuellsten OpenJDK und OracleJava hat der HIN Client ein Problem und funktioniert nicht richtig.
Wir Empfehlen Ihnen eine Extra Java Installation zu erstellen, und diese ältere Version für den HIN Client zu nutzen.

Bitte verwenden Sie dazu OpenJDK Version 8u121b13. Ein Fix des Problems ist leider erst in der übernächsten HIN Client version geplant.
Sehr wahrscheinlich im Oktober oder November dieses Jahr.

Besten dank für Ihr Verständnis

Freundliche Grüsse

Patrick Raths


https://www.oracle.com/webfolder/s/digest/8u121checksum.html

jdk-8u121-linux-x64.tar.gz

wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz"
tar xzf jdk-8u121-linux-x64.tar.gz

wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz"
tar xzf jdk-8u121-linux-x64.tar.gz


http://www.oracle.com/technetwork/java/javase/downloads/java-archive-javase8-2177648.html


wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"  http://download.oracle.com/otn/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz

http://download.oracle.com/otn/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jre-8u121-linux-x64.tar.gz

-> /opt/downloads/jdk-8u121-linux-x64.tar.gz

sudo apt-get install java-package
make-jpkg /opt/downloads/jdk-8u121-linux-x64.tar.gz (get ein paar wenige Minuten)
