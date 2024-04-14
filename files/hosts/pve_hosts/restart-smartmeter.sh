#!/bin/bash

debug=true

fancy_echo() {
  local color="$1"; shift
  local fmt="$1"; shift
  local color_code
  case "$color" in
    red) color_code="1;31" ;;
    green) color_code="1;32" ;;
    blue) color_code="1;34" ;;
    orange) color_code="1;33" ;;
    *) color_code="0" ;;
  esac
  printf "\n\033[${color_code}m$fmt\033[0m\n" "$@"
}

function debug_msg() {
    local color="$1"
    local msg="$2"
    if [ "$debug" = "true" ]; then fancy_echo "$color" "$msg"; fi
}

if [ "$HOSTNAME" = pve-ct-iobroker ]; then

  debug_msg blue "----- hostname = pve-ct-iobroker -----"

  debug_msg orange "ssh to loki and do a restart of ser2net.service ..."
  
  ssh darkiop@loki bash -c "'sudo /usr/bin/systemctl restart ser2net.service'"

  debug_msg orange  "restarting socat-loki-usb[0,1].service ..."
  sudo systemctl restart socat-loki-usb0.service
  sudo systemctl restart socat-loki-usb1.service

  sleep 5

  debug_msg orange   "restarting ioBroker Adapter smartmeter.[0,1]"
  iobroker restart smartmeter.0
  iobroker restart smartmeter.1

elif [ "$HOSTNAME" = loki ]; then

  debug_msg blue "----- hostname = loki -----"

  debug_msg orange "restart ser2net.service ..."
  sudo systemctl restart ser2net.service

  debug_msg orange "ssh to pve-ct-iobroker and do a restart of socat-loki-usb[0,1].service ..."
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb0.service'"
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb1.service'"

  sleep 5
  
  debug_msg orange "ssh to pve-ct-iobroker and do a restart of ioBroker Adapter smartmeter.[0,1]"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.0'"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.1'"

else

  debug_msg blue "----- hostname != pve-ct-iobroker -----"

  debug_msg orange "ssh to loki and do a restart of ser2net.service ..."
  ssh darkiop@loki bash -c "'sudo /usr/bin/systemctl restart ser2net.service'"

  debug_msg orange "ssh to pve-ct-iobroker and do a restart of socat-loki-usb[0,1].service ..."
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb0.service'"
  ssh darkiop@pve-ct-iobroker bash -c "'sudo systemctl restart socat-loki-usb1.service'"

  sleep 5

  debug_msg orange "ssh to pve-ct-iobroker and do a restart of ioBroker Adapter smartmeter.[0,1]"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.0'"
  ssh darkiop@pve-ct-iobroker bash -c "'iobroker restart smartmeter.1'"

fi

# EOF