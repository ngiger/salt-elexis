# Dokumentation des Aufsetzten eines HIN-Clients

Vorgängig muss aus einem Windows oder Mac der Zugang zum HIN konfiguriert werden, da HIN leider Linux nur halbwegs unterstützt.

Im Moment muss der HIN-Client noch von Hand gestartet werden. Dazu /usr/local/bin/restart_<HIN login>_hin_client aufrufen. Sollte man bei Gelegenheit als Service oder Desktop verpacken.

Es kann nur eine HIN-Identität pro Linux-Server laufen!

Der ganze Setup basiert auf einem Shell Script von Fabian Schmid, das man als Referenz unter [file/client.sh](file/client.sh) anschauen kann.

Den Inhalt des *.hin-Identiyfiles, passwort, e-mail, etc muss man im pillar analog zum [Beispiel](../../pillar/hinclient/init.sls) beim eigenen Pillar anpassen.

