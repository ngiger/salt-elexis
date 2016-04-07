# wget http://www.irfanview.info/files/iview442g_x64_setup.exe
# http://www.irfanview.info/files/iview442g_x64.zip
# http://0.0.0.0:3333/issues/81

# https://download.heise.de/software/2b24d5450017ac21527bf668e1f31421/5700079b/188237/iview442g_x64_setup.exe
# https://download.heise.de/software/5971b32cf823736600750e75df484a35/570007e1/188404/irfanview_plugins_442_setup.exe

# Download von irfanview and irfanview-plugins via Heise.de. Default download schlug fehlt. Eventuell wird die Seite blockiert, da keine Java/Javascript oder ähnliche im firefox aktiviert wurde.
# wine ~/downloads/iview438_setup.exe schlug fehl, da MFC42.DLL fehlte.
# winetricks mfc432
# wine ~/Downloads/iview438_setup.exe läuft diesmal gut. Kein Chrome installiert (siehe Irfanview_1.png), Ausgabe in persönlichen Order wie für Windows empfohlen (siehe Irfanview_2.png). Keine Analyse für Ausgabe auf Konsole wegen kritschen Fehler wegen glibc gemacht
# wine ~/Downloads/irfanview_plugins_438_setup.exe lief ohne Probleme durch.
# Danach konnte ohne Probleme eine PNG-Datei angeschaut werden.
# Icon auf Desktop angelegt. Ausführbar gemacht. Diverse Dateitype angehängt. Danach war es möglich, irfanview zu Favoriten und zur Kontrolleiste hinzuzufügen.
# Gemäss http://wiki.winehq.org/FAQ#head-f54d469b937b82e6d757a851dfcece0167919859 könnte man nun den /home/sbu/.wine-Ordner -> /home/psy kopieren, um sich die Neuinstallation zu erparen.
# Damit PDF geöffnet werden können, musste zusätzlich noch (die 32-Bit) Version von GhostScripts installiert werden. Die Exe-Datei mittels wine installiert. Nemo weigert sich für PDF IrfanView als default Applikation zu betrachen. Im Kontextmenu (rechter Mausclick) taucht Irfanview jedoch auf.

irfanview-setup:
  pkg.install:
    - pkgs:
      - name: wine-bin
