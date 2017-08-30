#!/bin/bash
echo "Configuring the HIN Client (Singleuser Servermodus)"
export IDENTITY_FILE=/home/user_hin/user.hin
env
echo "keystore=$IDENTITY_FILE" > /home/user_hin/.hinclient-service-parameters.txt
echo "$PASSPHRASE" > /home/user_hin/passphrase.txt
echo "passphrase=/home/user_hin/passphrase.txt" >> /home/user_hin/.hinclient-service-parameters.txt
chmod 600 /home/user_hin/passphrase.txt
chmod 600 $IDENTITY_FILE
ls -lrt /home/user_hin/HIN\ Client/hinclientservice 
/home/user_hin/HIN\ Client/hinclientservice start
status=$?
echo START status is $status
while :
do
  sleep 5
  tail -f /home/user_hin/.HIN/HIN\ Client/hinclient.log
  /home/user_hin/HIN\ Client/hinclientservice status
status=$?
echo START status is $status
#  /home/user_hin/HIN\ Client/hinclientservice start
done

