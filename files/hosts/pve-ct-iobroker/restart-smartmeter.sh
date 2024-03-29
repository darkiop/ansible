#!/bin/bash

if [ "$HOSTNAME" = pve-ct-iobroker ]; then

  echo "hostname = pve-ct-iobroker"

  echo "ssh to loki and do a restart of ser2net.service ..."
  ssh darkiop@loki bash -c "'sudo /usr/bin/systemctl restart ser2net.service'"

  echo "restarting socat-loki-usb[0,1].service ..."
  sudo systemctl restart socat-loki-usb0.service
  sudo systemctl restart socat-loki-usb1.service

  sleep 5

  echo  "restarting ioBroker Adapter smartmeter.[0,1]"
  iobroker restart smartmeter.0
  iobroker restart smartmeter.1

elif [ "$HOSTNAME" = loki ]; then

  echo "hostname = loki"

  echo "restart ser2net.service ..."
  sudo systemctl restart ser2net.service

  echo "ssh to pve-ct-iobroker and do a restart of socat-loki-usb[0,1].service ..."
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb0.service'"
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb1.service'"

  sleep 5
  
  echo "ssh to pve-ct-iobroker and do a restart of ioBroker Adapter smartmeter.[0,1]"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.0'"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.1'"

else

  echo "hostname != pve-ct-iobroker"

  echo "ssh to loki and do a restart of ser2net.service ..."
  ssh darkiop@loki bash -c "'sudo /usr/bin/systemctl restart ser2net.service'"

  echo "ssh to pve-ct-iobroker and do a restart of socat-loki-usb[0,1].service ..."
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb0.service'"
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb1.service'"

  sleep 5

  echo "ssh to pve-ct-iobroker and do a restart of ioBroker Adapter smartmeter.[0,1]"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.0'"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.1'"

fi

# EOF