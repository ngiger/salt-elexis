# Allgemeines

Die Firma Medidata (http://www.medidata.ch), welche Mediport vertreibt. arbeitet normalerweise nicht direkt mit Praxen sondern mit Softwarehäusern (wie zB Medelexis).

Mann muss sich dort als freie Praxis dort anmelden, und direkt als Softwarehaus deklarieren, unzählige Verträge unterzeichen und einen vollen Testzyklus durchlaufen
bevor man den benötigen MPCommunicator und produktive Zertifikate erhälst. 2-6 Wochen nervigen Mailverkehr  sind einrechnen, aber am Schluss gehts.

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
* MediPortCommunicator-Linux_64.zip runter laden und z.B. unter /opt/downloads/ speichern. (MediData gewährt bis jetzt leider keinen öffentlichen Zugang zu dieser Datei)
* Im eigenen pillar_root die Datei saltstack/pillar/mpc.sls kopieren und anpassen
* Im eigenen file_roots pro sender EAN eine Kope der Datei salt/files/EAN<ean>_mpg.keystore hinzufügen
* ´´´´sudo salt-call state.apply mpc Test=true´´´´ zeigt auf, was gemacht würde
* ´´´´sudo salt-call state.apply mpc Test=false´´´´ um Änderung durchzuführen

## Testen

* In elexis eine Rechnung erstellen
* In Konfiguration von Mediport vom Produktiver Server: 212.243.92.201 auf  212.243.92.199 wechseln
* Rechnung verschicken
* im Webaccess von Mediport schauen, ob Rechnung angekommen ist

# TODO

* In eine docker container laufen lassen

# Autoren

Fabian Schmid
Niklaus Giger

