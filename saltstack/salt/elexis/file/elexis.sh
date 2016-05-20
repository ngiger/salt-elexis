#!/bin/bash
# Niklaus Giger 2016-04-01. Generated from salt/elexis/file/elexis.sh
# fail on error
set -x # show commands being executed

# configuration
export DB_TO_USE={{app.db_to_use}}
export ELEXIS_VARIANT={{app.variant}}
export ELEXIS_CONFIG="{{app.config}}"
export ELEXIS_DB_CONFIG_ARGS="-Dch.elexis.dbFlavor={{elexis.db_type}} \
-Dch.elexis.dbSpec=jdbc:{{elexis.db_type}}://{{db_server}}/{{app.db_to_use}} \
-Dch.elexis.dbUser={{elexis.db_user}} \
-Dch.elexis.dbPw={{elexis.db_password}}"
INST_PATH=/usr/local/bin/elexis-3.1-${ELEXIS_VARIANT}

export ECLIPSEPASSWORD_FILE="${HOME}/.elexis.dummy.password"

# some constants
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
echo $INST_PATH/Elexis3
ls -lrt $INST_PATH/Elexis3
if [ -f $INST_PATH/Elexis3 ]
then
  echo $INST_PATH gibt es schon
else
  msg="$INST_PATH/Elexis3 fehlt"
  echo $msg
  logger $msg
  notify-send "$msg"
  exit 2
fi

cd $INST_PATH

logger "User $USER starting Elexis3 in $PWD with result $result using $PATH"

./Elexis3 -eclipse.password ~/.elexis.dummy.password -clean -debug -consoleLog \
-vm /usr/lib/jvm/java-8-oracle/jre/bin/java \
--use-config=elexis-${ELEXIS_VARIANT}-${DB_TO_USE} -vmargs \
-Dorg.eclipse.swt.internal.gtk.cairoGraphics=false \
$ELEXIS_DB_CONFIG_ARGS \


set result=$?
logger "User $USER done with Elexis3 in $PWD with result $result using $PATH"

