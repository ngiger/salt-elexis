#!/bin/bash
# Niklaus Giger 2016-04-01. Generated from salt/elexis/file/medelexis.sh
# fail on error
set -x # show commands being executed

# configuration
export DB_TO_USE={{app.db_to_use}}
export ELEXIS_VARIANT={{app.variant}}
export ELEXIS_ZIP_FILE={{medelexis.linux_x86_64}}
export ELEXIS_CONFIG="{{app.config}}"
export ELEXIS_DB_CONFIG_ARGS="-Dch.elexis.dbFlavor={{elexis.db_type}} \
-Dch.elexis.dbSpec=jdbc:{{elexis.db_type}}://{{elexis.db_server}}/{{app.db_to_use}} \
-Dch.elexis.dbUser={{elexis.db_user}} \
-Dch.elexis.dbPw={{elexis.db_password}}"

export ECLIPSEPASSWORD_FILE="${HOME}/.medelexis.dummy.password"
export DEFAULT_LICENSE="/etc/license.xml"

# some constants
export MEDELEXIS_LICENSE="${HOME}/elexis/license.xml"

xml_config="${HOME}/elexis/localCfg_${ELEXIS_CONFIG}.xml"
echo $xml_config
if [ -f "${xml_config}" ] &&  [ `grep storedJDBCConnections  ${xml_config}` ]
then
  msg="storedJDBCConnections aus ${xml_config} wird gebraucht"
  echo $msg
  logger $0 $msg
  notify-send $msg
  unset ELEXIS_DB_CONFIG_ARGS
fi

lsb_release -a | egrep -i 'Wheezy|precise'

if [ $? -ne 0 ]; then
  msg="Elexis läuft nur unter wheezy oder precise. Aktuell gefunden: `lsb_release -scd`"
  echo $msg
  notify-send $msg
  exit 2
fi

set -e # fail on error

lsb_release -a | grep weezy && echo "Wheezy gefunden"
java -version 2>&1 | grep 'version "1.8' && echo "Found Java 8"

if [ -f $ECLIPSEPASSWORD_FILE ]
then
  echo "ECLIPSEPASSWORD_FILE $ECLIPSEPASSWORD_FILE gefunden"
else
  msg="Cleaning ECLIPSEPASSWORD_FILE $ECLIPSEPASSWORD_FILE and secure storage $HOME/.eclipse/org.eclipse.equinox.security/secure_storage"
  echo $msg
  logger $msg
  echo {{elexis.db_password}} > $ECLIPSEPASSWORD_FILE
  rm -f $HOME/.eclipse/org.eclipse.equinox.security/secure_storage
fi

export PATH=/usr/lib/jvm/java-8-oracle/jre/bin:$PATH
INST_PATH=$HOME/.medelexis-${ELEXIS_VARIANT}
echo $INST_PATH/Medelexis
ls -lrt $INST_PATH/Medelexis
if [ -f $INST_PATH/Medelexis ]
then
  echo $INST_PATH gibt es schon
else
  echo muss $INST_PATH erstellen und medelexis installieren
  mkdir -p $INST_PATH
  cd $INST_PATH
  if [ -f $ELEXIS_ZIP_FILE ]; then
    unzip $ELEXIS_ZIP_FILE
  else
    msg="Unable to unzip $ELEXIS_ZIP_FILE"
    echo $msg
    logger $msg
    notify-send "$msg"
    exit 2
  fi
fi

cd $INST_PATH


if [ -f configuration/.settings ]
then
  echo "configuration/.settings. Gefunden. Lizenz schon akzeptiert"
else
  echo "Erstelle configuration/.settings. zum akzeptieren der Lizenz"

mkdir -p configuration/.settings
echo "eclipse.preferences.version=1
usageConditionAcceptanceDate=06.11.15 13\:00
usageConditionAccepted=true" > configuration/.settings/MedelexisDesk.prefs
fi

if [ -f $MEDELEXIS_LICENSE ]
then
  echo "MEDELEXIS_LICENSE $MEDELEXIS_LICENSE vorhanden"
else
  echo "Muss $MEDELEXIS_LICENSE aus $DEFAULT_LICENSE holen"
  mkdir -p $HOME/elexis
  cp -pv $DEFAULT_LICENSE $MEDELEXIS_LICENSE
fi

logger "User $USER starting Medelexis in $PWD with result $result using $PATH"

./Medelexis -eclipse.password ~/.medelexis.dummy.password -clean -debug -consoleLog \
--use-config=elexis-${ELEXIS_VARIANT}-${DB_TO_USE} -vmargs \
-Dorg.eclipse.swt.internal.gtk.cairoGraphics=false \
$ELEXIS_DB_CONFIG_ARGS \
-Dprovisioning.UpdateRepository=${ELEXIS_VARIANT}

set result=$?
logger "User $USER done with Medelexis in $PWD with result $result using $PATH"

