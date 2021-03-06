# Allgemeines

Die Firma Medidata (http://www.medidata.ch), welche Mediport vertreibt. arbeitet normalerweise nicht direkt mit Praxen sondern mit Softwarehäusern (wie zB Medelexis).

Wie unter https://wiki.elexis.info/MediPortCommunicator beschrieben, ist es jedoch für Anwender, welche nur die unter der EPL (Eclipse Public License) Teile von
Elexis einsetzen möglich, eine Lizenz zu erhalten.

# Installation

## Manuelle Installation

Die Installation des MPCommunicator ist keine grosse Sache, einfach Installscript aufrufen. Ich empfehle die SW unter /opt zu installieren und das Datenverzeichnis
in einen für alle Clients zugänglichen, gesharten Ordner zu legen. Dann das Start/Stop Script nach /etc/init.d verlinken, deamon user einrichten
und runlevels für autostart konfigurieren, fertig. Ab jetzt muss man nur noch im Datenverzeichnis arbeiten.

Das Filetstück ist dann der Aufbau der mpcommunicator.config Datei im Datenverzeichnis/config. Teilweise kann diese über den Konfig Screens des Plugins erstellt werden.
Es geht jedoch einfacher, wenn man direkt in die Datei schreibt. Siehe beiliegende Datei mpcommunicator.config. Sie enthält die Konfiguration für
2 Ärzte welche sowohl TP (Tier Payant) als auch TG (Tiers Garant) Rechnungen über einen Sender schicken

* Tipp 1:
		Wenn man TG und TP Rechnungen darüber laufen lassen willst ein spezifische Ablageverzeichnis zB unter Datenverzeichnis/ausgang/tp und Datenverzeichnis/ausgang/tg erstellen.
		Wenn man sie direkt ins Datenverzeichnis/data/send ausgibst gibt das Probleme mit dem Sencontrol File

* Tipp2:
		Einfach Mediport Testserver nehmen,  übermitteln und im Webaccess von Mediport schauen ob alles wie gewünscht ankommt...

* Tipp 3:
		Wenn etwas zurückgewiesen wird zeigt Elexis dies an, dazu wird das zurückgekommene XML mit eine Defaultstylesheet verknüpft und im Browser geöffnet.
		Da scheints zumindest in unserer Version ein Problem mit dem Pfad des Stylesheets zu geben die XML kann man trotzdem halt etwas weniger schön formatiert anschauen...

* Tipp 4:
		Viele Probleme im Test hängen nicht mit dem Mediport zusammen, sondern sind auf falsche oder fehlende Daten im Zusammenhang mit den erfassten Krankenkassen im Elexis zurückzufühen.
		Das allerwichtigste sind korrekte EAN Nummern ! Teilweise muss man sogar direkt in der DB Felder editieren weil Elexis keine Dialoge für das Editieren der ID (xid) Daten hat.

## Installation via salt

Folgende Schritte sind zu unternehmen:
* salt (siehe ../../readme.md)  bootstrappen
* Im eigenen pillar_root die Datei saltstack/pillar/mpc.sls kopieren und anpassen
* Im eigenen file_roots pro sender EAN eine Kope der Datei salt/files/EAN<ean>_mpg.keystore hinzufügen
* `sudo salt-call state.apply mpc Test=true` zeigt auf, was gemacht würde
* `sudo salt-call state.apply mpc Test=false` um Änderung durchzuführen

## Testen

* In elexis eine Rechnung erstellen
* In Konfiguration von Mediport vom Produktiver Server: 212.243.92.201 auf  212.243.92.199 wechseln
* Rechnung verschicken
* im Webaccess "https://www.medidata.ch/mp/webaccess" von Mediport schauen, ob Rechnung angekommen ist

## Troubleshooting

* Look at the data/log/mpcommunicator.log. Here some errors and how you can avoid them
** `S ERROR - E2907: Reading server response stream failed[iaik.security.ssl.SSLException: Peer sent alert: Alert Fatal: unknown ca]` Check whether you have the correct, up-to-date config/EAN<ean>_mpg.keystore
** `SSL initialization failed. [F0204: Current certificate not found. null]`. Check whether data/partner/partnerinfo.txt is uptodate and contains the EAN of the mandant used for billing
* In the dialog "Rechnung ausgeben" you choosed "Übermittlung an MediPort" and specified as Ausgabeverzeichnis `/usr/local/mediport/ausgang/tp`. You get the alert "Fehler bei der Ausgabe" with the content "Konnte MediPort-Transmit nicht starten Reason: Fehler in Rechnung Nr <id>"

# TODO

* `sudo setfacl --default  -m group:praxis:rwX /usr/local/mediport`
* `sudo setfacl -R -m group:praxis:rwX /usr/local/mediport`
* In einem docker container laufen lassen

# Autoren

Fabian Schmid
Niklaus Giger
